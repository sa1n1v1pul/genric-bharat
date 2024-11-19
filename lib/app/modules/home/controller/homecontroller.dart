import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../../api_endpoints/api_endpoints.dart';

class HomeController extends GetxController {
  final Dio _dio = Dio();
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> subcategories =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> sliders = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubcategoriesLoading = true.obs;
  final RxBool isSlidersLoading = true.obs;
  final RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;
  final RxBool isServicesLoading = true.obs;
  final RxList<Map<String, dynamic>> providers = <Map<String, dynamic>>[].obs;
  final RxBool isProvidersLoading = true.obs;
  final RxList<Map<String, dynamic>> categoryItems =
      <Map<String, dynamic>>[].obs;
  final RxBool isCategoryItemsLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategoryItems();
    fetchCategories();
    fetchSliders();
  }

  Future<void> fetchCategoryItems() async {
    try {
      isCategoryItemsLoading.value = true;
      final response = await _dio.get(ApiEndpoints.categories_item);

      if (response.statusCode == 200 && response.data['status'] == true) {
        if (response.data['data'] is List) {
          categoryItems.value =
              List<Map<String, dynamic>>.from(response.data['data']);

          // Debug print for category names
          print("Available Categories:");
          for (var category in categoryItems) {
            print("- ${category['category_name']}");
          }
        } else {
          print('Unexpected response structure: ${response.data}');
        }
      }
    } catch (e) {
      print('Error fetching category items: $e');
    } finally {
      isCategoryItemsLoading.value = false;
    }
  }

  // Get items for a specific category
  List<Map<String, dynamic>> getItemsForCategory(String categoryName) {
    try {
      final category = categoryItems.firstWhere(
        (element) => element['category_name'] == categoryName,
        orElse: () => {'items': []},
      );
      return List<Map<String, dynamic>>.from(category['items'] ?? []);
    } catch (e) {
      print('Error getting items for category $categoryName: $e');
      return [];
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await _dio.get(ApiEndpoints.categories);

      if (response.statusCode == 200 && response.data['status'] == true) {
        if (response.data['data'] is List) {
          categories.value =
              List<Map<String, dynamic>>.from(response.data['data']);
          print("Fetching categories successfully: ${response.data['data']}");
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
      if (response.statusCode == 200) {
        if (response.data is Map && response.data['data'] is List) {
          subcategories.value =
              List<Map<String, dynamic>>.from(response.data['data']);
          print(
              'Successfully fetched ${subcategories.value.length} subcategories');
        } else {
          print(
              'Unexpected response structure. Expected a List but got ${response.data.runtimeType}');
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

  Future<void> fetchSliders() async {
    try {
      isSlidersLoading.value = true;
      final response = await _dio.get(ApiEndpoints.sliders);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final List<dynamic> slidersList = responseData['data'];
          sliders.value = List<Map<String, dynamic>>.from(slidersList);
          print("Fetched sliders successfully: ${sliders.length}");
        } else {
          print('Unexpected response structure: $responseData');
        }
      }
    } catch (e) {
      print('Error fetching sliders: $e');
    } finally {
      isSlidersLoading.value = false;
    }
  }

  Future<void> fetchItems(String categoryId, {String? subcategoryId}) async {
    try {
      isServicesLoading.value = true;
      String url = '${ApiEndpoints.services}?category_id=$categoryId';
      if (subcategoryId != null && subcategoryId != 'All') {
        url += '&subcategory_id=$subcategoryId';
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
      final url =
          '${ApiEndpoints.providersList}?service_id=$serviceId&id=$userId';
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

class SliderModel {
  final int id;
  final String photo;
  final String? title;
  final String? link;
  final String? logo;
  final String? details;
  final String? createdAt;
  final String? updatedAt;
  final String? homePage;

  SliderModel({
    required this.id,
    required this.photo,
    this.title,
    this.link,
    this.logo,
    this.details,
    this.createdAt,
    this.updatedAt,
    this.homePage,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'] ?? 0,
      photo: json['photo'] ?? '',
      title: json['title'],
      link: json['link'],
      logo: json['logo'],
      details: json['details'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      homePage: json['home_page'],
    );
  }
}
