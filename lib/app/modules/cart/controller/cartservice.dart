import 'package:genric_bharat/app/modules/api_endpoints/api_endpoints.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartApiService extends GetxService {
  RxBool isInitialized = false.obs;
  final RxnInt userId = RxnInt();
  @override
  void onInit() async {
    super.onInit();
    await initializeService();
  }

  Future<void> initializeService() async {
    try {
      // Add a retry mechanism
      int maxRetries = 3;
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        final retrievedUserId = await getUserId();
        if (retrievedUserId != null) {
          userId.value = retrievedUserId;
          isInitialized.value = true;
          print('🔍 CartApiService initialized with userId: $retrievedUserId');
          return;
        }

        // Wait a bit before retrying
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }

      print('⚠️ CartApiService could not retrieve userId after $maxRetries attempts');
    } catch (e) {
      print('❌ Error initializing CartApiService: $e');
    }
  }

  Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('user_id');

      // If no userId is found, wait and check again
      if (storedUserId == null) {
        // Potential race condition mitigation
        await Future.delayed(Duration(milliseconds: 200));
        return prefs.getInt('user_id');
      }

      print('🔍 Retrieved userId: $storedUserId');
      return storedUserId;
    } catch (e) {
      print('❌ Error getting userId: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> addToCart(String itemId, int quantity) async {
    try {
      print('📝 Starting addToCart request');
      print('Parameters - itemId: $itemId, quantity: $quantity');

      final userId = await getUserId();
      if (userId == null) {
        print('❌ User ID is null');
        throw Exception('User not logged in');
      }

      var request = http.MultipartRequest('POST', Uri.parse(ApiEndpoints.addToCart));
      print('🌐 API URL: ${request.url}');

      request.fields.addAll({
        'user_id': userId.toString(),
        'item_id': itemId,
        'quantity': quantity.toString(),
      });
      print('📦 Request fields: ${request.fields}');

      print('⏳ Sending request...');
      var response = await request.send();
      print('📥 Response status code: ${response.statusCode}');

      var responseData = await response.stream.bytesToString();
      print('📄 Raw response: $responseData');

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to add to cart: Server returned ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error in addToCart: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<Map<String, dynamic>> getCart() async {
    try {
      print('📝 Starting getCart request');

      final userId = await getUserId();
      if (userId == null) {
        print('❌ User ID is null');
        throw Exception('User not logged in');
      }

      final url = '${ApiEndpoints.getCart}?user_id=$userId';
      print('🌐 API URL: $url');

      print('⏳ Sending request...');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );
      print('📥 Response status code: ${response.statusCode}');
      print('📄 Raw response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('❌ Non-200 status code received');
        throw Exception('Failed to load cart: Server returned ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error in getCart: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get cart: $e');
    }
  }

  Future<Map<String, dynamic>> clearAllCart() async {
    try {
      print('🗑️ Starting clearAllCart request');

      final userId = await getUserId();
      if (userId == null) {
        print('❌ User ID is null');
        throw Exception('User not logged in');
      }

      final queryParameters = {
        'user_id': userId.toString(),
      };

      final uri = Uri.parse(ApiEndpoints.clearCart)
          .replace(queryParameters: queryParameters);
      print('🌐 API URL: $uri');

      print('⏳ Sending request...');
      final response = await http.delete(uri);
      print('📥 Response status code: ${response.statusCode}');
      print('📄 Raw response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('❌ Non-200 status code received');
        throw Exception('Failed to clear all cart items');
      }
    } catch (e, stackTrace) {
      print('❌ Error in clearAllCart: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to clear all cart items: $e');
    }
  }

  Future<Map<String, dynamic>> clearCartItem(String itemId) async {
    try {
      print('🗑️ Starting clearCartItem request for item: $itemId');

      final userId = await getUserId();
      if (userId == null) {
        print('❌ User ID is null');
        throw Exception('User not logged in');
      }

      final queryParameters = {
        'user_id': userId.toString(),
        'item_id': itemId,
      };

      final uri = Uri.parse(ApiEndpoints.clearCart)
          .replace(queryParameters: queryParameters);
      print('🌐 API URL: $uri');

      print('⏳ Sending request...');
      final response = await http.delete(uri);
      print('📥 Response status code: ${response.statusCode}');
      print('📄 Raw response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('❌ Non-200 status code received');
        throw Exception('Failed to clear cart item');
      }
    } catch (e, stackTrace) {
      print('❌ Error in clearCartItem: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to clear cart item: $e');
    }
  }
}