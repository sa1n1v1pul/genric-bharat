import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart' as razorpay;
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_endpoints/api_provider.dart';
import '../../cart/controller/cartcontroller.dart';
import '../../delivery/controller/deliverycontroller.dart';

import 'invoicescreen.dart';

class PaymentSelectionScreen extends StatefulWidget {
  const PaymentSelectionScreen({Key? key}) : super(key: key);

  @override
  _PaymentSelectionScreenState createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  late razorpay.Razorpay _razorpay;
  final CartController _cartController = Get.find<CartController>();
  final DeliveryDetailsController _deliveryController = Get.find<DeliveryDetailsController>();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  @override
  void initState() {
    super.initState();
    _razorpay = razorpay.Razorpay();
    _razorpay.on(razorpay.Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(razorpay.Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(razorpay.Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPaymentOptions();
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('Pay with Razorpay'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _initiateRazorpayPayment,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.money),
              label: const Text('Cash on Delivery'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _processCashOnDelivery,
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _prepareOrderData({String? txnId}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    // Prepare discount data only if a coupon is applied
    Map<String, dynamic>? discountData;
    if (_cartController.appliedCouponCode.isNotEmpty && _cartController.discountAmount.value > 0) {
      discountData = {
        "discount": _cartController.discountAmount.value,
        "code": _cartController.appliedCouponCode.value
      };
    }

    // Prepare shipping information
    final shippingInfo = {
      "ship_first_name": _deliveryController.selectedPatientName.value,
      "ship_address1": _deliveryController.selectedAddress.value,
      "ship_zip": _deliveryController.selectedPincode.value,
      "ship_city": _deliveryController.selectedCity.value,
      "state": _deliveryController.selectedState.value
    };

    // Build the order data map
    final orderData = <String, dynamic>{
      "user_id": userId,
      "payment_method": txnId != null ? 'razorpay' : 'cod',
      "shipping_info": shippingInfo,
    };

    // Only add optional fields if they have values
    if (txnId != null) {
      orderData["txnid"] = txnId;
    }

    if (discountData != null) {
      orderData["discount"] = discountData;
    }

    return orderData;
  }

  Future<void> _createOrder({String? txnId}) async {
    try {
      final orderData = await _prepareOrderData(txnId: txnId);

      final response = await _apiProvider.post('/orders-app', orderData);

      if (response.statusCode == 200) {
        // Handle successful order creation
        Get.off(() => InvoiceScreen(
          paymentId: txnId ?? 'COD',
          totalAmount: _deliveryController.finalAmount.value,
          originalAmount: _cartController.total.value,
          discountAmount: _cartController.discountAmount.value,
          couponCode: _cartController.appliedCouponCode.value,
        ));
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create order: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    }
  }

  void _initiateRazorpayPayment() {
    Get.back(); // Close bottom sheet

    double finalAmount = _deliveryController.finalAmount.value;
    int amountInPaisa = (finalAmount * 100).toInt();

    var options = {
      'key': 'rzp_live_BbOBBiObm5VTkb',
      'amount': amountInPaisa,
      'name': 'Generic Bharat',
      'description': _cartController.appliedCouponCode.isNotEmpty
          ? 'Order Payment (Coupon: ${_cartController.appliedCouponCode})'
          : 'Order Payment',
      'prefill': {
        'name': _deliveryController.selectedPatientName.value,
      },
      'notes': {
        'address': _deliveryController.selectedAddress.value,
        'final_amount': finalAmount.toString(),
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Payment initialization failed: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    }
  }

  void _handlePaymentSuccess(razorpay.PaymentSuccessResponse response) async {
    await _createOrder(txnId: response.paymentId);
  }

  void _handlePaymentError(razorpay.PaymentFailureResponse response) {
    Get.back();
    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Unknown error occurred',
      backgroundColor: Colors.red[100],
      colorText: Colors.black,
    );
  }

  void _handleExternalWallet(razorpay.ExternalWalletResponse response) {
    Get.snackbar(
      'External Wallet',
      'External Wallet Selected: ${response.walletName}',
      backgroundColor: Colors.blue[100],
      colorText: Colors.black,
    );
  }

  Future<void> _processCashOnDelivery() async {
    Get.back(); // Close bottom sheet
    await _createOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}