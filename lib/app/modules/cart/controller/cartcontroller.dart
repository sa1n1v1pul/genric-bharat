import 'package:get/get.dart';

class CartController extends GetxController {
  RxList<CartItem> cartItems = <CartItem>[].obs;
  RxDouble total = 0.0.obs;

  void addToCart(Map<String, dynamic> product) {
    // Convert ID to String to ensure type consistency
    final String productId = product['id'].toString();

    // Check if item already exists in cart
    final existingItemIndex = cartItems.indexWhere((item) => item.id == productId);

    if (existingItemIndex != -1) {
      // If item exists, increment quantity
      cartItems[existingItemIndex].quantity++;
      cartItems.refresh();
    } else {
      // If item doesn't exist, add new item
      cartItems.add(
        CartItem(
          id: productId,
          name: product['name'] ?? '',
          price: _parseDouble(product['discount_price']),
          image: product['photo'] ?? '',
          quantity: 1,
        ),
      );
    }
    _updateTotal();
  }

  // Helper method to safely parse double values
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  void removeFromCart(String id) {
    cartItems.removeWhere((item) => item.id == id);
    _updateTotal();
  }

  void incrementQuantity(String id) {
    final item = cartItems.firstWhere((item) => item.id == id);
    item.quantity++;
    cartItems.refresh();
    _updateTotal();
  }

  void decrementQuantity(String id) {
    final item = cartItems.firstWhere((item) => item.id == id);
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
    } else {
      removeFromCart(id);
    }
    _updateTotal();
  }

  void _updateTotal() {
    total.value = cartItems.fold(
      0,
          (sum, item) => sum + (item.price * item.quantity),
    );
  }

  void clearCart() {
    cartItems.clear();
    _updateTotal();
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });
}