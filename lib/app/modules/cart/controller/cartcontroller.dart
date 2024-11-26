import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:genric_bharat/app/modules/cart/controller/cartservice.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_endpoints/api_endpoints.dart';
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
  RxString appliedCouponCode = ''.obs;
  RxDouble discountAmount = 0.0.obs;
  RxList<PromoCode> availablePromoCodes = <PromoCode>[].obs;
  RxBool isLoadingCoupons = false.obs;
  RxBool isCouponValid = false.obs;
  RxString couponErrorMessage = ''.obs;
  RxBool isInitialized = false.obs;
  double get finalAmount => total.value - discountAmount.value;
  int? currentUserId;

  @override
  void onInit() async {
    super.onInit();
    print('🚀 CartController initialized');
    ever(isInitialized, (_) => print('Cart initialization status changed: $isInitialized'));

    // Listen to user ID changes
    ever(_apiService.userId, (userId) {
      if (userId != null) {
        print('👤 User ID changed in CartController: $userId');
        initializeCart(userId: userId);
      }
    });

    await fetchPromoCodes();
    checkAndInitializeCart();
  }
  Future<void> checkAndInitializeCart() async {
    try {
      // First check if we already have a userId from the service
      if (_apiService.userId.value != null) {
        currentUserId = _apiService.userId.value;
        print('✅ Using userId from service: ${currentUserId}');
        await initializeCart(userId: currentUserId!);
        return;
      }

      // If not, try to get it from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        currentUserId = userId;
        print('✅ Retrieved userId from SharedPreferences: $userId');
        await initializeCart(userId: userId);
      } else {
        print('⚠️ No userId found in SharedPreferences or service');
        // Clear cart data when no user is logged in
        cartItems.clear();
        total.value = 0.0;
        cartCount.value = 0;
      }
    } catch (e) {
      print('❌ Error in checkAndInitializeCart: $e');
    } finally {
      isInitialized.value = true;
    }
  }
  Future<void> initializeCart({int? userId}) async {
    try {
      if (userId != null) {
        currentUserId = userId;
        print('✅ Setting currentUserId to: $userId');
      }

      if (currentUserId == null) {
        print('❌ User ID is still null during initialization');
        return;
      }

      isLoading.value = true;
      await fetchCart();
      await checkAddressFromProfile(currentUserId!);

    } catch (e) {
      print('❌ Error initializing cart: $e');
    } finally {
      isLoading.value = false;
      isInitialized.value = true;
    }
  }
  Future<void> fetchPromoCodes() async {
    try {
      isLoadingCoupons.value = true;
      final response = await _apiProvider.get(ApiEndpoints.coupnecode);

      if (response.statusCode == 200) {
        final data = response.data;
        availablePromoCodes.value = (data['promo_codes'] as List)
            .map((code) => PromoCode.fromJson(code))
            .toList();
      }
    } catch (e) {
      print('Error fetching promo codes: $e');
    } finally {
      isLoadingCoupons.value = false;
    }
  }

  // Add method to apply coupon
  void applyCoupon(String code) {
    final promoCode = availablePromoCodes.firstWhereOrNull(
          (coupon) => coupon.codeName.toLowerCase() == code.toLowerCase(),
    );

    if (promoCode == null) {
      couponErrorMessage.value = 'Invalid coupon code';
      isCouponValid.value = false;
      discountAmount.value = 0.0;
      return;
    }

    if (total.value < 500) {
      couponErrorMessage.value = 'Minimum order amount should be ₹500';
      isCouponValid.value = false;
      discountAmount.value = 0.0;
      return;
    }

    isCouponValid.value = true;
    appliedCouponCode.value = promoCode.codeName;

    // Calculate discount
    if (promoCode.type == 'percentage') {
      discountAmount.value = (total.value * promoCode.discount / 100);
    } else {
      discountAmount.value = promoCode.discount;
    }
  }

  // Add method to remove coupon
  void removeCoupon() {
    appliedCouponCode.value = '';
    discountAmount.value = 0.0;
    isCouponValid.value = false;
    couponErrorMessage.value = '';
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
    try {
      if (total.value < 1) {
        Get.snackbar(
          'Error',
          'Minimum order amount should be ₹500',
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
        );
        return;
      }

      if (!hasAddress.value) {
        Get.to(() => AddressScreen());
        return;
      }

      // Pass order summary data through Get.arguments
      Get.toNamed(Routes.DELIVERY, arguments: getOrderSummary());
    } catch (e) {
      print('Error proceeding to checkout: $e');
      Get.snackbar(
        'Error',
        'Failed to proceed to checkout',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    }
  }

  Map<String, dynamic> getOrderSummary() {
    return {
      'subtotal': total.value,
      'discount': discountAmount.value,
      'finalAmount': finalAmount,
      'appliedCoupon': appliedCouponCode.value,
    };
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
  void refreshCart() {
    if (currentUserId != null) {
      fetchCart();
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

        // Clear and update cart items
        cartItems.clear();
        if (cartData.isNotEmpty) {
          cartItems.addAll(cartData.map((item) => _createCartItem(item as Map<String, dynamic>)));
        }
        print('📦 Cart items count after update: ${cartItems.length}');

        total.value = double.parse(response['data']['total_amount'].toString());
        cartCount.value = response['data']['total_items'] ?? 0;

        // Force UI update
        update();
      }
    } catch (e, stackTrace) {
      print('❌ Error in fetchCart: $e');
      print('Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
      print('✅ fetchCart completed');
    }
  }
  CartItem _createCartItem(Map<String, dynamic> item) {
    print('Creating cart item - Full item data: $item');

    // Check for nested 'item' key which seems present in your log
    final itemData = item['item'] ?? item;

    return CartItem(
      id: item['id']?.toString() ?? '',
      itemId: item['item_id']?.toString() ?? '',
      name: itemData['name'] ?? item['name'] ?? '',
      price: _parseDouble(itemData['discount_price'] ?? item['unit_price']),
      image: itemData['photo'] ?? item['photo'] ?? '',
      quantity: int.parse(item['qty']?.toString() ?? '1'),
    );
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

class PromoCode {
  final int id;
  final String codeName;
  final String title;
  final double discount;
  final String type;
  final bool status;

  PromoCode({
    required this.id,
    required this.codeName,
    required this.title,
    required this.discount,
    required this.type,
    required this.status,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'],
      codeName: json['code_name'],
      title: json['title'],
      discount: double.parse(json['discount'].toString()),
      type: json['type'],
      status: json['status'] == 1,
    );
  }
}