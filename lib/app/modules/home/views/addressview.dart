import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../controller/addresscontroller.dart';

class AddressScreen extends StatelessWidget {
  AddressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<AddressController>(
      init: AddressController(),
      builder: (controller) {
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
              'Address Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: Stack(
            children: [
              Form(
                key: controller.formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildLabel('Enter Pincode'),
                    const SizedBox(height: 8),
                    _buildPincodeSection(controller),
                    const SizedBox(height: 24),
                    _buildAutoFilledFields(controller),
                    const SizedBox(height: 32),
                    _buildSaveButton(controller),
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
          ),
        );
      },
    );
  }

  Widget _buildPincodeSection(AddressController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: controller.pincodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        hintText: 'Pincode',
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        suffixIcon: _buildPincodeSuffixIcon(controller),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.blue[300]!),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                      validator: controller.validatePincode,
                    ),
                  ),
                  if (controller.pincodeController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 8),
                      child: _buildDeliveryStatusMessage(controller),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildCurrentLocationButton(controller),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentLocationButton(AddressController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: controller.getCurrentLocation,
        icon: Icon(Icons.location_on, color: CustomTheme.loginGradientStart),
        label: Text(
          'Use current',
          style: TextStyle(color: CustomTheme.loginGradientStart),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoFilledFields(AddressController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('House number, Floor, Building name'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: controller.addressLine1Controller,
          hintText: 'House No., Floor, Building name',
          validator: (value) => value?.isEmpty ?? true ? 'Please enter house number' : null,
        ),
        const SizedBox(height: 16),

        // Always show Post Office label and field
        _buildLabel('Post Office'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: controller.addressLine2Controller,
          hintText: 'Post Office',
          validator: (value) => value?.isEmpty ?? true ? 'Please enter post office' : null,
          enabled: false, // Make it read-only since it's populated from API
        ),
        const SizedBox(height: 16),



        _buildLabel('Area, Colony'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: controller.localityController,
          hintText: 'Area/Colony name',
          validator: (value) => value?.isEmpty ?? true ? 'Please enter area/colony' : null,
        ),
        const SizedBox(height: 16),

        _buildLabel('Landmark (Optional)'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: controller.landmarkController,
          hintText: 'Landmark',
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('City'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: controller.cityController,
                    hintText: 'City',
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter city' : null,
                    enabled: !controller.isPincodeValid.value,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('State'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: controller.stateController,
                    hintText: 'State',
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter state' : null,
                    enabled: !controller.isPincodeValid.value,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPincodeSuffixIcon(AddressController controller) {
    if (controller.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (controller.pincodeController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    if (controller.isPincodeValid.value && controller.isDeliveryAvailable.value) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }

    if (controller.pincodeController.text.length == 6) {
      return const Icon(Icons.error, color: Colors.red);
    }

    return const SizedBox.shrink();
  }

  Widget _buildDeliveryStatusMessage(AddressController controller) {
    final isSuccess = controller.isPincodeValid.value && controller.isDeliveryAvailable.value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: isSuccess ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              controller.pincodeValidationMessage.value,
              style: TextStyle(
                color: isSuccess ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: CustomTheme.loginGradientStart.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.red[300]!),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSaveButton(AddressController controller) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.loginGradientStart.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.saveAddress,
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomTheme.loginGradientStart,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Save and continue',
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