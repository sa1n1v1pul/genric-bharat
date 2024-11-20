import 'package:genric_bharat/app/modules/cart/controller/cartservice.dart';
import 'package:get/get.dart';


import '../../api_endpoints/api_provider.dart';
import '../../home/views/addressview.dart';
import '../../routes/app_routes.dart';

class CartController extends GetxController {
  final CartApiService _apiService = Get.find<CartApiService>();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  RxList<CartItem> cartItems = <CartItem>[].obs;
  RxDouble total = 0.0.obs;
  RxInt cartCount = 0.obs;
  RxBool isLoading = false.obs;
  RxBool hasAddress = false.obs;

  @override
  void onInit() async {
    super.onInit();
    print('🚀 CartController initialized');


  }

  Future<void> initializeCart() async {
    try {
      final userId = await _apiService.getUserId();
      if (userId != null) {
        await fetchCart();
        await checkAddressFromProfile(userId);
      } else {
        print('❌ User ID is null during initialization');
      }
    } catch (e) {
      print('❌ Error initializing cart: $e');
    }
  }

  Future<void> checkAddressFromProfile(int userId) async {
    try {
      print('📍 Checking address from profile for user: $userId');
      final response = await _apiProvider.getUserProfile(userId);

      if (response.data != null) {
        final userData = response.data;
        // Check if essential address fields are present
        hasAddress.value = _isValidAddress(userData);
        print('🏠 Has valid address: ${hasAddress.value}');
      }
    } catch (e) {
      print('❌ Error checking address from profile: $e');
      hasAddress.value = false;
    }
  }

  bool _isValidAddress(dynamic userData) {
    return userData['ship_address1'] != null &&
        userData['ship_address1'].toString().isNotEmpty &&
        userData['ship_city'] != null &&
        userData['ship_city'].toString().isNotEmpty &&
        userData['ship_zip'] != null &&
        userData['ship_zip'].toString().isNotEmpty &&
        userData['state'] != null &&
        userData['state'].toString().isNotEmpty;
  }

  Future<void> proceedToCheckout() async {
    if (!hasAddress.value) {
      Get.to(() => AddressScreen());
      return;
    }

    Get.toNamed(Routes.DELIVERY);
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
        final cartData = response['data']['items'] as List;
        print('🛒 Cart data type: ${cartData.runtimeType}');

        cartItems.clear();

        if (cartData.isNotEmpty) {
          cartItems.addAll(cartData.map((item) => _createCartItem(item as Map<String, dynamic>)));
        }

        total.value = double.parse(response['data']['total_amount'].toString());
        cartCount.value = response['data']['total_items'] ?? 0;
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

      // Find the cart item to get its item_id
      final cartItem = cartItems.firstWhere((item) => item.id == itemId);

      final response = await _apiService.addToCart(cartItem.itemId, quantity);
      print('📦 Update quantity response: $response');

      if (response['status'] == true) {
        await fetchCart(); // Refresh cart to get updated data
        print('✅ Quantity updated successfully');
      } else {
        print('❌ Failed to update quantity: ${response['message']}');
        Get.snackbar('Error', response['message'] ?? 'Failed to update quantity');
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
      print('🔼 Incrementing quantity for item $id from ${item.quantity} to $newQuantity');
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
        print('🔽 Decrementing quantity for item $id from ${item.quantity} to $newQuantity');
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
      itemId: item['item_id']?.toString() ?? '',
      name: item['name'] ?? '',
      price: _parseDouble(item['unit_price']),
      image: item['photo'] ?? '',
      quantity: int.parse(item['qty']?.toString() ?? '1'),
    );
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
      print('🗑️ Removing specific item from cart: $id');
      isLoading.value = true;

      final response = await _apiService.clearCartItem(id);

      if (response['status'] == true) {
        // Don't remove from cartItems here since we already removed it in confirmDismiss
        total.value = double.parse(response['data']['total_amount'].toString());
        cartCount.value = response['data']['total_items'] ?? 0;
        Get.snackbar('Success', 'Item removed from cart');
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to remove item from cart');
        await fetchCart(); // Refresh the cart if the API call failed
      }
    } catch (e) {
      print('❌ Error removing item from cart: $e');
      Get.snackbar('Error', 'Failed to remove item from cart');
      await fetchCart(); // Refresh the cart if there was an error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearAllCart() async {
    try {
      print('🗑️ Clearing entire cart');
      isLoading.value = true;

      final response = await _apiService.clearAllCart();

      if (response['status'] == true) {
        cartItems.clear();
        total.value = 0.0;
        cartCount.value = 0;
        Get.snackbar('Success', 'Cart cleared successfully');
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to clear cart');
        await fetchCart();
      }
    } catch (e) {
      print('❌ Error clearing cart: $e');
      Get.snackbar('Error', 'Failed to clear cart');
      await fetchCart();
    } finally {
      isLoading.value = false;
    }
  }
}

class CartItem {
  final String id;
  final String itemId;
  final String name;
  final double price;
  final String image;
  final int quantity;

  CartItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });
}