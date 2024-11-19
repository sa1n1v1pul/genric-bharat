import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';
import '../api_endpoints/api_endpoints.dart';
import '../home/controller/homecontroller.dart';
import 'medicinedetailsheet.dart';

class AllVitaminsScreen extends StatelessWidget {
  AllVitaminsScreen({Key? key}) : super(key: key);

  final HomeController controller = Get.find<HomeController>();
  final searchController = TextEditingController();
  final RxList<Map<String, dynamic>> filteredItems = RxList<Map<String, dynamic>>([]);
  final RxBool isSearching = false.obs;
  String getCompleteImageUrl(String photoPath) {
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    return '${ApiEndpoints.imageBaseUrl}$photoPath';
  }
  void filterItems(String query) {
    if (query.isEmpty) {
      filteredItems.value = controller.getItemsForCategory("MULTIVITAMINS AND MULTIMINERALS");
    } else {
      final items = controller.getItemsForCategory("MULTIVITAMINS AND MULTIMINERALS");
      filteredItems.value = items.where((item) {
        final name = item['name'].toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Initialize filtered items
    if (filteredItems.isEmpty) {
      filteredItems.value = controller.getItemsForCategory("MULTIVITAMINS AND MULTIMINERALS");
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: Container(
          padding: const EdgeInsets.only(left: 4),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? Colors.black : Colors.white).withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
          ),
        ),
        toolbarHeight: 80,
        title: Obx(
              () => isSearching.value
              ? TextField(
            controller: searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search vitamins...',
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onChanged: filterItems,
          )
              : const Text(
            'Vitamins & Supplements',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isSearching.value ? Icons.close : Icons.search,color: Colors.black,),
            onPressed: () {
              isSearching.toggle();
              if (!isSearching.value) {
                searchController.clear();
                filterItems('');
              }
            },
          ),
        ],
      ),

        body: Obx(() {
        if (controller.isCategoryItemsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (filteredItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_information,
                  size: 64,
                  color: isDarkMode ? Colors.white54 : Colors.black54,
                ),
                const SizedBox(height: 16),
                Text(
                  'No items found',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchCategoryItems();
            filterItems(searchController.text);
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return _buildItemCard(context, item, isDarkMode);
            },
          ),
        );
      }),
    );
  }

  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.6,
            maxChildSize: 0.8,
            builder: (context, scrollController) => MedicineDetailsSheet(
              service: item,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  getCompleteImageUrl(item['photo'] ?? ''),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
            ),
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Unknown Product',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '₹${item['discount_price']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.green[300] : Colors.green[700],
                          ),
                        ),
                        if (item['previous_price'] != null &&
                            item['previous_price'] != 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '₹${item['previous_price']}',
                            style: TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: isDarkMode ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item['discount_percentage'] != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.amber[700] : Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item['discount_percentage']}% OFF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}