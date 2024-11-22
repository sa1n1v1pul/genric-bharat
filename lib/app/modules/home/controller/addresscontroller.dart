import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_endpoints/api_provider.dart';
import '../../cart/controller/cartcontroller.dart';
import '../../location/controller/location_controller.dart';
import '../../routes/app_routes.dart';

class AddressController extends GetxController {
  final LocationController locationController = Get.find<LocationController>();
  final ApiProvider apiProvider = Get.find<ApiProvider>();
  final formKey = GlobalKey<FormState>();
  final RxBool isManualPincodeEntry = true.obs;

  // Text Controllers
  final pincodeController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final localityController = TextEditingController();
  final landmarkController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool hasAddress = false.obs;
  final RxString savedAddress = ''.obs;
  final RxInt selectedAddressType = 0.obs;
  final RxBool isPincodeValid = false.obs;
  final RxString pincodeValidationMessage = ''.obs;
  final RxBool isDeliveryAvailable = false.obs;

  // Previous pincode to track changes
  String previousPincode = '';
  String? validatePincode(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter pincode';
    }
    if (value!.length != 6) {
      return 'Please enter valid 6-digit pincode';
    }
    if (!isPincodeValid.value) {
      return 'Invalid pincode';
    }
    if (!isDeliveryAvailable.value) {
      return 'Delivery not available in this location';
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    pincodeController.addListener(_handlePincodeChange);
    loadSavedAddress();
    if (locationController.currentPosition.value != null) {
      _populateFieldsFromLocation();
    }
  }

  void _handlePincodeChange() {
    final currentPincode = pincodeController.text.trim();

    // Only proceed if pincode has actually changed
    if (currentPincode != previousPincode) {
      previousPincode = currentPincode;
      isManualPincodeEntry.value = true;

      // Clear all fields when pincode changes
      _clearFieldsExceptPincode();

      // Validate and populate new data if pincode is complete
      if (currentPincode.length == 6) {
        _validateAndPopulateFromPincode();
      } else {
        // Reset validation states if pincode is incomplete
        _resetValidationStates();
      }
    }
  }

  void _clearFieldsExceptPincode() {
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    localityController.clear();
    landmarkController.clear();
    cityController.clear();
    stateController.clear();
  }

  void _resetValidationStates() {
    isPincodeValid.value = false;
    isDeliveryAvailable.value = false;
    pincodeValidationMessage.value = '';
  }

