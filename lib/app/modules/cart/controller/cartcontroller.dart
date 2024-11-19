// cart_controller.dart
import 'package:genric_bharat/app/modules/cart/controller/cartservice.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final CartApiService _apiService = CartApiService();
  RxList<CartItem> cartItems = <CartItem>[].obs;
  RxDouble total = 0.0.obs;
  RxInt cartCount = 0.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🚀 CartController initialized');
    fetchCart();
  }

  Future<void> addToCart(Map<String, dynamic> service) async {
    try {
      print('📝 Starting addToCart for service: ${service['name']}');
      isLoading.value = true;

      final response = await _apiService.addToCart(
        service['id'].toString(),
        1,
      );
      print('📦 Add to cart response: $response');

      if (response['status'] == true) {
        await fetchCart(); // Refresh the entire cart to ensure sync
        Get.snackbar('Success', 'Item added to cart');
      } else {
        print('❌ Failed to add item: ${response['message']}');
        Get.snackbar(
            'Error', response['message'] ?? 'Failed to add item to cart');
      }
    } catch (e, stackTrace) {
      print('❌ Error in addToCart: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar('Error', 'Failed to add item to cart');
    } finally {
      isLoading.value = false;
      print('✅ addToCart completed');
    }
  }

  Future<void> fetchCart() async {
    try {
      print('📝 Starting fetchCart');
      isLoading.value = true;

      final response = await _apiService.getCart();
      print('📦 Received cart data: $response');

      if (response['status'] == true) {
        final cartData = response['data']['cart'];
        print('🛒 Cart data type: ${cartData.runtimeType}');

        cartItems.clear();

        if (cartData is Map<String, dynamic> && cartData.isNotEmpty) {
          cartItems.addAll(cartData.entries.map((entry) {
            final item = entry.value as Map<String, dynamic>;
            return _createCartItem(item);
          }).toList());
        } else if (cartData is List && cartData.isNotEmpty) {
          cartItems.addAll(cartData
              .map((item) => _createCartItem(item as Map<String, dynamic>)));
        }

        cartCount.value = response['data']['cart_count'] ?? 0;
        total.value = _calculateTotal();
        print('💰 Updated cart total: ${total.value}');
      }
    } catch (e, stackTrace) {
      print('❌ Error in fetchCart: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar('Error', 'Failed to fetch cart items');
    } finally {
      isLoading.value = false;
      print('✅ fetchCart completed');
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      print('🔄 Updating quantity - ItemID: $itemId, New Quantity: $quantity');
      isLoading.value = true;

      final response = await _apiService.addToCart(itemId, quantity);
      print('📦 Update quantity response: $response');

      if (response['status'] == true) {
        final cartData = response['data']['cart'] as Map<String, dynamic>;
        int itemIndex = cartItems.indexWhere((item) => item.id == itemId);
        if (itemIndex != -1) {
          final updatedItem = cartItems[itemIndex];
          cartItems[itemIndex] = CartItem(
            id: updatedItem.id,
            name: updatedItem.name,
            price: updatedItem.price,
            image: updatedItem.image,
            quantity: quantity,
          );
        }

        cartCount.value = response['data']['cart_count'] ?? 0;
        total.value = _calculateTotal();
        print('✅ Quantity updated successfully');
      } else {
        print('❌ Failed to update quantity: ${response['message']}');
        Get.snackbar(
            'Error', response['message'] ?? 'Failed to update quantity');
        await fetchCart();
      }
    } catch (e, stackTrace) {
      print('❌ Error updating quantity: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar('Error', 'Failed to update quantity');
      await fetchCart();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> incrementQuantity(String id) async {
    try {
      final item = cartItems.firstWhere((item) => item.id == id);
      final newQuantity = item.quantity + 1;
      print(
          '🔼 Incrementing quantity for item $id from ${item.quantity} to $newQuantity');

      int itemIndex = cartItems.indexWhere((item) => item.id == id);
      if (itemIndex != -1) {
        final updatedItem = cartItems[itemIndex];
        cartItems[itemIndex] = CartItem(
          id: updatedItem.id,
          name: updatedItem.name,
          price: updatedItem.price,
          image: updatedItem.image,
          quantity: newQuantity,
        );
        total.value = _calculateTotal();
      }

      await updateQuantity(id, newQuantity);
    } catch (e) {
      print('❌ Error in incrementQuantity: $e');
      await fetchCart();
    }
  }

  Future<void> decrementQuantity(String id) async {
    try {
      final item = cartItems.firstWhere((item) => item.id == id);
      if (item.quantity > 1) {
        final newQuantity = item.quantity - 1;
        print(
            '🔽 Decrementing quantity for item $id from ${item.quantity} to $newQuantity');

        int itemIndex = cartItems.indexWhere((item) => item.id == id);
        if (itemIndex != -1) {
          final updatedItem = cartItems[itemIndex];
          cartItems[itemIndex] = CartItem(
            id: updatedItem.id,
            name: updatedItem.name,
            price: updatedItem.price,
            image: updatedItem.image,
            quantity: newQuantity,
          );
          total.value = _calculateTotal();
        }

        await updateQuantity(id, newQuantity);
      } else {
        await removeFromCart(id);
      }
    } catch (e) {
      print('❌ Error in decrementQuantity: $e');
      await fetchCart();
    }
  }

  CartItem _createCartItem(Map<String, dynamic> item) {
    print('Creating cart item from: $item');
    return CartItem(
      id: item['id']?.toString() ?? '',
      name: item['name'] ?? '',
      price: _parseDouble(item['unit_price']),
      image: item['photo'] ?? '',
      quantity: int.parse(item['qty']?.toString() ?? '1'),
    );
  }

  double _calculateTotal() {
    final calculatedTotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    print('💰 Calculated total: $calculatedTotal');
    return calculatedTotal;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> removeFromCart(String id) async {
    try {
      print('🗑️ Removing item from cart: $id');
      isLoading.value = true;

      final removedItemIndex = cartItems.indexWhere((item) => item.id == id);
      if (removedItemIndex != -1) {
        final removedItem = cartItems[removedItemIndex];
        cartItems.removeAt(removedItemIndex);
        total.value = _calculateTotal();
        cartCount.value = cartItems.length;

        final response = await _apiService.clearCartItem(id);

        if (response['status'] == true) {
          Get.snackbar('Success', 'Item removed from cart');
        } else {
          cartItems.insert(removedItemIndex, removedItem);
          total.value = _calculateTotal();
          cartCount.value = cartItems.length;
          Get.snackbar('Error',
              response['message'] ?? 'Failed to remove item from cart');
        }
      }
    } catch (e) {
      print('❌ Error removing from cart: $e');
      Get.snackbar('Error', 'Failed to remove item from cart');
      await fetchCart();
    } finally {
      isLoading.value = false;
    }
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });
}
