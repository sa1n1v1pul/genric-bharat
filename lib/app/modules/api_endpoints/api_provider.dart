import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';

class ApiProvider extends GetxController {
  late dio.Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));
    _dio.interceptors.add(dio.LogInterceptor(
      responseBody: true,
      requestBody: true,
      requestHeader: true,
    ));
  }

  Future<dio.Response> requestOtp(String mobileNumber) async {
    try {
      return await _dio.post(
        ApiEndpoints.requestOtp,
        data: {'mobile_number': mobileNumber},
      );
    } catch (e) {
      print('Error in requestOtp: $e');
      throw e;
    }
  }

  Future<dio.Response> updateUserLocation(int userId, double latitude, double longitude) async {
    try {
      final token = await getToken();
      return await _dio.put(
        '${ApiEndpoints.updateUserLocation}$userId/location',
        data: {
          'latitu': latitude.toString(),
          'longitu': longitude.toString(),
        },
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Error in updateUserLocation: $e');
      throw e;
    }
  }



  Future<dio.Response> verifyOtp(
      String mobileNumber, String otp, int? id) async {
    try {
      final data = {
        'mobile_number': mobileNumber,
        'otp': otp,
        'id': id,
      };
      print('Verify OTP request data: $data');
      return await _dio.post(
        ApiEndpoints.verifyOtp,
        data: data,
      );
    } catch (e) {
      print('Error in verifyOtp: $e');
      if (e is dio.DioException) {
        print('DioException details: ${e.message}');
        print('DioException type: ${e.type}');
        print('DioException response: ${e.response}');
      }
      throw e;
    }
  }

  Future<dio.Response> getOtp(String mobileNumber) async {
    try {
      return await _dio.get(
        ApiEndpoints.getOtp,
        queryParameters: {'mobile_number': mobileNumber},
      );
    } catch (e) {
      print('Error in getOtp: $e');
      throw e;
    }
  }

  Future<dio.Response> getUserProfile(int userId) async {
    try {
      final token = await getToken();
      return await _dio.get(
        '${ApiEndpoints.profile}?id=$userId',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Error in getUserProfile: $e');
      throw e;
    }
  }

  // New method for updating user profile
  Future<dio.Response> updateUserProfile(int userId, Map<String, dynamic> userData) async {
    try {
      final token = await getToken();
      return await _dio.put(
        '${ApiEndpoints.profile_update}$userId',
        data: userData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Error in updateUserProfile: $e');
      throw e;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}