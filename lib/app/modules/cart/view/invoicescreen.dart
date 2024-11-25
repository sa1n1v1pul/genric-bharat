import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:open_file/open_file.dart';
import 'package:genric_bharat/app/modules/cart/controller/cartcontroller.dart';
import 'package:genric_bharat/app/modules/delivery/controller/deliverycontroller.dart';
import 'package:genric_bharat/app/modules/api_endpoints/api_endpoints.dart';
import '../../routes/app_routes.dart';
import 'cartitem.dart';

class InvoiceScreen extends StatelessWidget {
  final String paymentId;
  final double totalAmount;
  final double originalAmount;
  final double discountAmount;
  final String couponCode;

  const InvoiceScreen({
    Key? key,
    required this.paymentId,
    required this.totalAmount,
    required this.originalAmount,
    required this.discountAmount,
    required this.couponCode,
  }) : super(key: key);

  Future<void> _generateAndDownloadPdf(
      CartController cartController,
      DeliveryDetailsController deliveryController,
      BuildContext context) async {
    try {
      print('Starting PDF generation process...');

      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Storage permission is required to download invoice')));
        return;
      }

      final pdf = pw.Document();
      final regularFont =
      await rootBundle.load("assets/fonts/Roboto/Roboto-Regular.ttf");
      final ttfRegular = pw.Font.ttf(regularFont);

      List<pw.MemoryImage> productImages = [];
      for (var item in cartController.cartItems) {
        try {
          final response =
          await http.get(Uri.parse('${ApiEndpoints.imageBaseUrl}${item.image}'));
          if (response.statusCode == 200) {
            productImages.add(pw.MemoryImage(response.bodyBytes));
          }
        } catch (e) {
          print('Failed to load image for product ${item.name}: $e');
          continue;
        }
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header Section
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Invoice',
                      style: pw.TextStyle(
                        fontSize: 24,
                        font: ttfRegular,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Payment Successful',
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.green700,
                        font: ttfRegular,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Payment Details Section
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Payment Details',
                      style: pw.TextStyle(
                        fontSize: 16,
                        font: ttfRegular,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildPdfRow('Payment ID', paymentId, font: ttfRegular),
                    _buildPdfRow(
                      'Payment Date',
                      DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
                      font: ttfRegular,
                    ),
                    if (couponCode.isNotEmpty)
                      _buildPdfRow('Coupon Applied', couponCode, font: ttfRegular),
                    _buildPdfRow(
                      'Original Amount',
                      'Rs. ${originalAmount.toStringAsFixed(2)}',
                      font: ttfRegular,
                    ),
                    if (discountAmount > 0)
                      _buildPdfRow(
                        'Discount',
                        '- Rs. ${discountAmount.toStringAsFixed(2)}',
                        font: ttfRegular,
                        color: PdfColors.green700,
                      ),
                    _buildPdfRow(
                      'Final Amount',
                      'Rs. ${totalAmount.toStringAsFixed(2)}',
                      font: ttfRegular,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              // Rest of the sections remain the same
              pw.SizedBox(height: 20),

              // Delivery Information Section
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Delivery Information',
                      style: pw.TextStyle(
                        fontSize: 16,
                        font: ttfRegular,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildPdfRow('Patient Name',
                        deliveryController.selectedPatientName.value,
                        font: ttfRegular),
                    _buildPdfRow('Delivery Address',
                        deliveryController.selectedAddress.value,
                        font: ttfRegular),
                    _buildPdfRow(
                        'Area', deliveryController.selectedLocality.value,
                        font: ttfRegular),
                    _buildPdfRow('City', deliveryController.selectedCity.value,
                        font: ttfRegular),
                    _buildPdfRow('State', deliveryController.selectedState.value,
                        font: ttfRegular),
                    _buildPdfRow('Pincode',
                        deliveryController.selectedPincode.value,
                        font: ttfRegular),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Order Items Section with updated totals
              if (cartController.cartItems.isNotEmpty)
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Order Items',
                        style: pw.TextStyle(
                          fontSize: 16,
                          font: ttfRegular,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      ...cartController.cartItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 8),
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (index < productImages.length)
                                pw.Container(
                                  width: 40,
                                  height: 40,
                                  child: pw.Image(productImages[index],
                                      fit: pw.BoxFit.cover),
                                ),
                              pw.SizedBox(width: 10),
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      item.name,
                                      style: pw.TextStyle(font: ttfRegular),
                                    ),
                                    pw.Text(
                                      'Quantity: ${item.quantity}',
                                      style: pw.TextStyle(font: ttfRegular),
                                    ),
                                    pw.Text(
                                      'Rs. ${(item.price * item.quantity).toStringAsFixed(2)}',
                                      style: pw.TextStyle(font: ttfRegular),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      // Updated Total Summary Section
                      pw.SizedBox(height: 20),
                      pw.Divider(color: PdfColors.grey300),
                      _buildPdfRow(
                        'Subtotal',
                        'Rs. ${originalAmount.toStringAsFixed(2)}',
                        font: ttfRegular,
                      ),
                      if (discountAmount > 0)
                        _buildPdfRow(
                          'Discount',
                          '- Rs. ${discountAmount.toStringAsFixed(2)}',
                          font: ttfRegular,
                          color: PdfColors.green700,
                        ),
                      _buildPdfRow(
                        'Delivery Charges',
                        'Free',
                        font: ttfRegular,
                      ),
                      pw.Divider(color: PdfColors.grey300),
                      _buildPdfRow(
                        'Total Amount',
                        'Rs. ${totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                        font: ttfRegular,
                      ),
                    ],
                  ),
                ),
            ];
          },
        ),
      );

      Directory? downloadsDir = Directory('/storage/emulated/0/Download');
      final String filename =
          'invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String path = '${downloadsDir.path}/$filename';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      await MediaScanner.loadMedia(path: path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice downloaded successfully: $filename'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () async {
              final result = await OpenFile.open(path);
              if (result.type != ResultType.done) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Could not open file: ${result.message}')),
                );
              }
            },
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('Error in PDF generation: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download invoice: $e')),
      );
    }
  }

  pw.Widget _buildPdfRow(String label, String value,
      {bool isBold = false,
        required pw.Font font,
        PdfColor color = PdfColors.black}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isBold ? 16 : 14,
              font: font,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isBold ? 16 : 14,
              font: font,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    final DeliveryDetailsController deliveryController =
    Get.find<DeliveryDetailsController>();
    bool isDarkMode = Get.isDarkMode;

    return WillPopScope(
        onWillPop: () async {
          await cartController.clearAllCart();
          Get.offAllNamed(Routes.HOME);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            centerTitle: true,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              color: Colors.black,
              onPressed: () async {
                await cartController.clearAllCart();
                Get.offAllNamed(Routes.HOME);
              },
            ),
            title: const Text(
              'Order Invoice',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Center(
            child: Column(
            children: [
              const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 10),
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildSectionHeader('Payment Details'),
        _buildDetailRow('Payment ID', paymentId),
        _buildDetailRow('Payment Date',
            DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())),
        if (couponCode.isNotEmpty)
    _buildDetailRow('Coupon Applied', couponCode),
    _buildDetailRow(
    'Original Amount', '₹${originalAmount.toStringAsFixed(2)}'),
    if (discountAmount > 0)
    _buildDetailRow(
    'Discount',
    '- ₹${discountAmount.toStringAsFixed(2)}',
    valueColor: Colors.green,
    ),
    _buildDetailRow(
    'Final Amount', '₹${totalAmount.toStringAsFixed(2)}',
    isBold: true),

    const SizedBox(height: 20),

    _buildSectionHeader('Delivery Information'),
    _buildDetailRow('Patient Name',
    deliveryController.selectedPatientName.value),
    _buildDetailRow('Delivery Address',
    deliveryController.selectedAddress.value),
    _buildDetailRow('Area', deliveryController.selectedLocality.value),
    _buildDetailRow('City', deliveryController.selectedCity.value),
    _buildDetailRow('State', deliveryController.selectedState.value),
    _buildDetailRow('Pincode', deliveryController.selectedPincode.value),

    const SizedBox(height: 20),

                _buildSectionHeader(
                    'Order Items (${cartController.cartItems.length})'),
                ...cartController.cartItems
                    .map((item) => _buildOrderItemCard(item))
                    .toList(),

                const SizedBox(height: 20),

                // Total Summary section with discount details
                _buildSectionHeader('Order Summary'),
                Column(
                  children: [
                    _buildTotalRow('Subtotal', originalAmount),
                    if (discountAmount > 0)
                      _buildTotalRow('Discount', discountAmount,
                          isDiscount: true),
                    _buildTotalRow('Delivery Charges', 0.0, isDelivery: true),
                    const Divider(),
                    _buildTotalRow('Total Amount', totalAmount, isBold: true),
                  ],
                ),

                const SizedBox(height: 30),

                Center(
                  child: ElevatedButton(
                    onPressed: () => _generateAndDownloadPdf(
                      cartController,
                      deliveryController,
                      context,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Download Invoice',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(CartItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                '${ApiEndpoints.imageBaseUrl}${item.image}',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error_outline),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity: ${item.quantity}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount,
      {bool isDelivery = false, bool isDiscount = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            isDelivery
                ? 'Free'
                : isDiscount
                ? '- ₹${amount.toStringAsFixed(2)}'
                : '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDelivery
                  ? Colors.green
                  : isDiscount
                  ? Colors.green
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}