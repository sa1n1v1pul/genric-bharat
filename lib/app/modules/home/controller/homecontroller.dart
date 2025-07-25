import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

import '../../api_endpoints/api_endpoints.dart';

class HomeController extends GetxController {
  final Dio _dio = Dio();
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> subcategories =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> sliders =
      <Map<String, dynamic>>[].obs; // Add this line
  final RxBool isLoading = true.obs;
  final RxBool isSubcategoriesLoading = true.obs;
  final RxBool isSlidersLoading = true.obs;
  final RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;
  final RxBool isServicesLoading = true.obs;
  final RxList<Map<String, dynamic>> providers = <Map<String, dynamic>>[].obs;
  final RxBool isProvidersLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchSliders();
  }

  //fetch categories
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await _dio.get(ApiEndpoints.categories);
      if (response.statusCode == 200) {
        if (response.data is List) {
          categories.value = List<Map<String, dynamic>>.from(response.data);
          print("Fetching categories successfully: ${response.data}");
        } else {
          print('Unexpected response structure: ${response.data}');
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  //fetch subcategories
  Future<void> fetchSubcategories(String categoryId) async {
    try {
      isSubcategoriesLoading.value = true;
      final url = '${ApiEndpoints.subcategories}?category_id=$categoryId';
      print('Fetching subcategories from: $url');

      final response = await _dio.get(
        url,
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      print('Response status code: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');
      // print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic> &&
            response.data['data'] is List) {
          subcategories.value =
              List<Map<String, dynamic>>.from(response.data['data']);
          print(
              "Fetching subcategories successfully: ${response.data['data']}");
        } else {
          print(
              'Unexpected response structure. Data is not in the expected format.');
          subcategories.value = [];
        }
      } else {
        print('Unexpected response status: ${response.statusCode}');
        subcategories.value = [];
      }
    } catch (e) {
      print('Error fetching subcategories: $e');
      if (e is dio.DioException) {
        print('DioException details: ${e.message}');
        print('DioException response: ${e.response}');
      }
      subcategories.value = [];
    } finally {
      isSubcategoriesLoading.value = false;
    }
  }

  //fetch sliders data
  Future<void> fetchSliders() async {
    try {
      isSlidersLoading.value = true;
      final response = await _dio.get(ApiEndpoints.sliders);
      if (response.statusCode == 200) {
        if (response.data is List) {
          sliders.value = List<Map<String, dynamic>>.from(response.data);
          print("Fetching sliders successfully: ${response.data}");
        } else {
          print('Unexpected response structure: ${response.data}');
        }
      }
    } catch (e) {
      print('Error fetching sliders: $e');
    } finally {
      isSlidersLoading.value = false;
    }
  }

  //fetch services
  Future<void> fetchServices(String categoryId, {String? subcategoryId}) async {
    try {
      isServicesLoading.value = true;
      String url = '${ApiEndpoints.services}?category_id=$categoryId';
      if (subcategoryId != null && subcategoryId != 'All') {
        url += '&sub_category_id=$subcategoryId';
      }

      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data['data'] is List) {
        services.value = List<Map<String, dynamic>>.from(response.data['data']);
        print("Fetching services successfully: ${response.data}");
      } else {
        print('Unexpected response structure: ${response.data}');
        services.value = [];
      }
    } catch (e) {
      print('Error fetching services: $e');
      services.value = [];
    } finally {
      isServicesLoading.value = false;
    }
  }


  Future<void> fetchProviders(String serviceId, String userId) async {
    try {
      isProvidersLoading.value = true;
      final url = '${ApiEndpoints.providersList}?service_id=$serviceId&id=$userId';
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data is List) {
        providers.value = List<Map<String, dynamic>>.from(response.data);
        print("Fetching providers successfully: ${response.data}");
      } else {
        print('Unexpected response structure: ${response.data}');
        providers.value = [];
      }
    } catch (e) {
      print('Error fetching providers: $e');
      providers.value = [];
    } finally {
      isProvidersLoading.value = false;
    }
  }
}

