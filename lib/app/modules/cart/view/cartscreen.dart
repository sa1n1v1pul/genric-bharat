import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../api_endpoints/api_endpoints.dart';
import '../../routes/app_routes.dart';
import '../controller/cartcontroller.dart';

class CartScreen extends GetView<CartController> {
  final bool fromBottomNav;

  const CartScreen({
    Key? key,
    this.fromBottomNav = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!fromBottomNav) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchAddresses();
      });
    }

    if (fromBottomNav) {
      Get.find<CartController>().checkAndInitializeCart();
    }
    bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor:
      fromBottomNav ? CustomTheme.backgroundColor : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        centerTitle: true,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: !fromBottomNav,
        leading: !fromBottomNav
            ? Container(
          padding: const EdgeInsets.only(left: 4),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? Colors.black : Colors.white)
                    .withOpacity(0.3),
                spreadRadius: 5,
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
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
          ),
        )
            : null,
        actions: [
          Obx(() =>
          controller.cartItems.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.delete_outline,color: Colors.red,),
            onPressed: () => _showClearCartDialog(context),
          )
              : const SizedBox()),
        ],
        iconTheme: IconThemeData(
          color: isDarkMode
              ? const Color.fromARGB(255, 244, 243, 248)
              : Colors.black,
        ),
        toolbarHeight: 60,
        title: const Text(
          'Cart',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!controller.isInitialized.value || controller.currentUserId == null) {
          return _buildLoadingState();
        }

        if (controller.cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        return _buildCartContent();
      }),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart', style: TextStyle(fontSize: 16)),
          content: const Text(
              'Are you sure you want to clear all items from your cart?',
              style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(fontSize: 14)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.clearAllCart();
              },
              child: const Text('Clear',
                  style: TextStyle(color: Colors.red, fontSize: 14)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Loading data...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '⏳ Please wait',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.cartItems.length,
            itemBuilder: (context, index) {
              final item = controller.cartItems[index];
              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Remove Item',
                            style: TextStyle(fontSize: 16)),
                        content: Text(
                            'Are you sure you want to remove ${item.name} from your cart?',
                            style: const TextStyle(fontSize: 14)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel',
                                style: TextStyle(fontSize: 14)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Remove',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (result == true) {
                    controller.cartItems.removeAt(index);
                    await controller.removeFromCart(item.id);
                  }

                  return false;
                },
                child: _buildCartItemCard(item),
              );
            },
          ),
        ),
        _buildCartSummary(),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${ApiEndpoints.imageBaseUrl}${item.image}',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: CustomTheme.loginGradientStart,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            _buildQuantityControls(item),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onTap: () {
              if (item.quantity > 1) {
                controller.decrementQuantity(item.id);
              }
            },
            isEnabled: item.quantity > 1,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onTap: () => controller.incrementQuantity(item.id),
            isEnabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isEnabled ? Colors.white : Colors.grey[200],
        boxShadow: isEnabled
            ? [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: isEnabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled ? CustomTheme.loginGradientStart : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.cartItems.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Obx(() => controller.appliedCouponCode.isEmpty
                      ? OutlinedButton.icon(
                    icon: const Icon(Icons.local_offer_outlined, size: 16),
                    label: const Text('Apply Coupon',
                        style: TextStyle(fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => _showCouponsDialog(),
                  )
                      : Chip(
                    label: Text(
                      'Applied Coupon: ${controller.appliedCouponCode.value}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16, color: Colors.red,),
                    onDeleted: () => controller.removeCoupon(),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          _buildSummaryRow('Subtotal:', controller.total.value),
          if (controller.discountAmount.value > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Discount (${controller.appliedCouponCode.value}):',
              -controller.discountAmount.value,
              isDiscount: true,
            ),
          ],
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() =>
                    Text(
                      '₹${(controller.total.value -
                          controller.discountAmount.value).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [
                              CustomTheme.loginGradientStart,
                              CustomTheme.loginGradientStart.withBlue(255),
                            ],
                          ).createShader(
                              const Rect.fromLTWH(0.0, 0.0, 100.0, 30.0)),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Proceed Button
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _getButtonAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonColor(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _getButtonText(),
                style: TextStyle(
                  fontSize: 16,
                  color: controller.cartItems.isEmpty ? Colors.grey[600] : Colors.white,
                ),
              ),
            ),
          )),
          if (controller.cartItems.isNotEmpty) ...[
            const SizedBox(height: 6),
            Obx(() => Text(
                  _getHelperText(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDiscount ? Colors.green : Colors.grey[800],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              color: isDiscount ? Colors.green : Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCouponsDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Coupons',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => controller.isLoadingCoupons.value
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                shrinkWrap: true,
                itemCount: controller.availablePromoCodes.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final promoCode = controller.availablePromoCodes[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      promoCode.codeName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${promoCode.discount}${promoCode.type == 'percentage' ? '%' : '₹'} off',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        controller.applyCoupon(promoCode.codeName);
                        Get.back();
                      },
                      child: const Text('Apply'),
                    ),
                  );
                },
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getButtonText() {
    if (controller.cartItems.isEmpty) {
      return 'Cart is Empty';
    }
    return controller.hasAddress.value ? 'Proceed to Checkout' : 'Add Delivery Address';
  }
  Color _getButtonColor() {
    if (controller.cartItems.isEmpty) {
      return Colors.grey[300]!;
    }
    return CustomTheme.loginGradientStart;
  }
  String _getHelperText() {
    if (controller.hasAddress.value) {
      return 'Inclusive of all taxes';
    }
    return 'Please add delivery address to continue';
  }
  VoidCallback? _getButtonAction() {
    if (controller.cartItems.isEmpty) {
      return null;
    }


    return () {
      if (controller.hasAddress.value) {

        controller.proceedToCheckout();
      } else {

        Get.toNamed(Routes.ADDRESS);
      }};}}




