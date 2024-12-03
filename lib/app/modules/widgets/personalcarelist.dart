import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';
import '../api_endpoints/api_endpoints.dart';
import '../home/controller/homecontroller.dart';
import 'medicinedetailsheet.dart';

class PersonalCareListScreen extends StatelessWidget {
  const PersonalCareListScreen({Key? key}) : super(key: key);
  String getCompleteImageUrl(String photoPath) {
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    return '${ApiEndpoints.imageBaseUrl}$photoPath';
  }
  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Adjust text sizes based on scale factor
    final titleSize = (20 / textScaleFactor).clamp(16.0, 20.0);
    final itemTitleSize = (14 / textScaleFactor).clamp(12.0, 14.0);
    final priceSize = (14 / textScaleFactor).clamp(12.0, 14.0);
    final discountSize = (12 / textScaleFactor).clamp(10.0, 12.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.only(left: 4),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? Colors.black : Colors.grey)
                        .withOpacity(0.3),
                    spreadRadius: 2,
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
        title: Text(
          'Beauty & Personal Care',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 80,
      ),
      body: Obx(() {
        final items = controller.getItemsForCategory("Beauty & Personal Care");

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75 * (1 / textScaleFactor).clamp(0.8, 1.0),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildGridItem(
              context,
              item,
              isDarkMode,
              itemTitleSize,
              priceSize,
              discountSize,
            );
          },
        );
      }),
    );
  }

  Widget _buildGridItem(
      BuildContext context,
      Map<String, dynamic> item,
      bool isDarkMode,
      double titleSize,
      double priceSize,
      double discountSize,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
              builder: (context, scrollController) => MedicineDetailsSheet(
                service: item,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                getCompleteImageUrl(item['photo']),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${item['discount_price']}',
                    style: TextStyle(
                      fontSize: priceSize,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item['original_price'] != null)
                    Row(
                      children: [
                        Text(
                          '₹${item['original_price']}',
                          style: TextStyle(
                            fontSize: discountSize,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${calculateDiscount(item['original_price'], item['discount_price'])}% off',
                          style: TextStyle(
                            fontSize: discountSize,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int calculateDiscount(dynamic originalPrice, dynamic discountPrice) {
    if (originalPrice == null || discountPrice == null) return 0;
    final original = double.parse(originalPrice.toString());
    final discount = double.parse(discountPrice.toString());
    return ((original - discount) / original * 100).round();
  }
}