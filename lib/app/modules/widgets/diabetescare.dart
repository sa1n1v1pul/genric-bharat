import 'package:flutter/material.dart';
import 'package:genric_bharat/app/modules/api_endpoints/api_endpoints.dart';
import 'package:genric_bharat/app/modules/home/controller/homecontroller.dart';
import 'package:genric_bharat/app/modules/widgets/medicinedetailsheet.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';

class DiabetesCareProductsScreen extends StatelessWidget {
  const DiabetesCareProductsScreen({Key? key}) : super(key: key);

  String getCompleteImageUrl(String photoPath) {
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    return '${ApiEndpoints.imageBaseUrl}$photoPath';
  }

  Widget _buildDiabetesCard({
    required String title,
    required String discount,
    required String imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  discount,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Image.network(
                getCompleteImageUrl(imageUrl),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
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
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        toolbarHeight: 80,
        title: const Text(
          'Diabetes Care Products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      body: Obx(() {
        final diabetesItems =
        controller.getItemsForCategory("SUGAR AND ANTI DIABETES MEDICINES");

        if (diabetesItems.isEmpty) {
          return const Center(
            child: Text('No products available'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: diabetesItems.length,
          itemBuilder: (context, index) {
            final item = diabetesItems[index];
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
                    builder: (context, scrollController) =>
                        MedicineDetailsSheet(
                          service: item,
                        ),
                  ),
                );
              },
              child: _buildDiabetesCard(
                title: item['name'],
                discount: item['previous_price'] != 0
                    ? 'Save ₹${(item['previous_price'] - item['discount_price']).toStringAsFixed(0)}'
                    : 'Up to 20% off',
                imageUrl: item['photo'],
              ),
            );
          },
        );
      }),
    );
  }
}