import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../controller/addresscontroller.dart';

class AddressScreen extends GetView<AddressController> {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(AddressController());
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
      body: Obx(() => Stack(
        children: [
          Form(
            key: controller.formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildLabel('Enter Pincode'),
                const SizedBox(height: 8),
                _buildPincodeSection(),
                const SizedBox(height: 24),
                _buildLabel('House number, Floor, Building name'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: controller.addressLine1Controller,
                  hintText: 'Address Line 1',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('Street name'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: controller.addressLine2Controller,
                  hintText: 'Street name',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter street name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('Area, Colony'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: controller.localityController,
                  hintText: 'Area/Colony name',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter area/colony';
                    }
                    return null;
                  },
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
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter city';
                              }
                              return null;
                            },
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
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter state';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLabel('Save as'),
                const SizedBox(height: 12),
                _buildAddressTypeSelector(),
                const SizedBox(height: 32),
                _buildSaveButton(),
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

  Widget _buildPincodeSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
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
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter pincode';
                }
                if (value!.length != 6) {
                  return 'Please enter valid 6-digit pincode';
                }
                return null;
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
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
          child: ElevatedButton.icon(
            onPressed: controller.getCurrentLocation,
            icon:  Icon(Icons.location_on, color: CustomTheme.loginGradientStart,),
            label:  Text(
              'Use current',
              style: TextStyle(color: CustomTheme.loginGradientStart,),
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
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
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
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
          filled: true,
          fillColor: Colors.white,
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

  Widget _buildAddressTypeSelector() {
    return Obx(() => Row(
      children: [
        _buildAddressTypeChip('Home', 0),
        const SizedBox(width: 12),
        _buildAddressTypeChip('Office', 1),
        const SizedBox(width: 12),
        _buildAddressTypeChip('Other', 2),
      ],
    ));
  }

  Widget _buildAddressTypeChip(String label, int index) {
    final isSelected = controller.selectedAddressType.value == index;
    return GestureDetector(
      onTap: () => controller.selectedAddressType.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? CustomTheme.loginGradientStart : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? CustomTheme.loginGradientStart : Colors.grey[300]!,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
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