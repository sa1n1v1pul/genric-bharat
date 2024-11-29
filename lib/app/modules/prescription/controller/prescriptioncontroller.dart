import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../api_endpoints/api_endpoints.dart';

class PrescriptionController extends GetxController {
  final Dio _dio = Dio();
  final RxList<Map<String, dynamic>> prescriptions = <Map<String, dynamic>>[].obs;
  final RxBool isPrescriptionsLoading = true.obs;
  final RxBool isPrescriptionUploading = false.obs;
  final RxString prescriptionUrl = ''.obs;
  final RxnInt userId = RxnInt();

  @override
  void onInit() async {
    super.onInit();
    // Try to get userId from SharedPreferences during initialization
    await loadUserId();
  }

  Future<void> loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('user_id');
      if (storedUserId != null) {
        userId.value = storedUserId;
        await fetchPrescriptions();
      }
    } catch (e) {
      print('Error loading userId in PrescriptionController: $e');
    }
  }

  Future<void> initialize(int newUserId) async {
    try {
      print('Initializing PrescriptionController with userId: $newUserId');
      userId.value = newUserId;

      // Save userId to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', newUserId);
      print('Saved userId to SharedPreferences: $newUserId');

      await fetchPrescriptions();
    } catch (e) {
      print('Error initializing PrescriptionController: $e');
    }
  }

  Future<void> uploadPrescription(File prescriptionFile) async {
    if (userId.value == null) {
      throw 'User ID not initialized';
    }

    try {
      isPrescriptionUploading.value = true;

      final formData = dio.FormData.fromMap({
        'user_id': userId.value.toString(),
        'prescription': await dio.MultipartFile.fromFile(
          prescriptionFile.path,
          filename: prescriptionFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        ApiEndpoints.prescription,
        data: formData,
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['status'] == 'success') {
          prescriptionUrl.value = responseData['data']['prescription_url'];
          await fetchPrescriptions();
          print('Prescription uploaded successfully: ${prescriptionUrl.value}');
        } else {
          throw 'Upload failed: ${responseData['message']}';
        }
      } else {
        throw 'Upload failed with status: ${response.statusCode}';
      }
    } catch (e) {
      print('Error uploading prescription: $e');
      throw e;
    } finally {
      isPrescriptionUploading.value = false;
    }
  }

  Future<void> fetchPrescriptions() async {
    if (userId.value == null) {
      print('PrescriptionController: Cannot fetch prescriptions - userId is null');
      return;
    }

    try {
      print('Fetching prescriptions for userId: ${userId.value}');
      isPrescriptionsLoading.value = true;
      final response = await _dio.get(
        ApiEndpoints.getUserPrescriptions(userId.value!),
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 'success') {
          prescriptions.value = List<Map<String, dynamic>>.from(responseData['data']);
          print('Successfully fetched ${prescriptions.length} prescriptions');
        }
      }
    } catch (e) {
      print('Error fetching prescriptions: $e');
    } finally {
      isPrescriptionsLoading.value = false;
    }
  }

  @override
  void onClose() {
    prescriptions.clear();
    super.onClose();
  }
}