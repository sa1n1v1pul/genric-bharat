import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../api_endpoints/api_provider.dart';
import '../../api_endpoints/api_endpoints.dart';
import '../../cart/controller/cartcontroller.dart';
import '../../cart/view/ordersummary.dart';
import '../../home/views/addressview.dart';
import '../../routes/app_routes.dart';
import '../views/addressmodel.dart';

class DeliveryDetailsController extends GetxController {
  final ApiProvider apiProvider = Get.find<ApiProvider>();
  final UserService userService = Get.find<UserService>();
  final CartController cartController = Get.find<CartController>();
  final TextEditingController patientNameController = TextEditingController();

  final RxString selectedPatientName = ''.obs;
  final RxList<Address> addresses = <Address>[].obs;
  final Rx<Address?> selectedAddress = Rx<Address?>(null);

  final RxString selectedLocality = ''.obs;
  final RxString selectedCity = ''.obs;
  final RxString selectedState = ''.obs;
  final RxString selectedPincode = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasData = false.obs;
  RxDouble subtotal = 0.0.obs;
  RxDouble discount = 0.0.obs;
  RxDouble finalAmount = 0.0.obs;
  RxString appliedCoupon = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserDetails();
    updateOrderAmounts();

    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      subtotal.value = args['subtotal'] ?? 0.0;
      discount.value = args['discount'] ?? 0.0;
      finalAmount.value = args['finalAmount'] ?? 0.0;
      appliedCoupon.value = args['appliedCoupon'] ?? '';
    }


    ever(RxString(Get.currentRoute), (String route) {
      if (route == Routes.DELIVERY) {
        loadUserDetails();
        updateOrderAmounts();
      }
    });
  }

  void updateOrderAmounts() {
    final orderSummary = cartController.getOrderSummary();
    subtotal.value = orderSummary['subtotal'];
    discount.value = orderSummary['discount'];
    finalAmount.value = orderSummary['finalAmount'];
    appliedCoupon.value = orderSummary['appliedCoupon'];
  }

  @override
  void onClose() {
    patientNameController.dispose();
    super.onClose();
  }

  Future<void> loadUserDetails() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      if (userId <= 0) {
        Get.snackbar('Error', 'Please log in again');
        return;
      }

      // Fetch user profile for patient name
      final userResponse = await apiProvider.getUserProfile(userId);
      if (userResponse.data != null) {
        final userData = userResponse.data;
        String fullName = userData['fullname'] ?? '';
        if (fullName.isEmpty) {
          String firstName = userData['first_name'] ?? '';
          String lastName = userData['last_name'] ?? '';
          fullName = '$firstName ${lastName}'.trim();
        }
        selectedPatientName.value = fullName;
      }

      // Fetch addresses using CartController's endpoint
      final addressResponse = await apiProvider.get(
          ApiEndpoints.getAddressesForUser(userId)
      );

      if (addressResponse.statusCode == 200) {
        final List<dynamic> addressData = addressResponse.data['data'];
        addresses.value = addressData.map((data) => Address.fromJson(data)).toList();

        // Select the first address by default if available
        if (addresses.isNotEmpty) {
          selectedAddress.value = addresses.first;
        }
      }
    } catch (e) {
      print('Error loading user details: $e');
      Get.snackbar('Error', 'Failed to load user details');
    } finally {
      isLoading.value = false;
    }
  }

  void selectAddress(Address address) {
    selectedAddress.value = address;
    // Update individual fields when address is selected
    selectedLocality.value = address.area;
    selectedCity.value = address.city;
    selectedState.value = address.state;
    selectedPincode.value = address.pinCode;
  }

  Future<Map<String, dynamic>> confirmOrder({
    required String paymentId,
    required double originalAmount,
    required double discountAmount,
    required double finalAmount,
    required String couponCode,
  }) async {
    try {
      print('Preparing order confirmation data...');

      // Get the user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      if (userId <= 0) {
        throw Exception('Invalid user ID');
      }

      // Validate that address details are not empty
      if (selectedAddress.value == null) {
        throw Exception('No address selected');
      }

      // Ensure area, city, state, and pincode are not empty
      if (selectedLocality.value.isEmpty) {
        selectedLocality.value = selectedAddress.value!.area;
      }
      if (selectedCity.value.isEmpty) {
        selectedCity.value = selectedAddress.value!.city;
      }
      if (selectedState.value.isEmpty) {
        selectedState.value = selectedAddress.value!.state;
      }
      if (selectedPincode.value.isEmpty) {
        selectedPincode.value = selectedAddress.value!.pinCode;
      }

      // Format the current date and time
      final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

      // Create order items array with proper format
      final List<Map<String, dynamic>> orderItems = cartController.cartItems.map((item) {
        return {
          'name': item.name,
          'quantity': item.quantity.toString(),
          'qty': item.quantity.toString(), // Adding qty field as seen in Postman
          'rs': (item.price * item.quantity).toStringAsFixed(2)
        };
      }).toList();

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'payment_id': paymentId,
        'payment_date': formattedDate,
        'user_id': userId,
        if (couponCode.isNotEmpty) 'coupon_applied': couponCode,
        'original_amount': originalAmount.toStringAsFixed(2),
        'discount': discountAmount.toStringAsFixed(2),
        'final_amount': finalAmount.toStringAsFixed(2),
        'patient_name': selectedPatientName.value,
        'delivery_address': selectedAddress.value!.formattedAddress,
        'area': selectedLocality.value,
        'city': selectedCity.value,
        'state': selectedState.value,
        'pincode': selectedPincode.value,
        'items': orderItems,
      };

      print('Order confirmation request body: $requestBody');

      // Make the API call
      final response = await apiProvider.postOrderConfirmation(
        ApiEndpoints.orders,
        requestBody,
      );

      print('Order confirmation API response: ${response.data}');

      if (response.data['status'] == 'success') {
        print('Order confirmed successfully! Order ID: ${response.data['data']['order_id']}');
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to confirm order');
      }
    } catch (e) {
      print('Error confirming order: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> confirmCODOrder({
    required double originalAmount,
    required double discountAmount,
    required double finalAmount,
    required String couponCode,
  }) async {
    try {
      print('Preparing COD order confirmation data...');

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      if (userId <= 0) {
        throw Exception('Invalid user ID');
      }

      if (selectedAddress.value == null) {
        throw Exception('Delivery address is required');
      }

      // Format the current date and time
      final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

      // Create order items array - Fixed to match confirmOrder format
      final List<Map<String, dynamic>> orderItems = cartController.cartItems.map((item) {
        return {
          'name': item.name,
          'quantity': item.quantity.toString(),
          'qty': item.quantity.toString(),
          'rs': (item.price * item.quantity).toStringAsFixed(2)
        };
      }).toList();

      // Prepare request body with all required fields - Matched with confirmOrder
      final Map<String, dynamic> requestBody = {
        'payment_date': formattedDate,
        'user_id': userId,
        if (couponCode.isNotEmpty) 'coupon_applied': couponCode,
        'original_amount': originalAmount.toStringAsFixed(2),
        'discount': discountAmount.toStringAsFixed(2),
        'final_amount': finalAmount.toStringAsFixed(2),
        'patient_name': selectedPatientName.value,
        'delivery_address': selectedAddress.value!.formattedAddress,
        'area': selectedAddress.value!.area,
        'city': selectedAddress.value!.city,
        'state': selectedAddress.value!.state,
        'pincode': selectedAddress.value!.pinCode,
        'items': orderItems, // Changed from 'order_items' to 'items' to match confirmOrder
      };

      print('COD order request body: $requestBody');

      // Validate required fields before making the API call
      if (requestBody['city']?.isEmpty ?? true) {
        throw Exception('City is required');
      }
      if (requestBody['state']?.isEmpty ?? true) {
        throw Exception('State is required');
      }
      if (requestBody['pincode']?.isEmpty ?? true) {
        throw Exception('Pincode is required');
      }

      final response = await apiProvider.postOrderCODConfirmation(
        ApiEndpoints.ordersCOD,
        requestBody,
      );

      print('COD order API response: ${response.data}');

      if (response.data['status'] == 'success') {
        print('COD Order confirmed! Order ID: ${response.data['data']['order_id']}');
        // Clear cart after successful order
        cartController.clearAllCart();
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to confirm COD order');
      }
    } catch (e) {
      print('Error confirming COD order: $e');
      throw e;
    }
  }

  // Add this helper method to validate address before placing order
  bool validateDeliveryAddress() {
    if (selectedAddress.value == null) {
      Get.snackbar(
        'Error',
        'Please select a delivery address',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
      return false;
    }

    final address = selectedAddress.value!;
    if (address.city.isEmpty || address.state.isEmpty || address.pinCode.isEmpty) {
      Get.snackbar(
        'Error',
        'Please provide complete address with city, state and pincode',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
      return false;
    }

    return true;
  }


  void onAddAddressPressed() {
    Get.to(() => AddressScreen())?.then((_) => loadUserDetails());
  }

  void onEditAddressPressed(AddressModel address) {
    Get.to(() => AddressScreen(addressToEdit: address))?.then((_) => loadUserDetails());
  }
  Future<void> updatePatientName() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      if (userId <= 0) {
        throw Exception('Invalid user ID');
      }

      final newName = patientNameController.text.trim();
      if (newName.isEmpty) {
        throw Exception('Please enter patient name');
      }

      await apiProvider.updateUserProfile(userId, {
        'fullname': newName,
      });

      selectedPatientName.value = newName;

    } catch (e) {
      print('Error updating patient name: $e');
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onProceedToCheckout() async {
    try {
      if (selectedAddress.value == null) {
        Get.snackbar(
          'Error',
          'Please select a delivery address',
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
        );
        return;
      }

      if (selectedPatientName.isEmpty) {
        if (patientNameController.text.trim().isEmpty) {
          Get.snackbar(
            'Error',
            'Please enter patient name',
            backgroundColor: Colors.red[100],
            colorText: Colors.black,
          );
          return;
        }
        await updatePatientName();
      }

      Get.to(() => OrderSummaryScreen(), arguments: {
        'subtotal': subtotal.value,
        'discount': discount.value,
        'finalAmount': finalAmount.value,
        'appliedCoupon': appliedCoupon.value,
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
class Address {
  final int id;
  final String pinCode;
  final String address1;
  final String address2;
  final String area;
  final String landmark;
  final String city;
  final String state;
  String get formattedAddress {
    final List<String> parts = [
      address1,
      if (address2.isNotEmpty) address2,
      if (landmark.isNotEmpty) 'Landmark: $landmark',
      'Area: $area',
      '$city, $state',
      'PIN: $pinCode'
    ];
    return parts.join(', ');
  }

  String get fullAddress {
    final List<String> parts = [
      address1,
      if (address2.isNotEmpty) address2,
      if (landmark.isNotEmpty) 'Landmark: $landmark',
      'Area: $area',
      '$city',
      state,
      'PIN: $pinCode'
    ];
    return parts.where((part) => part.isNotEmpty).join('\n');
  }

  Address({
    required this.id,
    required this.pinCode,
    required this.address1,
    required this.address2,
    required this.area,
    required this.landmark,
    required this.city,
    required this.state,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      pinCode: json['pin_code'] ?? '',
      address1: json['ship_address1'] ?? '',
      address2: json['ship_address2'] ?? '',
      area: json['area'] ?? '',
      landmark: json['landmark'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
    );
  }
}