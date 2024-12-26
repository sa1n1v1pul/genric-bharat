// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../api_endpoints/api_endpoints.dart';
// import '../../cart/view/invoicescreen.dart';
// import '../views/previewscreen.dart';

// class MyOrdersController extends GetxController {
//   final Dio _dio = Dio();
//   final RxList<OrderModel> orders = <OrderModel>[].obs;
//   final RxBool isLoading = false.obs;
//   final RxBool hasError = false.obs;
//   final RxString errorMessage = ''.obs;
//   @override
//   void onInit() {
//     super.onInit();
//     fetchOrders();
//   }

//   Future<void> fetchOrders() async {
//     try {
//       isLoading.value = true;
//       hasError.value = false;
//       errorMessage.value = '';

//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       dynamic userId = prefs.getInt('user_id') ?? prefs.getString('user_id');

//       if (userId == null) {
//         hasError.value = true;
//         errorMessage.value = 'Please login to view your orders';
//         return;
//       }

//       final response = await _dio.get('${ApiEndpoints.apibaseUrl}orders-get',
//           queryParameters: {'user_id': userId},
//           options: Options(
//               validateStatus: (status) => status != null && status < 500));

//       if (response.statusCode == 200) {
//         final responseData = response.data;
//         if (responseData['status'] == 'success') {
//           if (responseData['data'] is! List) {
//             hasError.value = true;
//             errorMessage.value = 'No orders found';
//             return;
//           }

