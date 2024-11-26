// // OrderModel.dart
// class OrderModel {
//   final int id;
//   final int userId; // Changed from String to int
//   final List<CartItemModel> cart;
//   final String currencySign;
//   final String discount;
//   final String? couponApplied;
//   final String paymentMethod;
//   final String txnid;
//   final String orderStatus;
//   final String paymentStatus;
//   final String finalPrice;
//   final DateTime createdAt;
//
//   // Shipping Details
//   final String shippingName;
//   final String shippingAddress;
//   final String shippingArea;
//   final String shippingCity;
//   final String shippingState;
//   final String shippingPincode;
//
//   // Billing Details
//   final String billingName;
//   final String billingAddress;
//   final String billingCity;
//   final String billingState;
//   final String billingPincode;
//
//   OrderModel({
//     required this.id,
//     required this.userId,
//     required this.cart,
//     required this.currencySign,
//     required this.discount,
//     this.couponApplied,
//     required this.paymentMethod,
//     required this.txnid,
//     required this.orderStatus,
//     required this.paymentStatus,
//     required this.finalPrice,
//     required this.createdAt,
//     required this.shippingName,
//     required this.shippingAddress,
//     required this.shippingArea,
//     required this.shippingCity,
//     required this.shippingState,
//     required this.shippingPincode,
//     required this.billingName,
//     required this.billingAddress,
//     required this.billingCity,
//     required this.billingState,
//     required this.billingPincode,
//   });
//
//   factory OrderModel.fromJson(Map<String, dynamic> json) {
//     return OrderModel(
//       id: json['id'] ?? 0,
//       userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0, // Convert to int
//       cart: (json['cart']['items'] as List?)
//           ?.map((item) => CartItemModel.fromJson(item))
//           .toList() ??
//           [],
//       currencySign: json['currency_sign'] ?? '₹',
//       discount: json['discount'] ?? '0',
//       couponApplied: json['coupon_applied'],
//       paymentMethod: json['payment_method'] ?? '',
//       txnid: json['txnid'] ?? '',
//       orderStatus: json['order_status'] ?? '',
//       paymentStatus: json['payment_status'] ?? '',
//       finalPrice: json['final_price'] ?? '0',
//       createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
//
//       // Shipping Details
//       shippingName: json['shipping_info']?['name'] ?? '',
//       shippingAddress: json['shipping']?['address'] ?? '',
//       shippingArea: json['shipping']?['area'] ?? '',
//       shippingCity: json['shipping']?['city'] ?? '',
//       shippingState: json['shipping']?['state'] ?? '',
//       shippingPincode: json['shipping']?['pincode'] ?? '',
//
//       // Billing Details
//       billingName: json['billing_info']?['bill_first_name'] ?? '',
//       billingAddress: json['billing_info']?['bill_address1'] ?? '',
//       billingCity: json['billing_info']?['bill_city'] ?? '',
//       billingState: json['billing_info']?['bill_country'] ?? '',
//       billingPincode: json['billing_info']?['bill_zip'] ?? '',
//     );
//   }
// }
//
// // CartItemModel.dart
// class CartItemModel {
//   final String name;
//   final String price;
//   final String quantity;
//
//   CartItemModel({
//     required this.name,
//     required this.price,
//     required this.quantity,
//   });
//
//   factory CartItemModel.fromJson(Map<String, dynamic> json) {
//     return CartItemModel(
//       name: json['name'] ?? '',
//       price: json['rs'] ?? '',
//       quantity: json['quantity'] ?? '',
//     );
//   }
// }