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
    ever(userId, (id) {
      if (id != null) {
        isInitialized.value = true;
      }
    });
  }

  Future<void> initializeService() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('user_id');

      if (storedUserId != null) {
        userId.value = storedUserId;
        isInitialized.value = true;
      }
    } catch (e) {
      // Error handling preserved without print
    }
  }

  Future<void> initializeWithUserId(int newUserId) async {
    try {
      userId.value = newUserId;
      isInitialized.value = true;
    } catch (e) {
      // Error handling preserved without print
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

      return storedUserId;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> addToCart(String itemId, int quantity) async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      var request =
          http.MultipartRequest('POST', Uri.parse(ApiEndpoints.addToCart));

      request.fields.addAll({
        'user_id': userId.toString(),
        'item_id': itemId,
        'quantity': quantity.toString(),
      });

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception(
            'Failed to add to cart: Server returned ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<Map<String, dynamic>> getCart() async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final url = '${ApiEndpoints.getCart}?user_id=$userId';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load cart: Server returned ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  Future<Map<String, dynamic>> clearAllCart() async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final queryParameters = {
        'user_id': userId.toString(),
      };

      final uri = Uri.parse(ApiEndpoints.clearCart)
          .replace(queryParameters: queryParameters);

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to clear all cart items');
      }
    } catch (e) {
      throw Exception('Failed to clear all cart items: $e');
    }
  }

  Future<Map<String, dynamic>> clearCartItem(String itemId) async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final queryParameters = {
        'user_id': userId.toString(),
        'item_id': itemId,
      };

      final uri = Uri.parse(ApiEndpoints.clearCart)
          .replace(queryParameters: queryParameters);

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to clear cart item');
      }
    } catch (e) {
      throw Exception('Failed to clear cart item: $e');
    }
  }
}