  Future<void> _validateAndPopulateFromPincode() async {
    try {
      isLoading.value = true;
      _resetValidationStates();

      final response = await apiProvider.checkPincode(pincodeController.text);
      print('Pincode API Response: ${response.data}');

      if (response.data['status'] == 'success') {
        isPincodeValid.value = true;
        final locationData = response.data['data'];

        isDeliveryAvailable.value = locationData['delivery_status'] == 'Available';
        pincodeValidationMessage.value = isDeliveryAvailable.value
            ? 'Delivery available in this location'
            : 'Delivery not available in this location';

        if (isDeliveryAvailable.value) {
          _populateFieldsFromPincodeData(locationData);
        }
      } else {
        pincodeValidationMessage.value = response.data['message'] ?? 'Invalid pincode';
      }
    } catch (e) {
      print('Pincode validation error: $e');
      pincodeValidationMessage.value = 'Error validating pincode';
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFieldsFromPincodeData(Map<String, dynamic> data) {
    cityController.text = data['city_name'] ?? '';
    stateController.text = data['state'] ?? '';
    localityController.text = data['locality'] ?? '';
    addressLine2Controller.text = data['post_office'] ?? ''; // Always use post office

    if (data['landmark'] != null) {
      landmarkController.text = data['landmark'];
    }

    if (data['sublocality'] != null) {
      addressLine1Controller.text = data['sublocality'];
    }
  }

  @override
  void onClose() {
    pincodeController.removeListener(_handlePincodeChange);
    pincodeController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    localityController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    super.onClose();
  }

  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      isManualPincodeEntry.value = false;
      await locationController.requestPermissionAndGetLocation();
      await _populateFieldsFromLocation();
    } catch (e) {
      print('Error getting current location: $e');
      Get.snackbar(
        'Error',
        'Failed to get current location',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSavedAddress() async {
    try {
      print('Loading address from API...');
      isLoading.value = true;

      final userId = await _getUserId();
      if (userId <= 0) {
        print('Invalid User ID: $userId');
        Get.snackbar(
          'Error',
          'Please log in again',
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
        );
        return;
      }

      final response = await apiProvider.getUserProfile(userId);
      final userData = response.data['data'];
      print('Received user profile data: $userData');

      if (userData != null) {
        pincodeController.text = userData['ship_zip'] ?? '';
        addressLine1Controller.text = userData['ship_address1'] ?? '';
        addressLine2Controller.text = userData['ship_address2'] ?? '';
        localityController.text = userData['locality'] ?? '';
        landmarkController.text = userData['landmark'] ?? '';
        cityController.text = userData['ship_city'] ?? '';
        stateController.text = userData['state'] ?? '';

        hasAddress.value = userData['ship_address1'] != null && userData['ship_address1'].isNotEmpty;

        if (hasAddress.value) {
          savedAddress.value = _formatAddress(userData);
        }
      }
    } catch (e) {
      print('Error loading address from API: $e');
      Get.snackbar(
        'Error',
        'Failed to load address',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _formatAddress(Map<String, dynamic> userData) {
    final parts = <String>[];

    if (userData['ship_address1']?.isNotEmpty == true)
      parts.add(userData['ship_address1']);
    if (userData['ship_address2']?.isNotEmpty == true)
      parts.add(userData['ship_address2']);
    if (userData['locality']?.isNotEmpty == true)
      parts.add(userData['locality']);
    if (userData['landmark']?.isNotEmpty == true)
      parts.add(userData['landmark']);
    if (userData['ship_city']?.isNotEmpty == true)
      parts.add(userData['ship_city']);
    if (userData['state']?.isNotEmpty == true)
      parts.add(userData['state']);
    if (userData['ship_zip']?.isNotEmpty == true)
      parts.add(userData['ship_zip']);

    return parts.join(', ');
  }

  Future<void> _populateFieldsFromLocation() async {
    try {
      if (locationController.currentPosition.value != null) {
        final position = locationController.currentPosition.value!;
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          print('Retrieved location data: $place');

          cityController.text = place.locality ?? locationController.cityName.value;
          stateController.text = place.administrativeArea ?? locationController.stateName.value;

          if (place.postalCode != null && place.postalCode!.isNotEmpty) {
            pincodeController.text = place.postalCode!;
            // Always make API call to get post office name
            if (pincodeController.text.length == 6) {
              try {
                final response = await apiProvider.checkPincode(pincodeController.text);
                if (response.data['status'] == 'success' &&
                    response.data['data'] != null) {
                  final locationData = response.data['data'];
                  addressLine2Controller.text = locationData['post_office'] ?? '';

                  // Update other fields from API response
                  if (locationData['locality'] != null) {
                    localityController.text = locationData['locality'];
                  }
                  if (locationData['landmark'] != null) {
                    landmarkController.text = locationData['landmark'];
                  }
                  if (locationData['sublocality'] != null) {
                    addressLine1Controller.text = locationData['sublocality'];
                  }
                }
              } catch (e) {
                print('Error fetching post office data: $e');
              }
            }
          }

          if (place.subLocality != null && place.subLocality!.isNotEmpty && addressLine1Controller.text.isEmpty) {
            addressLine1Controller.text = place.subLocality!;
          }
        }
      }
    } catch (e) {
      print('Error populating fields from location: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch address details',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    }
  }

  Future<void> saveAddress() async {
    if (!formKey.currentState!.validate()) return;

    try {
      print('Saving address to API...');
      isLoading.value = true;

      final userId = await _getUserId();
      if (userId <= 0) {
        throw Exception('Invalid User ID');
      }

      final addressData = {
        'address_type': selectedAddressType.value.toString(),
        'user_id': userId.toString(),
        'ship_zip': pincodeController.text,
        'ship_address1': addressLine1Controller.text,
        'ship_address2': addressLine2Controller.text,
        'locality': localityController.text,
        'ship_city': cityController.text,
        'state': stateController.text,
        'landmark': landmarkController.text,
      };

      print('Sending address data: $addressData');
      final response = await apiProvider.updateAddress(addressData);
      print('API Response: ${response.data}');

      if (response.data['status'] == true) {
        // Update local state
        hasAddress.value = true;
        savedAddress.value = '''
${addressLine1Controller.text},
${addressLine2Controller.text},
${localityController.text},
${landmarkController.text.isNotEmpty ? '${landmarkController.text}, ' : ''}
${cityController.text}, ${stateController.text}
${pincodeController.text}'''.trim();

        // Update cart controller if needed
        try {
          final cartController = Get.find<CartController>();
          cartController.hasAddress.value = true;
        } catch (e) {
          print('CartController not found: $e');
        }

        Get.snackbar(
          'Success',
          'Address saved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (Get.currentRoute != Routes.DELIVERY) {
          Get.offNamed(Routes.DELIVERY);
        } else {
          Get.back();
        }
      } else {
        throw Exception('Failed to save address');
      }
    } catch (e) {
      print('Error saving address: $e');
      Get.snackbar(
        'Error',
        'Failed to save address',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearFields() {
    pincodeController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    localityController.clear();
    landmarkController.clear();
    cityController.clear();
    stateController.clear();
    selectedAddressType.value = 0;
  }
}