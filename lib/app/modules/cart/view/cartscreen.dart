import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../../api_endpoints/api_endpoints.dart';
import '../controller/cartcontroller.dart';

class CartScreen extends GetView<CartController> {
  final bool fromBottomNav;

  const CartScreen({
    Key? key,
    this.fromBottomNav = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: fromBottomNav ? CustomTheme.backgroundColor : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        centerTitle: true,
        scrolledUnderElevation: 0,
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
          Obx(() => controller.cartItems.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.delete_outline),
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
            () => controller.cartItems.isEmpty
            ? _buildEmptyCart()
            : _buildCartContent(),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to clear all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.clearAllCart();
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
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
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(
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
                key: UniqueKey(), // Use UniqueKey instead of item.id to ensure unique keys
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
                        title: const Text('Remove Item'),
                        content: Text(
                            'Are you sure you want to remove ${item.name} from your cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Remove',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (result == true) {
                    // Remove item from local list first
                    controller.cartItems.removeAt(index);
                    // Then call API to remove from backend
                    await controller.removeFromCart(item.id);
                  }

                  return false; // Always return false to let us handle the dismissal
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
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
                    '₹${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        if (item.quantity > 1) {
                          controller.decrementQuantity(item.id);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.remove,
                          size: 20,
                          color: item.quantity > 1 ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => controller.incrementQuantity(item.id),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.add,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(fontSize: 16),
              ),
              Obx(
                    () => Text(
                  '₹${controller.total.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _getButtonAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonColor(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _getButtonText(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: controller.cartItems.isEmpty ? Colors.grey[600] : Colors.white,
                ),
              ),
            ),
          )),
          if (controller.cartItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            Obx(() => Text(
              _getHelperText(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )),
          ],
        ],
      ),
    );
  }


  VoidCallback? _getButtonAction() {
    if (controller.cartItems.isEmpty) return null;
    return () => controller.proceedToCheckout();
  }

  Color _getButtonColor() {
    if (controller.cartItems.isEmpty) {
      return Colors.grey[300]!;
    }
    return CustomTheme.loginGradientStart;
  }

  String _getButtonText() {
    if (controller.cartItems.isEmpty) {
      return 'Cart is Empty';
    }
    return controller.hasAddress.value
        ? 'Proceed to Checkout'
        : 'Add Delivery Address';
  }

  String _getHelperText() {
    if (controller.hasAddress.value) {
      return 'Inclusive of all taxes';
    }
    return 'Please add delivery address to continue';
  }
}