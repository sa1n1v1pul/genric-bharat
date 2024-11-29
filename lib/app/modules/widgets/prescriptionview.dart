import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../core/theme/theme.dart';
import '../home/controller/homecontroller.dart';
import '../prescription/controller/prescriptioncontroller.dart';

class UploadPrescriptionScreen extends StatefulWidget {
  const UploadPrescriptionScreen({Key? key}) : super(key: key);

  @override
  State<UploadPrescriptionScreen> createState() => _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState extends State<UploadPrescriptionScreen> {
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  final PrescriptionController _prescriptionController = Get.find<PrescriptionController>();

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
        _uploadFile();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File select karne me error aaya hai'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await _prescriptionController.uploadPrescription(_selectedFile!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File successfully upload ho gayi hai'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File upload karne me error aaya hai'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: Container(
          padding: const EdgeInsets.only(left: 4),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? Colors.black : Colors.white).withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        toolbarHeight: 60,
        title: const Text(
          'Upload Prescription',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

        body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload your prescription to start ordering',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please ensure that the prescription is valid and contains doctor, patient and medicine details.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: _isUploading ? null : _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all( color: CustomTheme.loginGradientStart,),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedFile != null ? Icons.check_circle : Icons.upload_file,
                            color: CustomTheme.loginGradientStart,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isUploading
                                ? 'Uploading...'
                                : _selectedFile != null
                                ? 'File Selected'
                                : 'Upload prescription',
                            style: TextStyle(
                              color: CustomTheme.loginGradientStart,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (_fileName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _fileName!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (_isUploading) ...[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Next Steps',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: CustomTheme.loginGradientStart.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:  Icon(
                        Icons.phone,
                          color: CustomTheme.loginGradientStart,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pharmacist call',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Free',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Our pharmacist will call to confirm the medicines in your prescription',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}