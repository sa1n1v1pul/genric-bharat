import 'dart:io';

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
  final RxString pageContent = RxString('');
  final RxBool isPageLoading = RxBool(false);
  final RxString errorMessage = ''.obs;

  HomeController() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Accept': 'application/json',
    };

    // Add interceptor for retry logic
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.type == DioExceptionType.connectionError) {
            // Retry the request up to 3 times
            for (int i = 0; i < 3; i++) {
              try {
                final response = await _dio.request(
                  error.requestOptions.path,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  ),
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                );
                return handler.resolve(response);
              } catch (e) {
                if (i == 2) handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategoryItems();
    fetchCategories();
    fetchSliders();
  }

  Future<void> fetchPageContent(String slug) async {
    try {
      isPageLoading.value = true;
      final response = await _dio.get(
        '${ApiEndpoints.pagesGet}?slug=$slug',
      );

      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        // Assuming the first item contains the page details
        final pageData = response.data[0];
        pageContent.value = pageData['details'] ?? 'No content available.';
      } else {
        pageContent.value = 'Unable to fetch page content.';
      }
    } catch (e) {
      pageContent.value = 'Error loading content.';
    } finally {
      isPageLoading.value = false;
    }
  }

  Future<void> fetchCategoryItems() async {
    try {
      isCategoryItemsLoading.value = true;
      final response = await _dio.get(ApiEndpoints.categories_item);

      if (response.statusCode == 200 && response.data['status'] == true) {
        if (response.data['data'] is List) {
          categoryItems.value =
              List<Map<String, dynamic>>.from(response.data['data']);
        }
      }
    } catch (e) {
      // Error handling without print
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
        }
      }
    } catch (e) {
      // Error handling without print
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSubcategories(String categoryId) async {
    try {
      isSubcategoriesLoading.value = true;
      final url = '${ApiEndpoints.subcategories}?category_id=$categoryId';

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

      if (response.statusCode == 200) {
        if (response.data is Map && response.data['data'] is List) {
          subcategories.value =
              List<Map<String, dynamic>>.from(response.data['data']);
        } else {
          subcategories.value = [];
        }
      } else {
        subcategories.value = [];
      }
    } catch (e) {
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
        }
      }
    } catch (e) {
      // Error handling without print
    } finally {
      isSlidersLoading.value = false;
    }
  }

  Future<void> fetchItems(String categoryId, {String? subcategoryId}) async {
    try {
      isServicesLoading.value = true;
      errorMessage.value = '';

      String url = '${ApiEndpoints.services}?category_id=$categoryId';
      if (subcategoryId != null && subcategoryId != 'All') {
        url += '&subcategory_id=$subcategoryId';
      }

      final response = await _dio.get(
        url,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        if (response.data['data'] is List) {
          services.value =
              List<Map<String, dynamic>>.from(response.data['data']);
        } else {
          throw Exception('Invalid response format: expected a list');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMsg = 'Network error occurred';

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMsg = 'Connection timed out';
          break;
        case DioExceptionType.receiveTimeout:
          errorMsg = 'Server is not responding';
          break;
        case DioExceptionType.connectionError:
          errorMsg = 'Cannot connect to the server';
          break;
        default:
          errorMsg = e.message ?? 'An unexpected error occurred';
      }

      errorMessage.value = errorMsg;
      services.value = [];
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      services.value = [];
    } finally {
      isServicesLoading.value = false;
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
