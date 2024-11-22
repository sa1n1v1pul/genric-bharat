import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_endpoints/api_provider.dart';
import '../../cart/controller/cartcontroller.dart';
import '../../cart/view/ordersummary.dart';
import '../../routes/app_routes.dart';

class DeliveryDetailsController extends GetxController {
  final ApiProvider apiProvider = Get.find<ApiProvider>();
  final UserService userService = Get.find<UserService>();
  final CartController cartController = Get.find<CartController>();
  // Add TextEditingController for patient name input
  final TextEditingController patientNameController = TextEditingController();

  final RxString selectedPatientName = ''.obs;
  final RxString selectedAddress = ''.obs;
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

    // Get the order summary data from arguments
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      subtotal.value = args['subtotal'] ?? 0.0;
      discount.value = args['discount'] ?? 0.0;
      finalAmount.value = args['finalAmount'] ?? 0.0;
      appliedCoupon.value = args['appliedCoupon'] ?? '';
    }

    // Listen to route changes
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
        print('Invalid User ID: $userId');
        Get.snackbar(
          'Error',
          'Please log in again',
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
        );
        return;
      }

      print('Fetching user profile for ID: $userId');
      final response = await apiProvider.getUserProfile(userId);
      print('API Response: ${response.data}');

      if (response.data != null) {
        final userData = response.data;

        // Set patient name
        String fullName = userData['fullname'] ?? '';
        if (fullName.isEmpty) {
          String firstName = userData['first_name'] ?? '';
          String lastName = userData['last_name'] ?? '';
          fullName = '$firstName ${lastName}'.trim();
        }
        selectedPatientName.value = fullName;

        // Set street address
        final addressParts = <String>[];
        if (userData['ship_address1']?.isNotEmpty == true) {
          addressParts.add(userData['ship_address1']);
        }
        if (userData['ship_address2']?.isNotEmpty == true) {
          addressParts.add(userData['ship_address2']);
        }
        selectedAddress.value = addressParts.join(', ');

        // Set individual location components with null checks
        selectedLocality.value = userData['locality'] ?? userData['landmark'] ?? 'N/A';
        selectedCity.value = userData['ship_city'] ?? 'N/A';
        selectedState.value = userData['state'] ?? 'N/A';
        selectedPincode.value = userData['ship_zip']?.isEmpty == true ? 'N/A' : userData['ship_zip'];

        hasData.value = selectedAddress.value.isNotEmpty;
      }
    } catch (e) {
      print('Error loading user details: $e');
      Get.snackbar(
        'Error',
        'Failed to load user details',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onAddAddressPressed() {
    Get.toNamed('/add-address')?.then((_) {
      loadUserDetails();
    });
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
      if (selectedAddress.isEmpty) {
        Get.snackbar(
          'Error',
          'Please add an address to proceed',
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
        );
        return;
      }

      // If patient name is empty, update it first
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

      // Navigate to OrderSummaryScreen with the current amounts
      Get.to(() => OrderSummaryScreen(), arguments: {
        'subtotal': subtotal.value,
        'discount': discount.value,
        'finalAmount': finalAmount.value,
        'appliedCoupon': appliedCoupon.value,
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    }
  }
}