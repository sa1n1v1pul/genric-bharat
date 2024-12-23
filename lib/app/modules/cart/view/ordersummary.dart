// ignore_for_file: use_super_parameters, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:genric_bharat/app/modules/cart/view/razorpayscreen.dart';

import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../api_endpoints/api_endpoints.dart';
import '../../delivery/controller/deliverycontroller.dart';
import '../../delivery/views/addressmodel.dart';
import '../../home/views/addressview.dart';
import '../../routes/app_routes.dart';
import '../controller/cartcontroller.dart';

class OrderSummaryScreen extends GetView<CartController> {
  const OrderSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    final deliveryController = Get.find<DeliveryDetailsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          color: Colors.black,
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Order Summary',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
        () => controller.cartItems.isEmpty
            ? const Center(
                child: Text('No items in cart'),
              )
            : Column(
                children: [
                  // Free delivery banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    color: Colors.blue.shade50,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Yay! You get Free delivery on this order!',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Items count
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${controller.cartItems.length} Items in your cart',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Items list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.cartItems[index];
                        return _buildOrderItem(item);
                      },
                    ),
                  ),

                  // Delivery details
                  _buildDeliveryDetails(deliveryController),
                  // Bottom summary
                  _buildOrderSummary(deliveryController),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderTotalSummary(DeliveryDetailsController deliveryController) {
    return Obx(() => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:'),
                Text(
                  '₹${deliveryController.finalAmount.value.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (deliveryController.discount.value > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Savings:'),
                  Text(
                    '₹${deliveryController.discount.value.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
              ),
            ],
          ],
        ));
  }

  Widget _buildOrderItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                '${ApiEndpoints.imageBaseUrl}${item.image}',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error_outline),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${item.quantity}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.price < item.price) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDetails(DeliveryDetailsController deliveryController) {
    return Obx(() {
      if (deliveryController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final selectedAddress = deliveryController.selectedAddress.value;
      if (selectedAddress == null) {
        return const Center(child: Text('No address selected'));
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deliver to:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                // TextButton(
                //   onPressed: () {
                //     final addressModel = AddressModel(
                //       id: selectedAddress.id,
                //       userId: selectedAddress.id,
                //       pinCode: selectedAddress.pinCode,
                //       shipAddress1: selectedAddress.address1,
                //       shipAddress2: selectedAddress.address2,
                //       area: selectedAddress.area,
                //       landmark: selectedAddress.landmark ?? '',
                //       city: selectedAddress.city,
                //       state: selectedAddress.state,
                //     );
                //     Get.to(() => AddressScreen(addressToEdit: addressModel));
                //   },
                //   child: const Text('Edit Address'),
                // ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              deliveryController.selectedPatientName.value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              selectedAddress.address1,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (selectedAddress.address2.isNotEmpty)
              Text(
                selectedAddress.address2,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            const SizedBox(height: 4),
            if (selectedAddress.landmark.isNotEmpty)
              Text(
                'Landmark: ${selectedAddress.landmark}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            const SizedBox(height: 4),
            Text(
              'Area: ${selectedAddress.area}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'City: ${selectedAddress.city}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'State: ${selectedAddress.state}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'PIN: ${selectedAddress.pinCode}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    });
  }

  void _showPaymentOptions(
      BuildContext context, DeliveryDetailsController deliveryController) {
    if (!deliveryController.validateDeliveryAddress()) {
      return;
    }

    // Create a serializable map of the address data
    final addressData = deliveryController.selectedAddress.value != null
        ? {
            'address1': deliveryController.selectedAddress.value!.address1,
            'address2': deliveryController.selectedAddress.value!.address2,
            'area': deliveryController.selectedAddress.value!.area,
            'landmark': deliveryController.selectedAddress.value!.landmark,
            'city': deliveryController.selectedAddress.value!.city,
            'state': deliveryController.selectedAddress.value!.state,
            'pinCode': deliveryController.selectedAddress.value!.pinCode,
          }
        : null;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildOrderTotalSummary(deliveryController),
            const SizedBox(height: 20),
            // COD Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Get.back(); // Close the bottom sheet

                  // Show a glassy loading dialog
                  Get.dialog(
                    WillPopScope(
                      onWillPop: () async => false,
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Center(
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const CircularProgressIndicator(),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Processing Order',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Please wait...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    barrierDismissible: false,
                    barrierColor: Colors.black.withOpacity(0.2),
                  );

                  try {
                    final result = await deliveryController.confirmCODOrder(
                      originalAmount: deliveryController.subtotal.value,
                      discountAmount: deliveryController.discount.value,
                      finalAmount: deliveryController.finalAmount.value,
                      couponCode: deliveryController.appliedCoupon.value,
                    );

                    // Close the loading dialog
                    Get.back();

                    // Show success snackbar and navigate to home
                    Get.snackbar(
                      'Success',
                      'Order placed successfully!\nOrder ID: ${result['transaction_number']}',
                      backgroundColor: Colors.green[100],
                      colorText: Colors.black,
                      duration: const Duration(seconds: 2),
                      snackPosition: SnackPosition.TOP,
                      margin: const EdgeInsets.all(16),
                    );

                    // Navigate to home after a brief delay
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Get.offAllNamed(Routes.HOME);
                    });
                  } catch (e) {
                    // Close the loading dialog
                    Get.back();

                    Get.snackbar(
                      'Error',
                      'Failed to place COD order: ${e.toString()}',
                      backgroundColor: Colors.red[100],
                      colorText: Colors.black,
                      duration: const Duration(seconds: 3),
                      margin: const EdgeInsets.all(16),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.loginGradientStart,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Cash on Delivery',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Online Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    Get.to(
                      () => const RazorpayCheckoutScreen(),
                      arguments: {
                        'subtotal': deliveryController.subtotal.value,
                        'discount': deliveryController.discount.value,
                        'finalAmount': deliveryController.finalAmount.value,
                        'appliedCoupon': deliveryController.appliedCoupon.value,
                        'patientName':
                            deliveryController.selectedPatientName.value,
                        'address':
                            addressData, // Pass the formatted address data
                      },
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: CustomTheme.loginGradientStart),
                ),
                child: Text(
                  'Online Payment',
                  style: TextStyle(
                    color: CustomTheme.loginGradientStart,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget _buildOrderSummary(DeliveryDetailsController deliveryController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Show original amount if there's a discount
          if (deliveryController.discount.value > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '₹${deliveryController.subtotal.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount (${deliveryController.appliedCoupon.value}):',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  '-₹${deliveryController.discount.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${deliveryController.finalAmount.value.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  _showPaymentOptions(Get.context!, deliveryController),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.loginGradientStart,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Choose payment method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
