import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart' as razorpay;
import '../../cart/controller/cartcontroller.dart';
import '../../delivery/controller/deliverycontroller.dart';
import '../../home/views/homepage.dart';
import 'invoicescreen.dart';

class RazorpayCheckoutScreen extends StatefulWidget {
  const RazorpayCheckoutScreen({Key? key}) : super(key: key);

  @override
  _RazorpayCheckoutScreenState createState() => _RazorpayCheckoutScreenState();
}

class _RazorpayCheckoutScreenState extends State<RazorpayCheckoutScreen> {
  late razorpay.Razorpay _razorpay;
  final CartController _cartController = Get.find<CartController>();
  final DeliveryDetailsController _deliveryController = Get.find<DeliveryDetailsController>();

  @override
  void initState() {
    super.initState();
    _razorpay = razorpay.Razorpay();
    _razorpay.on(razorpay.Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(razorpay.Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(razorpay.Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initiateRazorpayPayment();
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _initiateRazorpayPayment() async {
    double finalAmount = _deliveryController.finalAmount.value;
    int amountInPaisa = (finalAmount * 100).toInt();

    String orderDescription = 'Order Payment';
    if (_cartController.appliedCouponCode.value.isNotEmpty) {
      orderDescription += ' (Coupon: ${_cartController.appliedCouponCode.value})';
    }

    var options = {
      'key': 'rzp_live_BbOBBiObm5VTkb',
      'amount': amountInPaisa,
      'name': 'Generic Bharat',
      'description': orderDescription,
      'prefill': {},
      'notes': {
        'delivery_address': _deliveryController.selectedAddress.value,
        'patient_name': _deliveryController.selectedPatientName.value,
        'original_amount': _cartController.total.value.toString(),
        'discount_amount': _cartController.discountAmount.value.toString(),
        'coupon_code': _cartController.appliedCouponCode.value,
        'final_amount': finalAmount.toString(),
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment initialization failed: $e")),
      );
    }
  }

  void _handlePaymentSuccess(razorpay.PaymentSuccessResponse response) async {
    try {
      // First, confirm the order
      final orderResponse = await _deliveryController.confirmOrder(
        paymentId: response.paymentId ?? 'N/A',
        originalAmount: _cartController.total.value,
        discountAmount: _cartController.discountAmount.value,
        finalAmount: _deliveryController.finalAmount.value,
        couponCode: _cartController.appliedCouponCode.value,
      );

      print('Order confirmation successful: $orderResponse');

      // Then navigate to invoice screen
      Get.off(() => InvoiceScreen(
        paymentId: response.paymentId ?? 'N/A',
        totalAmount: _deliveryController.finalAmount.value,
        originalAmount: _cartController.total.value,
        discountAmount: _cartController.discountAmount.value,
        couponCode: _cartController.appliedCouponCode.value,

      ));
    } catch (e) {
      print('Error confirming order: $e');
      Get.snackbar(
        'Error',
        'Payment successful but order confirmation failed. Please contact support.',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    }
  }

  void _handlePaymentError(razorpay.PaymentFailureResponse response) {
    Get.back();
    Get.snackbar(
        'Payment Failed',
        response.message ?? 'Unknown error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white
    );
  }

  void _handleExternalWallet(razorpay.ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet Selected: ${response.walletName}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}