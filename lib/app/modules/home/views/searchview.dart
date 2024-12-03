import 'package:flutter/material.dart';
import 'package:genric_bharat/app/modules/api_endpoints/api_endpoints.dart';
import 'package:genric_bharat/app/modules/widgets/medicinedetailsheet.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../controller/search_controller.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductSearchController searchController = Get.put(ProductSearchController());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 500) {
      searchController.loadMore();
    }
  }

  String getFormattedPrice(dynamic price) {
    if (price == null) return 'N/A';
    return '₹${price.toString()}';
  }

  void _performSearch(String value) {
    if (value.length >= 2) {
      searchController.searchItems(
        value,
        isNewSearch: true,
        isComposition: searchController.isCompositionSearch.value,
      );
    } else if (value.isEmpty) {
      searchController.resetSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Search Products',
          style: TextStyle(color: Colors.black45),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: CustomTheme.appBarGradient,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black45,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchTextController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search medicines, categories...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _performSearch,
                ),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => ChoiceChip(
                      label: const Text('Name'),
                      selected: !searchController.isCompositionSearch.value,
                      onSelected: (selected) {
                        if (selected) {
                          searchController.isCompositionSearch.value = false;
                          if (_searchTextController.text.length >= 2) {
                            _performSearch(_searchTextController.text);
                          }
                        }
                      },
                    )),
                    const SizedBox(width: 8),
                    Obx(() => ChoiceChip(
                      label: const Text('Composition'),
                      selected: searchController.isCompositionSearch.value,
                      onSelected: (selected) {
                        if (selected) {
                          searchController.isCompositionSearch.value = true;
                          if (_searchTextController.text.length >= 2) {
                            _performSearch(_searchTextController.text);
                          }
                        }
                      },
                    )),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (searchController.isLoading.value &&
                  searchController.searchResults.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (searchController.searchResults.isEmpty) {
                if (searchController.searchQuery.value.isEmpty) {
                  return const Center(
                    child: Text('Enter at least 2 characters to search'),
                  );
                }
                return const Center(
                  child: Text('No results found'),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Found ${searchController.total} results',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Page ${searchController.currentPage} of ${searchController.lastPage}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: searchController.searchResults.length +
                          (searchController.isLoading.value ? 1 : 0),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        if (index == searchController.searchResults.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final item = searchController.searchResults[index];
                        final discount = item['discount_percentage']?.toString() ?? '0';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => DraggableScrollableSheet(
                                  initialChildSize: 0.8,
                                  minChildSize: 0.6,
                                  maxChildSize: 0.8,
                                  builder: (context, scrollController) =>
                                      MedicineDetailsSheet(
                                        service: item,
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              item['photo']?.toString()?.startsWith('http') == true
                                                  ? item['photo']
                                                  : '${ApiEndpoints.imageBaseUrl}${item['photo']}',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      if (discount != '0')
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '$discount% OFF',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] ?? 'No name',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (item['category_name'] != null)
                                          Text(
                                            '${item['category_name']}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        if (item['subcategory_name'] != null)
                                          Text(
                                            '${item['subcategory_name']}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              getFormattedPrice(item['discount_price']),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (item['previous_price'] != null)
                                              Text(
                                                getFormattedPrice(item['previous_price']),
                                                style: const TextStyle(
                                                  decoration: TextDecoration.lineThrough,
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (item['sort_details'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              item['sort_details'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        if (searchController.isCompositionSearch.value &&
                                            item['composition'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              'Composition: ${item['composition']}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
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
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}