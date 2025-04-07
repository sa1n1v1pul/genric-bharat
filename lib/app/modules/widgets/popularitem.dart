import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

import '../../core/theme/theme.dart';
import '../api_endpoints/api_endpoints.dart';
import '../cart/controller/cartcontroller.dart';
import '../cart/view/cartscreen.dart';
import '../home/controller/homecontroller.dart';
import '../auth/controllers/auth_controller.dart';
import '../widgets/loginrequireddialog.dart';
import 'medicinedetailsheet.dart';

class PopularItemsScreen extends StatelessWidget {
  const PopularItemsScreen({Key? key}) : super(key: key);

  String getCompleteImageUrl(String photoPath) {
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    return '${ApiEndpoints.imageBaseUrl}$photoPath';
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final CartController cartController = Get.find<CartController>();
    final isDarkMode = Get.isDarkMode;
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FE),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.8),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            );
          },
        ),
        toolbarHeight: 70,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.8),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Popular Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    ' ✨',
                    style: TextStyle(
                      fontSize: 20,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background design elements
          Positioned.fill(
            child: isDarkMode
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A1A2E),
                          Color(0xFF16213E),
                        ],
                      ),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF8F9FE),
                          Color(0xFFEDF1FD),
                        ],
                      ),
                    ),
                  ),
          ),
          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomTheme.loginGradientStart.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomTheme.loginGradientEnd.withOpacity(0.1),
              ),
            ),
          ),

          // Content Area
          SafeArea(
            child: Obx(() {
              final demandProducts =
                  controller.getItemsForCategory("Demand Products");

              if (controller.isCategoryItemsLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: CustomTheme.loginGradientStart,
                  ),
                );
              }

              if (demandProducts.isEmpty) {
                return Center(
                  child: Text(
                    'No popular items available at the moment',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65 / textScaleFactor,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: demandProducts.length,
                itemBuilder: (context, index) {
                  final product = demandProducts[index];
                  final discount = product['previous_price'] != 0
                      ? ((product['previous_price'] -
                                  product['discount_price']) /
                              product['previous_price'] *
                              100)
                          .toStringAsFixed(0)
                      : '0';

                  return _buildPopularItemCard(
                    context,
                    product: product,
                    discount: discount,
                    isDarkMode: isDarkMode,
                    cartController: cartController,
                    textScaleFactor: textScaleFactor,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularItemCard(
    BuildContext context, {
    required Map<String, dynamic> product,
    required String discount,
    required bool isDarkMode,
    required CartController cartController,
    required double textScaleFactor,
  }) {
    final _authController = Get.find<AuthController>();
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withOpacity(0.2)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  minChildSize: 0.6,
                  maxChildSize: 0.8,
                  builder: (context, scrollController) => MedicineDetailsSheet(
                    service: product,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        getCompleteImageUrl(product['photo']),
                        height: 110 * textScaleFactor,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 110 * textScaleFactor,
                            color: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[300],
                            child: Icon(
                              Icons.error,
                              size: 24 * textScaleFactor,
                              color:
                                  isDarkMode ? Colors.white60 : Colors.black45,
                            ),
                          );
                        },
                      ),
                    ),
                    if (discount != '0')
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8 * textScaleFactor,
                            vertical: 4 * textScaleFactor,
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12 / textScaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            if (product['previous_price'] > 0) ...[
                              Text(
                                '₹${product['previous_price'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 4),
                            ],
                            Text(
                              '₹${product['discount_price'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.greenAccent
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CustomTheme.loginGradientStart,
                                CustomTheme.loginGradientEnd
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: CustomTheme.loginGradientStart
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!_authController.isLoggedIn.value) {
                                final shouldLogin =
                                    await LoginRequiredDialog.show(context);
                                if (shouldLogin) {
                                  // User chose to login
                                  return;
                                }
                                return;
                              }

                              if (!cartController.isLoading.value) {
                                await cartController.addToCart(product);
                                Get.to(() => const CartScreen());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart_outlined, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
