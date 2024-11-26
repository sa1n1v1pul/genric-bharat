import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../controllers/previewcontroller.dart';

class OrderPreviewScreen extends StatelessWidget {
  final OrderPreviewController controller = Get.put(OrderPreviewController());

  OrderPreviewScreen({Key? key, required Map<String, dynamic> orderData})
      : super(key: key) {
    controller.setOrderDetails(orderData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.only(left: 4),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? Colors.black : Colors.grey)
                        .withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            );
          },
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        toolbarHeight: 60,
      ),
      body: Obx(() {
        final order = controller.orderDetails.value;
        return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Order Summary Card
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: CustomTheme.loginGradientStart.withOpacity(0.4),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Card(
                  margin: EdgeInsets.zero, // Remove extra margin
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order id: ${order.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy HH:mm').format(order.createdAt),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                          'Status',
                          order.orderStatus,
                          color: order.orderStatus == 'Delivered'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        _buildInfoRow('Payment Method', order.paymentMethod),
                        _buildInfoRow('Payment Status', order.paymentStatus),
                        _buildInfoRow('Transaction ID', order.txnId),
                      ],
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 16),

              // Cart Items Card
              Container(decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(
                  color: CustomTheme.loginGradientStart.withOpacity(0.4),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
                child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cart Items',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(),
                          ...order.cart.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Item Name
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                // Quantity
                                Row(
                                  children: [
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    const SizedBox(
                                        width:
                                        16), // Add space between Qty and Amount
                                    Text(
                                      '${order.currencySign}${item.price}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),

                          const SizedBox(height: 16),

                          // Shipping Details Card
                          Card(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                border: Border.all(
                                  color: CustomTheme.loginGradientStart.withOpacity(0.4), // Border color
                                  width: 1.5, // Border thickness
                                ),
                                borderRadius: BorderRadius.circular(8), // Optional: Rounded corners
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Shipping Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Divider(),
                                    _buildInfoRow('Name', order.shippingInfo.name),
                                    _buildInfoRow('Address', order.shipping.address),
                                    _buildInfoRow('Area', order.shipping.area),
                                    _buildInfoRow('City', order.shipping.city),
                                    _buildInfoRow('State', order.shipping.state),
                                    _buildInfoRow('Pincode', order.shipping.pincode),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Billing Details Card
                          Card(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                border: Border.all(
                                  color: CustomTheme.loginGradientStart.withOpacity(0.4),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Billing Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Divider(),
                                    _buildInfoRow('Name', order.billingInfo.firstName),
                                    _buildInfoRow('Address', order.billingInfo.address),
                                    _buildInfoRow('City', order.billingInfo.city),
                                    _buildInfoRow('State', order.billingInfo.state),
                                    _buildInfoRow('Zip', order.billingInfo.zip),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Price Details Card
                          Card(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                border: Border.all(
                                  color: CustomTheme.loginGradientStart.withOpacity(0.4),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Price Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Divider(),
                                    _buildInfoRow(
                                      'Total Amount',
                                      '${order.currencySign}${order.finalPrice}',
                                      isBold: true,
                                    ),
                                    if (order.couponApplied != null)
                                      _buildInfoRow(
                                        'Coupon Applied',
                                        order.couponApplied!,
                                        color: Colors.green,
                                      ),
                                    _buildInfoRow(
                                      'Discount',
                                      '${order.currencySign}${order.discount}',
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    )),
              )
            ]));
      }),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns text at the top
        children: [
          // Label Text
          Expanded(
            flex: 2, // Allocate less space to the label
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          // Value Text
          Expanded(
            flex: 3, // Allocate more space to the value
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.left, // Align value to the left
              overflow: TextOverflow.visible, // Allows multi-line
            ),
          ),
        ],
      ),
    );
  }
}