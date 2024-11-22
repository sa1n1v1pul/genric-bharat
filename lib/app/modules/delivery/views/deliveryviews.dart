import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../controller/deliverycontroller.dart';

class DeliveryDetailsScreen extends GetView<DeliveryDetailsController> {
  const DeliveryDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Delivery Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patient Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPatientNameWidget(),
                const SizedBox(height: 24),
                _buildSectionHeader('Delivery Address'),
                const SizedBox(height: 12),
                _buildAddressCard(),
                const SizedBox(height: 40),
                _buildProceedButton(),
              ],
            ),
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      )),
    );
  }

  Widget _buildPatientNameWidget() {
    return Obx(() {
      if (controller.selectedPatientName.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller.patientNameController,
            decoration: InputDecoration(
              hintText: 'Enter patient name',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      } else {
        return _buildPatientNameCard();
      }
    });
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientNameCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        controller.selectedPatientName.value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    // Existing address card code remains the same
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                onPressed: controller.onAddAddressPressed,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.selectedAddress.value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              children: [
                const TextSpan(
                  text: 'Area: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: controller.selectedLocality.value),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              children: [
                const TextSpan(
                  text: 'City: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: controller.selectedCity.value),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              children: [
                const TextSpan(
                  text: 'State: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: controller.selectedState.value),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              children: [
                const TextSpan(
                  text: 'PIN: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: controller.selectedPincode.value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.onProceedToCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Proceed to checkout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}