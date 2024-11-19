import 'package:dio/dio.dart';
import 'package:genric_bharat/app/modules/api_endpoints/api_endpoints.dart';
import 'package:get/get.dart';
import 'dart:async';

class ProductSearchController extends GetxController {
  final Dio _dio = Dio();

  final RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isCompositionSearch = false.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt perPage = 10.obs;
  final RxInt total = 0.obs;

  Timer? _debounce;

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void resetSearch() {
    searchResults.clear();
    currentPage.value = 1;
    lastPage.value = 1;
    total.value = 0;
    isCompositionSearch.value = false;
  }

  Future<void> searchItems(String query, {bool isNewSearch = true, bool? isComposition}) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        if (query.isEmpty) {
          resetSearch();
          return;
        }

        if (isNewSearch) {
          resetSearch();
          if (isComposition != null) {
            isCompositionSearch.value = isComposition;
          }
        }

        if (!isNewSearch && currentPage.value > lastPage.value) {
          return;
        }

        isLoading.value = true;
        searchQuery.value = query;

        // Prepare query parameters based on search type
        Map<String, dynamic> queryParams = {
          'per_page': perPage.value,
          'page': currentPage.value,
        };

        if (isCompositionSearch.value) {
          queryParams['composition_search'] = query;
        } else {
          queryParams['name'] = query;
          queryParams['search'] = query;
        }

        final response = await _dio.get(
          ApiEndpoints.search,
          queryParameters: queryParams,
          options: Options(
            headers: {'Accept': 'application/json'},
            validateStatus: (status) => status! < 500,
          ),
        );

        if (response.statusCode == 200) {
          final responseData = response.data;
          if (responseData is Map &&
              responseData['status'] == 'success' &&
              responseData['data'] is Map) {

            // Update pagination info
            if (responseData['data']['pagination'] != null) {
              final pagination = responseData['data']['pagination'];
              currentPage.value = pagination['current_page'] ?? 1;
              lastPage.value = pagination['last_page'] ?? 1;
              perPage.value = pagination['per_page'] ?? 10;
              total.value = pagination['total'] ?? 0;
            }

            // Handle search results
            if (responseData['data']['items'] is List) {
              if (isNewSearch) {
                searchResults.clear();
              }

              final newItems = List<Map<String, dynamic>>.from(responseData['data']['items']);

              // Add new items while avoiding duplicates
              for (var newItem in newItems) {
                if (!searchResults.any((existingItem) => existingItem['id'] == newItem['id'])) {
                  searchResults.add(newItem);
                }
              }
            }
          }
        } else {
          print('Error status code: ${response.statusCode}');
          if (isNewSearch) {
            searchResults.clear();
          }
        }
      } catch (e) {
        print('Error searching items: $e');
        if (isNewSearch) {
          searchResults.clear();
        }
      } finally {
        isLoading.value = false;
      }
    });
  }

  Future<void> loadMore() async {
    if (!isLoading.value && currentPage.value < lastPage.value) {
      currentPage.value++;
      await searchItems(searchQuery.value, isNewSearch: false);
    }
  }
}