//           orders.value = (responseData['data'] as List)
//               .map((order) => OrderModel.fromJson(order))
//               .toList();
//         } else {
//           hasError.value = true;
//           errorMessage.value = 'No orders found';
//         }
//       } else if (response.statusCode == 404) {
//         // Handle 404 specifically for no orders
//         hasError.value = true;
//         errorMessage.value =
//             'No orders found yet!\nStart shopping to see your orders here.';
//       } else {
//         hasError.value = true;
//         errorMessage.value = 'Unable to fetch orders. Please try again later.';
//       }
//     } on DioException catch (e) {
//       hasError.value = true;
//       if (e.type == DioExceptionType.connectionTimeout ||
//           e.type == DioExceptionType.receiveTimeout) {
//         errorMessage.value =
//             'Connection timeout. Please check your internet connection.';
//       } else {
//         errorMessage.value =
//             'Unable to connect. Please check your internet connection.';
//       }
//     } catch (e) {
//       hasError.value = true;
//       errorMessage.value = 'Something went wrong. Please try again later.';
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void navigateToOrderPreview(OrderModel order) {
//     try {
//       // Convert OrderModel to the format expected by OrderPreviewScreen
//       Map<String, dynamic> orderData = {
//         'id': order.id,
//         'user_id': order.userId,
//         'cart': {
//           'items': order.cart
//               .map((item) => {
//                     'name': item.name,
//                     'rs': item.price,
//                     'quantity': item.quantity
//                   })
//               .toList()
//         },
//         'currency_sign': order.currencySign,
//         'discount': order.discount,
//         'coupon_applied': order.couponApplied,
//         'shipping': {
//           'address': order.shippingAddress,
//           'area': order.shippingArea,
//           'city': order.shippingCity,
//           'state': order.shippingState,
//           'pincode': order.shippingPincode
//         },
//         'payment_method': order.paymentMethod,
//         'txnid': order.txnid,
//         'order_status': order.orderStatus,
//         'shipping_info': {
//           'name': order.shippingInfoName,
//           'address': order.shippingInfoAddress,
//           'city': order.shippingInfoCity,
//           'state': order.shippingInfoState,
//           'pincode': order.shippingInfoPincode
//         },
//         'billing_info': {
//           'bill_first_name': order.billingFirstName,
//           'bill_address1': order.billingAddress1,
//           'bill_city': order.billingCity,
//           'bill_country': order.billingCountry,
//           'bill_zip': order.billingZip
//         },
//         'payment_status': order.paymentStatus,
//         'final_price': order.finalPrice,
//         'created_at': order.createdAt.toIso8601String()
//       };

//       // Navigate to the OrderPreviewScreen
//       Get.to(() => OrderPreviewScreen(orderData: orderData));
//     } catch (e) {
//       print('Error navigating to order preview: $e');
//       Get.snackbar(
//         'Error',
//         'Unable to open order preview. Please try again.',
//         backgroundColor: Colors.red[100],
//         colorText: Colors.black,
//       );
//     }
//   }
// }

// class OrderModel {
//   final int id;
//   final int userId;
//   final List<CartItemModel> cart;
//   final String currencySign;
//   final String currencyValue;
//   final String discount;
//   final String? couponApplied;
//   final String paymentMethod;
//   final String txnid;
//   final String transactionNumber;
//   final String orderStatus;
//   final String tax;
//   final String? chargeId;
//   final String paymentStatus;
//   final String finalPrice;
//   final String state;
//   final DateTime createdAt;
//   final DateTime? updatedAt;

//   // Shipping Details
//   final String shippingAddress;
//   final String shippingArea;
//   final String shippingCity;
//   final String shippingState;
//   final String shippingPincode;

//   // Shipping Info
//   final String shippingInfoName;
//   final String shippingInfoAddress;
//   final String shippingInfoCity;
//   final String shippingInfoState;
//   final String shippingInfoPincode;

//   // Billing Details
//   final String? billingToken;
//   final String billingFirstName;
//   final String billingLastName;
//   final String billingEmail;
//   final String billingPhone;
//   final String billingCompany;
//   final String billingAddress1;
//   final String billingAddress2;
//   final String billingZip;
//   final String billingCity;
//   final String billingCountry;
//   final String sameShipAddress;

//   // Computed getters for compatibility
//   String get shippingName => shippingInfoName;
//   String get billingName =>
//       billingFirstName +
//       (billingLastName.isNotEmpty ? ' $billingLastName' : '');
//   String get billingAddress => billingAddress1;
//   String get billingState => billingCountry;
//   String get billingPincode => billingZip;

//   OrderModel({
//     required this.id,
//     required this.userId,
//     required this.cart,
//     required this.currencySign,
//     required this.currencyValue,
//     required this.discount,
//     this.couponApplied,
//     required this.paymentMethod,
//     required this.txnid,
//     required this.transactionNumber,
//     required this.orderStatus,
//     required this.tax,
//     this.chargeId,
//     required this.paymentStatus,
//     required this.finalPrice,
//     required this.state,
//     required this.createdAt,
//     this.updatedAt,
//     required this.shippingAddress,
//     required this.shippingArea,
//     required this.shippingCity,
//     required this.shippingState,
//     required this.shippingPincode,
//     required this.shippingInfoName,
//     required this.shippingInfoAddress,
//     required this.shippingInfoCity,
//     required this.shippingInfoState,
//     required this.shippingInfoPincode,
//     this.billingToken,
//     required this.billingFirstName,
//     this.billingLastName = '',
//     this.billingEmail = '',
//     this.billingPhone = '',
//     this.billingCompany = '',
//     required this.billingAddress1,
//     this.billingAddress2 = '',
//     required this.billingZip,
//     required this.billingCity,
//     required this.billingCountry,
//     required this.sameShipAddress,
//   });

//   factory OrderModel.fromJson(Map<String, dynamic> json) {
//     return OrderModel(
//       id: json['id'] ?? 0,
//       userId: _parseUserId(json['user_id']),
//       cart: _parseCartItems(json['cart']),
//       currencySign: json['currency_sign'] ?? '₹',
//       currencyValue: json['currency_value'] ?? '0.00',
//       discount: json['discount'] ?? '0.00',
//       couponApplied: json['coupon_applied'],
//       paymentMethod: json['payment_method'] ?? '',
//       txnid: json['txnid'] ?? '',
//       transactionNumber: json['transaction_number'] ?? '',
//       orderStatus: json['order_status'] ?? '',
//       tax: json['tax']?.toString() ?? '0',
//       chargeId: json['charge_id'],
//       paymentStatus: json['payment_status'] ?? '',
//       finalPrice: json['final_price'] ?? '0.00',
//       state: json['state'] ?? '',
//       createdAt: _parseDateTime(json['created_at']),
//       updatedAt: _parseDateTime(json['updated_at']),

//       // Shipping Details
//       shippingAddress: json['shipping']?['address'] ?? '',
//       shippingArea: json['shipping']?['area'] ?? '',
//       shippingCity: json['shipping']?['city'] ?? '',
//       shippingState: json['shipping']?['state'] ?? '',
//       shippingPincode: json['shipping']?['pincode'] ?? '',

//       // Shipping Info
//       shippingInfoName: json['shipping_info']?['name'] ?? '',
//       shippingInfoAddress: json['shipping_info']?['address'] ?? '',
//       shippingInfoCity: json['shipping_info']?['city'] ?? '',
//       shippingInfoState: json['shipping_info']?['state'] ?? '',
//       shippingInfoPincode: json['shipping_info']?['pincode'] ?? '',

//       // Billing Details
//       billingToken: json['billing_info']?['_token'],
//       billingFirstName: json['billing_info']?['bill_first_name'] ?? '',
//       billingLastName: json['billing_info']?['bill_last_name'] ?? '',
//       billingEmail: json['billing_info']?['bill_email'] ?? '',
//       billingPhone: json['billing_info']?['bill_phone'] ?? '',
//       billingCompany: json['billing_info']?['bill_company'] ?? '',
//       billingAddress1: json['billing_info']?['bill_address1'] ?? '',
//       billingAddress2: json['billing_info']?['bill_address2'] ?? '',
//       billingZip: json['billing_info']?['bill_zip'] ?? '',
//       billingCity: json['billing_info']?['bill_city'] ?? '',
//       billingCountry: json['billing_info']?['bill_country'] ?? '',
//       sameShipAddress: json['billing_info']?['same_ship_address'] ?? 'off',
//     );
//   }

//   // Helper methods for parsing
//   static int _parseUserId(dynamic userId) {
//     if (userId is int) return userId;
//     if (userId is String) return int.tryParse(userId) ?? 0;
//     return 0;
//   }

//   static List<CartItemModel> _parseCartItems(dynamic cartData) {
//     if (cartData is List) {
//       return cartData.map((item) => CartItemModel.fromJson(item)).toList();
//     }
//     return [];
//   }

//   static DateTime _parseDateTime(String? dateTimeString) {
//     try {
//       return dateTimeString != null
//           ? DateTime.parse(dateTimeString)
//           : DateTime.now();
//     } catch (e) {
//       print('Error parsing datetime: $e');
//       return DateTime.now();
//     }
//   }
// }

// class CartItemModel {
//   final String name;
//   final String quantity;
//   final String qty;
//   final String price;

//   CartItemModel({
//     required this.name,
//     required this.quantity,
//     required this.qty,
//     required this.price,
//   });

//   factory CartItemModel.fromJson(Map<String, dynamic> json) {
//     return CartItemModel(
//       name: json['name'] ?? '',
//       quantity: json['quantity']?.toString() ?? '',
//       qty: json['qty']?.toString() ?? '',
//       price: json['rs'] ?? '0.00',
//     );
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api_endpoints/api_endpoints.dart';
import '../views/previewscreen.dart';

class MyOrdersController extends GetxController {
  final Dio _dio = Dio();
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      dynamic userId = prefs.getInt('user_id') ?? prefs.getString('user_id');

      if (userId == null) {
        hasError.value = true;
        errorMessage.value = 'Please login to view your orders';
        return;
      }

      final response = await _dio.get(
        '${ApiEndpoints.apibaseUrl}combined-orders',
        queryParameters: {'user_id': userId},
        options:
            Options(validateStatus: (status) => status != null && status < 500),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 'success') {
          final ordersData = responseData['data']['orders'];
          if (ordersData is! List) {
            hasError.value = true;
            errorMessage.value = 'No orders found';
            return;
          }

          orders.value =
              ordersData.map((order) => OrderModel.fromJson(order)).toList();

          // Sort orders by creation date (newest first)
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          hasError.value = true;
          errorMessage.value = responseData['message'] ?? 'No orders found';
        }
      } else {
        hasError.value = true;
        errorMessage.value = 'Unable to fetch orders. Please try again later.';
      }
    } on DioException catch (e) {
      hasError.value = true;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage.value =
            'Connection timeout. Please check your internet connection.';
      } else {
        errorMessage.value =
            'Unable to connect. Please check your internet connection.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again later.';
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToOrderPreview(OrderModel order) {
    try {
      Map<String, dynamic> orderData = {
        'id': order.id,
        'user_id': order.userId,
        'cart': order.cart
            .map((item) => {
                  'name': item.name,
                  'rs': item.price,
                  'quantity': item.quantity
                })
            .toList(),
        'currency_sign': order.currencySign,
        'discount': order.discount,
        'coupon_applied': order.couponApplied,
        'shipping': {
          'address': order.shippingAddress,
          'area': order.shippingArea,
          'city': order.shippingCity,
          'state': order.shippingState,
          'pincode': order.shippingPincode
        },
        'payment_method': order.paymentMethod,
        'txnid': order.txnid,
        'transaction_number': order.transactionNumber,
        'order_status': order.orderStatus,
        'shipping_info': {
          'name': order.shippingInfoName,
          'address': order.shippingInfoAddress,
          'city': order.shippingInfoCity,
          'state': order.shippingInfoState,
          'pincode': order.shippingInfoPincode
        },
        'billing_info': {
          'bill_first_name': order.billingFirstName,
          'bill_address1': order.billingAddress1,
          'bill_city': order.billingCity,
          'bill_country': order.billingCountry,
          'bill_zip': order.billingZip
        },
        'payment_status': order.paymentStatus,
        'final_price': order.finalPrice,
        'created_at': order.createdAt.toIso8601String(),
        'order_source': order.orderSource, // Add order source
      };

      Get.to(() => OrderPreviewScreen(orderData: orderData));
    } catch (e) {
      print('Error navigating to order preview: $e');
      Get.snackbar(
        'Error',
        'Unable to open order preview. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    }
  }
}

class OrderModel {
  final int id;
  final int userId;
  final List<CartItemModel> cart;
  final String currencySign;
  final String currencyValue;
  final String discount;
  final String? couponApplied;
  final String paymentMethod;
  final String txnid;
  final String transactionNumber;
  final String orderStatus;
  final String tax;
  final String? chargeId;
  final String paymentStatus;
  final String finalPrice;
  final String state;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String orderSource; // Add order source field

  // Shipping Details
  final String shippingAddress;
  final String shippingArea;
  final String shippingCity;
  final String shippingState;
  final String shippingPincode;

  // Shipping Info
  final String shippingInfoName;
  final String shippingInfoAddress;
  final String shippingInfoCity;
  final String shippingInfoState;
  final String shippingInfoPincode;

  // Billing Details
  final String? billingToken;
  final String billingFirstName;
  final String billingLastName;
  final String billingEmail;
  final String billingPhone;
  final String billingCompany;
  final String billingAddress1;
  final String billingAddress2;
  final String billingZip;
  final String billingCity;
  final String billingCountry;
  final String sameShipAddress;

  String get shippingName => shippingInfoName;
  String get billingName =>
      billingFirstName +
      (billingLastName.isNotEmpty ? ' $billingLastName' : '');
  String get billingAddress => billingAddress1;
  String get billingState => billingCountry;
  String get billingPincode => billingZip;

  OrderModel({
    required this.id,
    required this.userId,
    required this.cart,
    required this.currencySign,
    required this.currencyValue,
    required this.discount,
    this.couponApplied,
    required this.paymentMethod,
    required this.txnid,
    required this.transactionNumber,
    required this.orderStatus,
    required this.tax,
    this.chargeId,
    required this.paymentStatus,
    required this.finalPrice,
    required this.state,
    required this.createdAt,
    this.updatedAt,
    required this.shippingAddress,
    required this.shippingArea,
    required this.shippingCity,
    required this.shippingState,
    required this.shippingPincode,
    required this.shippingInfoName,
    required this.shippingInfoAddress,
    required this.shippingInfoCity,
    required this.shippingInfoState,
    required this.shippingInfoPincode,
    this.billingToken,
    required this.billingFirstName,
    this.billingLastName = '',
    this.billingEmail = '',
    this.billingPhone = '',
    this.billingCompany = '',
    required this.billingAddress1,
    this.billingAddress2 = '',
    required this.billingZip,
    required this.billingCity,
    required this.billingCountry,
    required this.sameShipAddress,
    required this.orderSource,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse shipping details first
    final shippingDetails = _parseShippingDetails(json);
    final finalPrice = _calculateFinalPrice(json);

    return OrderModel(
      id: json['id'] ?? 0,
      userId: _parseUserId(json['user_id']),
      cart: _parseCartItems(json['cart']),
      currencySign: json['currency_sign'] ?? '₹',
      currencyValue: json['currency_value'] ?? '0.00',
      discount: json['discount']?.toString() ?? '0.00',
      couponApplied: json['coupon_applied'],
      paymentMethod: json['payment_method'] ?? '',
      txnid: json['txnid'] ?? '',
      transactionNumber: json['transaction_number'] ?? '',
      orderStatus: json['order_status'] ?? '',
      tax: json['tax']?.toString() ?? '0',
      chargeId: json['charge_id'],
      paymentStatus: json['payment_status'] ?? '',
      finalPrice: finalPrice,
      state: json['state'] ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      orderSource: json['order_source'] ?? '',

      // Shipping Details from parsed data
      shippingAddress: shippingDetails.address,
      shippingArea: shippingDetails.area,
      shippingCity: shippingDetails.city,
      shippingState: shippingDetails.state,
      shippingPincode: shippingDetails.pincode,

      // Shipping Info from parsed data
      shippingInfoName: shippingDetails.name,
      shippingInfoAddress: shippingDetails.address,
      shippingInfoCity: shippingDetails.city,
      shippingInfoState: shippingDetails.state,
      shippingInfoPincode: shippingDetails.pincode,

      // Billing Details
      billingToken: json['billing_info']?['_token'],
      billingFirstName: json['billing_info']?['bill_first_name'] ?? '',
      billingLastName: json['billing_info']?['bill_last_name'] ?? '',
      billingEmail: json['billing_info']?['bill_email'] ?? '',
      billingPhone: json['billing_info']?['bill_phone'] ?? '',
      billingCompany: json['billing_info']?['bill_company'] ?? '',
      billingAddress1: json['billing_info']?['bill_address1'] ?? '',
      billingAddress2: json['billing_info']?['bill_address2'] ?? '',
      billingZip: json['billing_info']?['bill_zip'] ?? '',
      billingCity: json['billing_info']?['bill_city'] ?? '',
      billingCountry: json['billing_info']?['bill_country'] ?? '',
      sameShipAddress: json['billing_info']?['same_ship_address'] ?? 'off',
    );
  }

  // Helper method to parse shipping details
  static ShippingDetails _parseShippingDetails(Map<String, dynamic> json) {
    if (json['order_source'] == 'web') {
      // Web order format
      return ShippingDetails(
        name:
            '${json['shipping_info']?['ship_first_name'] ?? ''} ${json['shipping_info']?['ship_last_name'] ?? ''}'
                .trim(),
        address: json['shipping_info']?['ship_address1'] ?? '',
        area: json['shipping_info']?['ship_address2'] ?? '',
        city: json['shipping_info']?['ship_city'] ?? '',
        state: json['shipping_info']?['ship_country'] ?? '',
        pincode: json['shipping_info']?['ship_zip'] ?? '',
      );
    } else {
      // Mobile order format
      return ShippingDetails(
        name: json['shipping_info']?['name'] ?? '',
        address: json['shipping']?['address'] ?? '',
        area: json['shipping']?['area'] ?? '',
        city: json['shipping']?['city'] ?? '',
        state: json['shipping']?['state'] ?? '',
        pincode: json['shipping']?['pincode'] ?? '',
      );
    }
  }

  static String _calculateFinalPrice(Map<String, dynamic> json) {
    if (json['order_source'] == 'web') {
      // Web order format - calculate from cart
      double total = 0.0;
      if (json['cart'] is Map) {
        json['cart'].forEach((key, item) {
          if (item is Map) {
            double price =
                double.tryParse(item['price']?.toString() ?? '0') ?? 0;
            int qty = int.tryParse(item['qty']?.toString() ?? '0') ?? 0;
            total += price * qty;
          }
        });
      }
      return total.toStringAsFixed(2);
    } else {
      // Mobile order format - use final_price directly
      return json['final_price']?.toString() ?? '0.00';
    }
  }
}

// Helper class for shipping details
class ShippingDetails {
  final String name;
  final String address;
  final String area;
  final String city;
  final String state;
  final String pincode;

  ShippingDetails({
    required this.name,
    required this.address,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
  });
}

// Update CartItemModel _parseCartItems method as previously shown
List<CartItemModel> _parseCartItems(dynamic cartData) {
  if (cartData is List) {
    // Handle mobile app format
    return cartData.map((item) => CartItemModel.fromJson(item)).toList();
  } else if (cartData is Map) {
    // Handle web format
    return cartData.entries.map((entry) {
      final item = entry.value;
      if (item is Map) {
        return CartItemModel(
          name: item['name']?.toString() ?? '',
          quantity: item['qty']?.toString() ?? '',
          qty: item['qty']?.toString() ?? '',
          price: item['price']?.toString() ?? '0.00',
        );
      }
      return CartItemModel(
        name: '',
        quantity: '',
        qty: '',
        price: '0.00',
      );
    }).toList();
  }
  return [];
}

int _parseUserId(dynamic userId) {
  if (userId is int) return userId;
  if (userId is String) return int.tryParse(userId) ?? 0;
  return 0;
}

DateTime _parseDateTime(String? dateTimeString) {
  try {
    return dateTimeString != null
        ? DateTime.parse(dateTimeString)
        : DateTime.now();
  } catch (e) {
    print('Error parsing datetime: $e');
    return DateTime.now();
  }
}

class CartItemModel {
  final String name;
  final String quantity;
  final String qty;
  final String price;

  CartItemModel({
    required this.name,
    required this.quantity,
    required this.qty,
    required this.price,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      name: json['name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? json['qty']?.toString() ?? '',
      qty: json['qty']?.toString() ?? json['quantity']?.toString() ?? '',
      price: json['rs']?.toString() ?? json['price']?.toString() ?? '0.00',
    );
  }
}
