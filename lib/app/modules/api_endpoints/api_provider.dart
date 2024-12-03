import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'api_endpoints.dart';

class ApiProvider extends GetxController {
  late dio.Dio _dio;
  final int maxRetries = 3;
  final Duration retryDelay = const Duration(seconds: 2);
  final Duration connectionTimeout = const Duration(seconds: 30);

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  Future<dio.Response> postOrderCODConfirmation(String endpoint, Map<String, dynamic> data) async {
    return _handleRequest(() async {
      final token = await getToken();
      print('Sending order data to API: $data');

      return await _dio.post(
        endpoint,
        data: data,
        options: dio.Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    });
  }

  Future<dio.Response> postOrderConfirmation(String endpoint, Map<String, dynamic> data) async {
    return _handleRequest(() async {
      final token = await getToken();
      print('Sending order data to API: $data');

      return await _dio.post(
        endpoint,
        data: data,
        options: dio.Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    });
  }

  Future<dio.Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _handleRequest(() async {
      final token = await getToken();
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: dio.Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    });
  }

  void _initializeDio() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: ApiEndpoints.apibaseUrl,
      connectTimeout: connectionTimeout,
      receiveTimeout: connectionTimeout,
      sendTimeout: connectionTimeout,
      validateStatus: (status) {
        return status! < 500; // Accept all status codes less than 500
      },
    ));

    _dio.interceptors.add(dio.LogInterceptor(
      responseBody: true,
      requestBody: true,
      requestHeader: true,
      error: true,
    ));

    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add retry count to options if not present
          options.extra['retryCount'] = options.extra['retryCount'] ?? 0;
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            return await _retryRequest(error, handler);
          }
          return handler.next(error);
        },
      ),
    );
  }

  bool _shouldRetry(dio.DioException error) {
    return error.type == dio.DioExceptionType.connectionTimeout ||
        error.type == dio.DioExceptionType.receiveTimeout ||
        error.type == dio.DioExceptionType.sendTimeout ||
        error.type == dio.DioExceptionType.connectionError ||
        (error.error is SocketException) ||
        (error.type == dio.DioExceptionType.unknown &&
            (error.error is TimeoutException || error.error is SocketException));
  }

  Future<void> _retryRequest(
      dio.DioException err, dio.ErrorInterceptorHandler handler) async {
    dio.RequestOptions requestOptions = err.requestOptions;
    int retryCount = (requestOptions.extra['retryCount'] ?? 0) + 1;

    if (retryCount <= maxRetries) {
      // Exponential backoff
      final delay = retryDelay * retryCount;
      print('Retry attempt $retryCount for ${requestOptions.path} after ${delay.inSeconds}s');
      await Future.delayed(delay);

      try {
        final newRequestOptions = dio.RequestOptions(
          path: requestOptions.path,
          method: requestOptions.method,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          headers: requestOptions.headers,
          extra: {...requestOptions.extra, 'retryCount': retryCount},
        );

        // Create a new Dio instance for retry to avoid interceptor loop
        final retryDio = dio.Dio(dio.BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: connectionTimeout,
          receiveTimeout: connectionTimeout,
          sendTimeout: connectionTimeout,
        ));

        final response = await retryDio.fetch(newRequestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (retryCount == maxRetries) {
          Get.snackbar(
            'Connection Error',
            'Unable to connect to server after multiple attempts. Please check your internet connection.',
            backgroundColor: Colors.red[100],
            colorText: Colors.black,
            duration: const Duration(seconds: 5),
          );
        }
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
  Future<dio.Response> checkPincode(String pincode) async {
    print('Checking pincode: $pincode');
    return _handleRequest(() async {
      final response = await _dio.get(
        ApiEndpoints.pincode_checking,
        queryParameters: {'pin_code': pincode},
      );
      print('Pincode check response: ${response.data}');
      return response;
    });
  }

  Future<dio.Response> _handleRequest(Future<dio.Response> Function() request) async {
    try {
      return await request();
    } on dio.DioException catch (e) {
      print('DioException details: ${e.message}');
      print('DioException type: ${e.type}');
      print('DioException response: ${e.response}');

      // Check if we've exceeded retry attempts
      if (e.requestOptions.extra['retryCount'] >= maxRetries) {
        String errorMessage = _getErrorMessage(e);
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
          duration: const Duration(seconds: 3),
        );
      }
      throw e;
    } catch (e) {
      print('Unexpected error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
        duration: const Duration(seconds: 3),
      );
      throw e;
    }
  }
  String _getErrorMessage(dio.DioException e) {
    if (e.error is SocketException) {
      final socketError = e.error as SocketException;
      if (socketError.osError?.errorCode == 104) {
        return 'Connection was reset. Please try again.';
      }
      return 'Network connection error. Please check your internet connection.';
    }

    switch (e.type) {
      case dio.DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case dio.DioExceptionType.receiveTimeout:
        return 'Server is taking too long to respond. Please try again.';
      case dio.DioExceptionType.sendTimeout:
        return 'Unable to send request. Please check your internet connection.';
      case dio.DioExceptionType.connectionError:
        return 'Connection error occurred. Please check your internet and try again.';
      case dio.DioExceptionType.badResponse:
        return _handleBadResponse(e.response?.statusCode);
      case dio.DioExceptionType.cancel:
        return 'Request was cancelled';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }String _handleBadResponse(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Unauthorized access. Please log in again.';
      case 403:
        return 'Access forbidden. Please check your permissions.';
      case 404:
        return 'Requested resource not found';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error occurred. Please try again later.';
      default:
        return 'Server returned an error: ${statusCode ?? "Unknown"}';
    }
  }

  Future<dio.Response> updateUserLocation(
      int userId, double latitude, double longitude) async {
    return _handleRequest(() async {
      final token = await getToken();
      return await _dio.put(
        '${ApiEndpoints.updateUserLocation}$userId/location',
        data: {
          'latitu': latitude,
          'longitu': longitude,
        },
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    });
  }

  Future<dio.Response> requestOtp(String mobileNumber) async {
    return _handleRequest(() async {
      return await _dio.post(
        ApiEndpoints.requestOtp,
        data: {'mobile_number': mobileNumber},
      );
    });
  }

  Future<dio.Response> verifyOtp(
      String mobileNumber, String otp, int? id) async {
    return _handleRequest(() async {
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
    });
  }

  Future<dio.Response> getOtp(String mobileNumber) async {
    return _handleRequest(() async {
      return await _dio.get(
        ApiEndpoints.getOtp,
        queryParameters: {'mobile_number': mobileNumber},
      );
    });
  }

  Future<dio.Response> updateAddress(Map<String, String> addressData) async {
    print('Updating address with data: $addressData');
    return _handleRequest(() async {
      final token = await getToken();
      final formData = dio.FormData.fromMap(addressData);

      final response = await _dio.post(
        ApiEndpoints.address_update,
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('Address update response: ${response.data}');
      return response;
    });
  }

  Future<dio.Response> getUserProfile(int userId) async {
    print('Fetching user profile for ID: $userId');
    return _handleRequest(() async {
      final token = await getToken();
      final response = await _dio.get(
        '${ApiEndpoints.profile}?id=$userId',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('User profile response: ${response.data}');
      return response;
    });
  }

  Future<dio.Response> updateUserProfile(
      int userId, Map<String, dynamic> userData, {File? profileImage}) async {
    return _handleRequest(() async {
      final token = await getToken();

      if (profileImage != null) {
        // Create form data for multipart request
        final formData = dio.FormData.fromMap({
          ...userData,
          'profile': await dio.MultipartFile.fromFile(
            profileImage.path,
            filename: 'profile_image.jpg',
          ),
        });

        return await _dio.post(
          '${ApiEndpoints.profile_update}$userId',
          data: formData,
          options: dio.Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'multipart/form-data',
            },
          ),
        );
      } else {
        // Regular JSON request without image
        return await _dio.post(
          '${ApiEndpoints.profile_update}$userId',
          data: userData,
          options: dio.Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );
      }
    });
  }


  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

class UserService extends GetxService {
  final RxInt userId = 0.obs;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getInt('user_id');

    if (savedUserId != null && savedUserId > 0) {
      userId.value = savedUserId;
      print('Initialized UserService with User ID: $savedUserId');
    } else {
      print('No valid user ID found in SharedPreferences');
    }
  }

  int getCurrentUserId() {
    return userId.value;
  }
}