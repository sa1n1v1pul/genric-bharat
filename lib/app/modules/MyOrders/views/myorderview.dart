import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../controllers/myordercontroller.dart';

class MyOrdersView extends GetView<MyOrdersController> {
  final bool fromBottomNav;

  const MyOrdersView({Key? key, this.fromBottomNav = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<MyOrdersController>()) {
      Get.put(MyOrdersController());
    }

    // Safely get isDarkMode
    final bool isDarkMode = Get.isDarkMode ?? false;

    return Scaffold(
      backgroundColor:
      fromBottomNav ? CustomTheme.backgroundColor : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false, // Changed this to false
        scrolledUnderElevation: 0,
        leading: fromBottomNav
            ? null  // Don't show back button if from bottom nav
            : IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          color: Colors.black,
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: GetBuilder<MyOrdersController>(
        init: MyOrdersController(),
        builder: (controller) {
          return Obx(
                () => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.orders.isEmpty
                ? const Center(child: Text('No orders found'))
                : ListView.builder(
              itemCount: controller.orders.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final order = controller.orders[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.blueGrey
                          : CustomTheme.loginGradientStart
                          .withOpacity(0.4),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () =>
                        controller.navigateToOrderPreview(order),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order id: ${order.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                DateFormat('dd MMM yyyy')
                                    .format(order.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Medicine: ${order.cart.map((item) => item.name).join(", ")}',
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Items: ${order.cart.length}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Status: ${order.orderStatus}',
                            style: TextStyle(
                              color: order.orderStatus == 'Delivered'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Amount: ${order.currencySign}${order.finalPrice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}