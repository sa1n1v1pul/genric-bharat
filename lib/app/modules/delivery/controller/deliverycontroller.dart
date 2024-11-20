import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api_endpoints/api_provider.dart';
import '../../cart/view/ordersummary.dart';

class DeliveryDetailsController extends GetxController {
  final ApiProvider apiProvider = Get.find<ApiProvider>();
  final UserService userService = Get.find<UserService>();

  // Observable variables
  final RxString selectedPatientName = ''.obs;
  final RxString selectedAddress = ''.obs;
  final RxString selectedLocality = ''.obs;
  final RxString selectedCity = ''.obs;
  final RxString selectedState = ''.obs;
  final RxString selectedPincode = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasData = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserDetails();
  }

  Future<void> loadUserDetails() async {
    try {
      print('Loading user details...');
      isLoading.value = true;

      final userId = userService.getCurrentUserId();
      print('User ID: $userId');

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
        selectedLocality.value = userData['landmark'] ?? 'N/A';
        selectedLocality.value = userData['locality'] ?? 'N/A';
        selectedCity.value = userData['ship_city'] ?? 'N/A';
        selectedState.value = userData['state'] ?? 'N/A';
        selectedPincode.value = userData['ship_zip'] ?? '';

        hasData.value = selectedAddress.value.isNotEmpty;
        update();
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

  void onProceedToCheckout() {
    if (selectedPatientName.isEmpty || selectedAddress.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add an address to proceed',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
      return;
    }
    Get.to(() => OrderSummaryScreen());
  }
}