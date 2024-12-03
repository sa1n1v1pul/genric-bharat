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
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Adjust text sizes based on scale factor
    final titleSize = (14 / textScaleFactor).clamp(12.0, 14.0);
    final priceSize = (16 / textScaleFactor).clamp(14.0, 16.0);
    final discountSize = (10 / textScaleFactor).clamp(8.0, 10.0);

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
                fontSize: titleSize,
              ),
            ),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: titleSize,
            ),
            onChanged: filterItems,
          )
              : Text(
            'Vitamins & Supplements',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isSearching.value ? Icons.search : Icons.search,color: Colors.black54,),
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
                    fontSize: titleSize,
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.80 * (1 / textScaleFactor).clamp(0.8, 0.9),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return _buildItemCard(context, item, isDarkMode, titleSize, priceSize, discountSize);
            },
          ),
        );
      }),
    );
  }

  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item, bool isDarkMode,
      double titleSize, double priceSize, double discountSize) {
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
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      getCompleteImageUrl(item['photo'] ?? ''),
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  // Discount Tag
                  if (item['discount_percentage'] != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.amber[700] : Colors.green[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item['discount_percentage']}% OFF',
                          style: TextStyle(
                            fontSize: discountSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      item['name'] ?? 'Unknown Product',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(), // This will push the price to the bottom
                    // Price Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item['previous_price'] != null &&
                            item['previous_price'] != 0)
                          Text(
                            '₹${item['previous_price']}',
                            style: TextStyle(
                              fontSize: titleSize * 0.85,
                              decoration: TextDecoration.lineThrough,
                              color: isDarkMode ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        Text(
                          '₹${item['discount_price']}',
                          style: TextStyle(
                            fontSize: priceSize,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.green[300] : Colors.green[700],
                          ),
                        ),
                      ],
                    ),
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