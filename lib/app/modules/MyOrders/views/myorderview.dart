// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
//
// import '../../../core/theme/theme.dart';
// import '../controllers/myordercontroller.dart';
//
// class MyOrdersView extends GetView<MyOrdersController> {
//   const MyOrdersView({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Initialize controller if not already initialized
//     if (!Get.isRegistered<MyOrdersController>()) {
//       Get.put(MyOrdersController());
//     }
//     bool isDarkMode = Get.isDarkMode;
//     return Scaffold(
//       backgroundColor: CustomTheme.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
//         foregroundColor: isDarkMode ? Colors.white : Colors.black,
//         centerTitle: true,
//         scrolledUnderElevation: 0,
//         automaticallyImplyLeading: false,
//         toolbarHeight: 60,
//         title: const Text(
//           'My Orders',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: GetBuilder<MyOrdersController>(
//         init: MyOrdersController(),
//         builder: (controller) {
//           return Obx(
//                 () => controller.isLoading.value
//                 ? const Center(child: CircularProgressIndicator())
//                 : controller.orders.isEmpty
//                 ? const Center(child: Text('No orders found'))
//                 : ListView.builder(
//               itemCount: controller.orders.length,
//               padding: const EdgeInsets.all(16),
//               itemBuilder: (context, index) {
//                 final order = controller.orders[index];
//                 return Container(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).cardColor,
//                     border: Border.all(
//                       color: isDarkMode
//                           ? Colors.blueGrey
//                           : CustomTheme.loginGradientStart
//                           .withOpacity(0.4),
//                       width: 1.5,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   margin: const EdgeInsets.only(bottom: 16),
//                   child: InkWell(
//                     onTap: () => controller.navigateToOrderPreview(order),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Order id: ${order.id}',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               Text(
//                                 DateFormat('dd MMM yyyy')
//                                     .format(order.createdAt),
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Medicine: ${order.cart.map((item) => item.name).join(", ")}',
//                             style: const TextStyle(fontSize: 14),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Items: ${order.cart.length}',
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Status: ${order.orderStatus}',
//                             style: TextStyle(
//                               color: order.orderStatus == 'Delivered'
//                                   ? Colors.green
//                                   : Colors.orange,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Amount: ${order.currencySign}${order.finalPrice}',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../controllers/myordercontroller.dart';

class MyOrdersView extends GetView<MyOrdersController> {
  const MyOrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already initialized
    if (!Get.isRegistered<MyOrdersController>()) {
      Get.put(MyOrdersController());
    }
    bool isDarkMode = Get.isDarkMode;
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        centerTitle: true,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
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
                    color: Colors.white, // Keep inside color white
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.blueGrey
                          : CustomTheme.loginGradientStart
                          .withOpacity(0.4), // Outer border color
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => controller.navigateToOrderPreview(order),
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
