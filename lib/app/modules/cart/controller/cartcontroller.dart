// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, annotate_overrides

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:genric_bharat/app/modules/auth/controllers/auth_controller.dart';
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
  final AuthController _authController = Get.find<AuthController>();
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
  RxList<Address> userAddresses = <Address>[].obs;
  final Map<String, bool> _updatingQuantities = {};
  void onReady() {
    super.onReady();
    ever(cartItems, (_) {
      if (currentUserId != null) {
        fetchAddresses();
      }
    });
  }

  void resetCouponState() {
    appliedCouponCode.value = '';
    discountAmount.value = 0.0;
    isCouponValid.value = false;
    couponErrorMessage.value = '';
  }

  @override
  void onInit() async {
    super.onInit();

    ever(_authController.isLoggedIn, (isLoggedIn) {
      if (!isLoggedIn) {
        cartItems.clear();
        total.value = 0.0;
        cartCount.value = 0;
        currentUserId = null;
        hasAddress.value = false;
      }
    });

    ever(_apiService.userId, (userId) {
      if (userId != null) {
        currentUserId = userId;
        initializeCart(userId: userId);
      }
    });

    await fetchPromoCodes();
    checkAndInitializeCart();
  }

  Future<void> checkAndInitializeCart() async {
    try {
      if (_authController.isLoggedIn.value) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('user_id');
        if (userId != null) {
          currentUserId = userId;
          await initializeCart(userId: userId);
          return;
        }
      }

      if (_apiService.userId.value != null) {
        currentUserId = _apiService.userId.value;
        await initializeCart(userId: currentUserId!);
        return;
      }

      cartItems.clear();
      total.value = 0.0;
      cartCount.value = 0;
      currentUserId = null;
      hasAddress.value = false;
    } catch (e) {
    } finally {
      isInitialized.value = true;
    }
  }

  Future<void> initializeCart({int? userId}) async {
    try {
      if (userId != null) {
        currentUserId = userId;
      }

      if (currentUserId == null) {
        return;
      }

      isLoading.value = true;
      await fetchCart();
      await fetchAddresses();
    } catch (e) {
    } finally {
      isLoading.value = false;
      isInitialized.value = true;
    }
  }

  Future<void> fetchAddresses() async {
    try {
      if (currentUserId == null) {
        hasAddress.value = false;
        return;
      }

      final response = await _apiProvider
          .get(ApiEndpoints.getAddressesForUser(currentUserId!));

      if (response.statusCode == 200) {
        final List<dynamic> addressData = response.data['data'] ?? [];
        userAddresses.value = addressData
            .map((data) {
              try {
                return Address.fromJson(data);
              } catch (e) {
                return null;
              }
            })
            .whereType<Address>()
            .toList();

        hasAddress.value = userAddresses.isNotEmpty;
      } else {
        hasAddress.value = false;
      }
    } catch (e) {
      hasAddress.value = false;
    }
  }

  Future<void> refreshAddressStatus() async {
    await fetchAddresses();
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
    } finally {
      isLoadingCoupons.value = false;
    }
  }

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

    if (promoCode.type == 'percentage') {
      discountAmount.value = (total.value * promoCode.discount / 100);
    } else {
      discountAmount.value = promoCode.discount;
    }
  }

  void removeCoupon() {
    appliedCouponCode.value = '';
    discountAmount.value = 0.0;
    isCouponValid.value = false;
    couponErrorMessage.value = '';
  }

  Future<void> checkAddressFromProfile(int userId) async {
    try {
      final response = await _apiProvider.getUserProfile(userId);

      if (response.data != null) {
        final userData = response.data;
        hasAddress.value = _isValidAddress(userData);
      }
    } catch (e) {
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
      if (cartItems.isEmpty) {
        Get.snackbar(
          'Error',
          'Your cart is empty',
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
        );
        return;
      }

      if (total.value < 500) {
        Get.snackbar(
          'Error',
          'Minimum order amount should be ₹500',
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
        );
        return;
      }

      await fetchAddresses();

      if (!hasAddress.value) {
        final result = await Get.toNamed(Routes.ADDRESS);
        if (result == true) {
          await fetchAddresses();
        }
        return;
      }

      Get.toNamed(Routes.DELIVERY, arguments: getOrderSummary());
    } catch (e) {
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
      isLoading.value = true;

      int quantity = service['quantity'] != null ? service['quantity'] : 1;

      final response = await _apiService.addToCart(
        service['id'].toString(),
        quantity,
      );

      if (response['status'] == true) {
        await fetchCart();
        Get.snackbar('Success', 'Item added to cart');
      } else {
        Get.snackbar(
            'Error', response['message'] ?? 'Failed to add item to cart');
      }
    } catch (e, stackTrace) {
      Get.snackbar('Error', 'Failed to add item to cart');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshCart() {
    if (currentUserId != null) {
      fetchCart();
    }
  }

  Future<void> fetchCart() async {
    try {
      isLoading.value = true;

      final response = await _apiService.getCart();

      if (response['status'] == true) {
        final cartData = response['data']['items'] as List;

        cartItems.clear();
        if (cartData.isNotEmpty) {
          cartItems.addAll(cartData
              .map((item) => _createCartItem(item as Map<String, dynamic>)));
        } else {
          resetCouponState();
        }

        total.value = double.parse(response['data']['total_amount'].toString());
        cartCount.value = response['data']['total_items'] ?? 0;

        update();
      }
    } catch (e, stackTrace) {
    } finally {
      isLoading.value = false;
    }
  }

  CartItem _createCartItem(Map<String, dynamic> item) {
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
    if (_updatingQuantities[itemId] == true) return;

    try {
      _updatingQuantities[itemId] = true;

      final itemIndex = cartItems.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final item = cartItems[itemIndex];
        final updatedItem = CartItem(
          id: item.id,
          itemId: item.itemId,
          name: item.name,
          price: item.price,
          image: item.image,
          quantity: quantity,
        );

        cartItems[itemIndex] = updatedItem;

        _updateLocalTotal();
      }

      final cartItem = cartItems[itemIndex];

      final response = await _apiService.addToCart(cartItem.itemId, quantity);

      if (response['status'] != true) {
        Get.snackbar(
            'Error', response['message'] ?? 'Failed to update quantity');
        await fetchCart();
      }
    } catch (e, stackTrace) {
      Get.snackbar('Error', 'Failed to update quantity');
      await fetchCart();
    } finally {
      _updatingQuantities[itemId] = false;
    }
  }

  void _updateLocalTotal() {
    double newTotal = 0.0;
    for (var item in cartItems) {
      newTotal += item.price * item.quantity;
    }
    total.value = newTotal;
    cartCount.value = cartItems.length;
  }

  Future<void> incrementQuantity(String id) async {
    try {
      final itemIndex = cartItems.indexWhere((item) => item.id == id);
      if (itemIndex != -1) {
        final item = cartItems[itemIndex];
        final newQuantity = item.quantity + 1;
        await updateQuantity(id, newQuantity);
      }
    } catch (e) {}
  }

  Future<void> decrementQuantity(String id) async {
    try {
      final itemIndex = cartItems.indexWhere((item) => item.id == id);
      if (itemIndex != -1) {
        final item = cartItems[itemIndex];
        if (item.quantity > 1) {
          final newQuantity = item.quantity - 1;
          await updateQuantity(id, newQuantity);
        } else {
          await removeFromCart(id);
        }
      }
    } catch (e) {}
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
      isLoading.value = true;

      final response = await _apiService.clearCartItem(id);

      if (response['status'] == true) {
        total.value = double.parse(response['data']['total_amount'].toString());
        cartCount.value = response['data']['total_items'] ?? 0;
        Get.snackbar('Success', 'Item removed from cart');
      } else {
        Get.snackbar(
            'Error', response['message'] ?? 'Failed to remove item from cart');
        await fetchCart();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove item from cart');
      await fetchCart();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearAllCart() async {
    try {
      isLoading.value = true;

      final response = await _apiService.clearAllCart();

      if (response['status'] == true) {
        cartItems.clear();
        total.value = 0.0;
        cartCount.value = 0;
        resetCouponState();
        Get.snackbar('Success', 'Cart cleared successfully');
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to clear cart');
        await fetchCart();
      }
    } catch (e) {
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

class Address {
  final int id;
  final int userId;
  final String pinCode;
  final String shipAddress1;
  final String? shipAddress2;
  final String? area;
  final String? landmark;
  final String city;
  final String state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;

  Address({
    required this.id,
    required this.userId,
    required this.pinCode,
    required this.shipAddress1,
    this.shipAddress2,
    this.area,
    this.landmark,
    required this.city,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    try {
      return Address(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0,
        pinCode: json['pin_code']?.toString() ?? '',
        shipAddress1: json['ship_address1']?.toString() ?? '',
        shipAddress2: json['ship_address2']?.toString(),
        area: json['area']?.toString(),
        landmark: json['landmark']?.toString(),
        city: json['city']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        createdAt: DateTime.parse(
            json['created_at'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(
            json['updated_at'] ?? DateTime.now().toIso8601String()),
        user: User.fromJson(json['user'] ?? {}),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class User {
  final int id;
  final String fullname;
  final String mobileNumber;
  final String email;

  User({
    required this.id,
    required this.fullname,
    required this.mobileNumber,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      fullname: json['fullname']?.toString() ?? '',
      mobileNumber: json['mobile_number']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}
