import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api_endpoints/api_endpoints.dart';
import '../home/controller/homecontroller.dart';
import 'service_explore.dart';

class AllCategories extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();

  AllCategories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.grey[550]
          : const Color.fromARGB(255, 244, 243, 248),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: isDarkMode
              ? const Color.fromARGB(255, 244, 243, 248)
              : Colors.black,
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            final ThemeData theme = Theme.of(context);
            final bool isDarkMode = theme.brightness == Brightness.dark;

            return Container(
              padding: const EdgeInsets.only(left: 4),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? Colors.black : Colors.white)
                        .withOpacity(0.3),
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
            );
          },
        ),
        toolbarHeight: 80,
        title: const Text(
          'Categories',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Obx(() {
        if (homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeController.categories.isEmpty) {
          return const Center(child: Text('No Categories available'));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          padding: const EdgeInsets.all(16),
          itemCount: homeController.categories.length,
          itemBuilder: (context, index) {
            final category = homeController.categories[index];
            return InkWell(
              onTap: () {
                homeController.fetchSubcategories(category['id'].toString());
                Get.to(() => ServiceExplore(
                  categoryId: category['id'].toString(),
                  categoryTitle: category['name'] ?? 'Unknown Category',
                ));
              },
              child: _buildCategoriesItem(
                category['photo'] != null
                    ? '${ApiEndpoints.imageBaseUrl}${category['photo']}'
                    : '',
                category['name'] ?? 'Unknown Category',
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCategoriesItem(String imagePath, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          elevation: 4,
          shadowColor: Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            width: 120,
            height: 100,
            child: imagePath.isNotEmpty
                ? Image.network(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/temp1.png',
                  fit: BoxFit.cover,
                );
              },
            )
                : Image.asset(
              'assets/images/temp1.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}