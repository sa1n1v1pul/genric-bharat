import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';

class OrderPreviewController extends GetxController {
  final Rx<OrderDetailModel> orderDetails = OrderDetailModel.empty().obs;

  void setOrderDetails(Map<String, dynamic> orderData) {
    orderDetails.value = OrderDetailModel.fromJson(orderData);
  }
}

class OrderDetailModel {
  final int id;
  final String userId;
  final CartDetails cart;
  final String currencySign;
  final String discount;
  final String? couponApplied;
  final ShippingDetails shipping;
  final String paymentMethod;
  final String txnId;
  final String orderStatus;
  final ShippingInfo shippingInfo;
  final BillingInfo billingInfo;
  final String paymentStatus;
  final String finalPrice;
  final DateTime createdAt;

  OrderDetailModel({
    required this.id,
    required this.userId,
    required this.cart,
    required this.currencySign,
    required this.discount,
    this.couponApplied,
    required this.shipping,
    required this.paymentMethod,
    required this.txnId,
    required this.orderStatus,
    required this.shippingInfo,
    required this.billingInfo,
    required this.paymentStatus,
    required this.finalPrice,
    required this.createdAt,
  });

  factory OrderDetailModel.empty() => OrderDetailModel(
        id: 0,
        userId: '',
        cart: CartDetails(items: []),
        currencySign: '₹',
        discount: '0',
        couponApplied: null,
        shipping: ShippingDetails.empty(),
        paymentMethod: '',
        txnId: '',
        orderStatus: '',
        shippingInfo: ShippingInfo.empty(),
        billingInfo: BillingInfo.empty(),
        paymentStatus: '',
        finalPrice: '0',
        createdAt: DateTime.now(),
      );

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailModel(
        id: json['id'] ?? 0,
        userId: json['user_id']?.toString() ?? '',
        cart: CartDetails.fromJson(json['cart'] ?? {}),
        currencySign: json['currency_sign'] ?? '₹',
        discount: json['discount'] ?? '0',
        couponApplied: json['coupon_applied'],
        shipping: ShippingDetails.fromJson(json['shipping'] ?? {}),
        paymentMethod: json['payment_method'] ?? '',
        txnId: json['txnid'] ?? '',
        orderStatus: json['order_status'] ?? '',
        shippingInfo: ShippingInfo.fromJson(json['shipping_info'] ?? {}),
        billingInfo: BillingInfo.fromJson(json['billing_info'] ?? {}),
        paymentStatus: json['payment_status'] ?? '',
        finalPrice: json['final_price'] ?? '0',
        createdAt: DateTime.parse(
            json['created_at'] ?? DateTime.now().toIso8601String()),
      );
}

class CartDetails {
  final List<CartItem> items;

  CartDetails({required this.items});

  factory CartDetails.fromJson(Map<String, dynamic> json) => CartDetails(
        items: (json['items'] as List?)
                ?.map((item) => CartItem.fromJson(item))
                .toList() ??
            [],
      );
}

class CartItem {
  final String name;
  final String price;
  final String quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        name: json['name'] ?? '',
        price: json['rs'] ?? '',
        quantity: json['quantity'] ?? '',
      );
}

class ShippingDetails {
  final String address;
  final String area;
  final String city;
  final String state;
  final String pincode;

  ShippingDetails({
    required this.address,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory ShippingDetails.empty() => ShippingDetails(
        address: '',
        area: '',
        city: '',
        state: '',
        pincode: '',
      );

  factory ShippingDetails.fromJson(Map<String, dynamic> json) =>
      ShippingDetails(
        address: json['address'] ?? '',
        area: json['area'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        pincode: json['pincode'] ?? '',
      );
}

class ShippingInfo {
  final String name;
  final String address;
  final String city;
  final String state;
  final String pincode;

  ShippingInfo({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory ShippingInfo.empty() => ShippingInfo(
        name: '',
        address: '',
        city: '',
        state: '',
        pincode: '',
      );

  factory ShippingInfo.fromJson(Map<String, dynamic> json) => ShippingInfo(
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        pincode: json['pincode'] ?? '',
      );
}

class BillingInfo {
  final String firstName;
  final String address;
  final String city;
  final String state;
  final String zip;
  final String country;

  BillingInfo({
    required this.firstName,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
  });

  factory BillingInfo.empty() => BillingInfo(
        firstName: '',
        address: '',
        city: '',
        state: '',
        zip: '',
        country: '',
      );

  factory BillingInfo.fromJson(Map<String, dynamic> json) => BillingInfo(
        firstName: json['bill_first_name'] ?? '',
        address: json['bill_address1'] ?? '',
        city: json['bill_city'] ?? '',
        state: json['bill_country'] ?? '',
        zip: json['bill_zip'] ?? '',
        country: json['bill_country'] ?? '',
      );
}


