import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';

import '../../home/views/addressview.dart';
import '../controller/deliverycontroller.dart';
import 'addressmodel.dart';

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
                const SizedBox(height: 12),

                _buildAddressSection(),
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

  Widget _buildAddressCard(Address address) {
    return Obx(() {
      final isSelected = controller.selectedAddress.value?.id == address.id;

      return GestureDetector(
        onTap: () => controller.selectAddress(address),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Radio<int>(
                    value: address.id,
                    groupValue: controller.selectedAddress.value?.id,
                    onChanged: (_) => controller.selectAddress(address),
                  ),
                  Expanded(
                    child: Text(
                      '${address.address1}, ${address.address2}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      final addressModel = AddressModel(
                        id: address.id,
                        userId: address.id,
                        pinCode: address.pinCode,
                        shipAddress1: address.address1,
                        shipAddress2: address.address2,
                        area: address.area,
                        landmark: address.landmark ?? '',
                        city: address.city,
                        state: address.state,
                      );
                      Get.to(() => AddressScreen(addressToEdit: addressModel));
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Area: ${address.area}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      'Landmark: ${address.landmark}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      '${address.city}, ${address.state}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      'PIN: ${address.pinCode}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAddressSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Delivery Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => AddressScreen()),
              child: const Text('Add New Address'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.addresses.isEmpty) {
            return const Center(
              child: Text('No addresses found'),
            );
          }

          return Column(
            children: [
              ...controller.addresses.map((address) => _buildAddressCard(address)),
            ],
          );
        }),
      ],
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