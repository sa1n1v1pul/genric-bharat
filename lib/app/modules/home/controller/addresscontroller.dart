import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_endpoints/api_endpoints.dart';
import '../../api_endpoints/api_provider.dart';
import '../../cart/controller/cartcontroller.dart';
import '../../delivery/controller/deliverycontroller.dart';
import '../../delivery/views/addressmodel.dart';
import '../../location/controller/location_controller.dart';
import '../../routes/app_routes.dart';

class AddressController extends GetxController {
  final LocationController locationController = Get.find<LocationController>();
  final ApiProvider apiProvider = Get.find<ApiProvider>();
  final formKey = GlobalKey<FormState>();
  final RxBool isManualPincodeEntry = true.obs;
  final AddressModel? addressToEdit;

  AddressController({this.addressToEdit});
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
    if (addressToEdit != null) {
      // Pre-fill the form with existing address data
      pincodeController.text = addressToEdit!.pinCode;
       addressLine1Controller.text = addressToEdit!.shipAddress1;
       addressLine2Controller.text = addressToEdit!.shipAddress2;
      localityController.text = addressToEdit!.area;
      landmarkController.text = addressToEdit!.landmark ?? '';
      cityController.text = addressToEdit!.city;
      stateController.text = addressToEdit!.state;

      // Validate pincode to enable/disable fields
      validatePincode(addressToEdit!.pinCode);
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

      // If editing an existing address and user wants to use current location
      if (addressToEdit != null) {
        // Clear existing address fields before populating with current location
        pincodeController.clear();
        addressLine1Controller.clear();
        addressLine2Controller.clear();
        localityController.clear();
        landmarkController.clear();
        cityController.clear();
        stateController.clear();
      }

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

          // When editing an existing address, preserve existing data
          if (addressToEdit != null) {
            // Only update fields that are empty
            cityController.text = cityController.text.isEmpty
                ? (place.locality ?? locationController.cityName.value)
                : cityController.text;

            stateController.text = stateController.text.isEmpty
                ? (place.administrativeArea ?? locationController.stateName.value)
                : stateController.text;

            // Only modify pincode if it's empty
            if (pincodeController.text.isEmpty && place.postalCode != null && place.postalCode!.isNotEmpty) {
              pincodeController.text = place.postalCode!;
            }

            // Only update address1 if it's empty
            if (addressLine1Controller.text.isEmpty && place.subLocality != null && place.subLocality!.isNotEmpty) {
              addressLine1Controller.text = place.subLocality!;
            }
          }
          // For new address, populate all fields
          else {
            cityController.text = place.locality ?? locationController.cityName.value;
            stateController.text = place.administrativeArea ?? locationController.stateName.value;

            if (place.postalCode != null && place.postalCode!.isNotEmpty) {
              pincodeController.text = place.postalCode!;
            }

            if (place.subLocality != null && place.subLocality!.isNotEmpty) {
              addressLine1Controller.text = place.subLocality!;
            }
          }

          // Make API call to get additional details if pincode is 6 digits
          if (pincodeController.text.length == 6) {
            try {
              final response = await apiProvider.checkPincode(pincodeController.text);
              if (response.data['status'] == 'success' && response.data['data'] != null) {
                final locationData = response.data['data'];

                // Only update these fields if they are empty when editing
                if (addressToEdit != null) {
                  addressLine2Controller.text = addressLine2Controller.text.isEmpty
                      ? (locationData['post_office'] ?? '')
                      : addressLine2Controller.text;

                  localityController.text = localityController.text.isEmpty
                      ? (locationData['locality'] ?? '')
                      : localityController.text;

                  landmarkController.text = landmarkController.text.isEmpty
                      ? (locationData['landmark'] ?? '')
                      : landmarkController.text;

                  if (addressLine1Controller.text.isEmpty && locationData['sublocality'] != null) {
                    addressLine1Controller.text = locationData['sublocality'];
                  }
                }
                // For new address, populate all fields
                else {
                  addressLine2Controller.text = locationData['post_office'] ?? '';
                  localityController.text = locationData['locality'] ?? '';

                  if (locationData['landmark'] != null) {
                    landmarkController.text = locationData['landmark'];
                  }

                  if (locationData['sublocality'] != null) {
                    addressLine1Controller.text = locationData['sublocality'];
                  }
                }
              }
            } catch (e) {
              print('Error fetching post office data: $e');
            }
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
      print('🔍 Address Operation Started...');
      isLoading.value = true;

      final userId = await _getUserId();
      if (userId <= 0) {
        throw Exception('Invalid User ID');
      }

      final addressData = {
        // Explicitly include ID for existing addresses
        if (addressToEdit != null) 'id': addressToEdit!.id,
        'user_id': userId.toString(),
        'pin_code': pincodeController.text,
        'ship_address1': addressLine1Controller.text,
        'ship_address2': addressLine2Controller.text,
        'area': localityController.text,
        'landmark': landmarkController.text,
        'city': cityController.text,
        'state': stateController.text,
      };

      print('📦 Payload to API: $addressData');

      // Use the correct endpoint based on whether it's a new or existing address
      final endpoint = addressToEdit != null
          ? '${ApiEndpoints.updateAddress}/${addressToEdit!.id}'
          : ApiEndpoints.updateAddress;

      final response = await apiProvider.postOrderConfirmation(
          endpoint,
          addressData
      );

      print('🌐 API Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          addressToEdit != null
              ? 'Address updated successfully'
              : 'New address saved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Refresh address lists
        try {
          final cartController = Get.find<CartController>();
          await cartController.fetchAddresses();
        } catch (e) {
          print('❌ Cart Controller Address Refresh Error: $e');
        }

        try {
          final deliveryController = Get.find<DeliveryDetailsController>();
          await deliveryController.loadUserDetails();
        } catch (e) {
          print('❌ Delivery Controller Address Refresh Error: $e');
        }

        // Navigate back
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
       // Get.toNamed(Routes.DELIVERY);

      } else {
        print('❌ API Reported Failure: ${response.data}');
        throw Exception('Failed to save/update address');
      }
    } catch (e) {
      print('❌ Address Save/Update Error: $e');
      Get.snackbar(
        'Error',
        'Failed to save/update address',
        backgroundColor: Colors.red,
        colorText: Colors.white,
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

