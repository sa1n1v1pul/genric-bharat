import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';
import '../api_endpoints/api_endpoints.dart';
import '../home/controller/homecontroller.dart';
import 'medicinedetailsheet.dart';

class BestOffers extends StatelessWidget {
  const BestOffers({super.key});
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
    final priceSize = (16 / textScaleFactor).clamp(14.0, 16.0);

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
          'Best Offers',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 80,
      ),
      body: Obx(() {
        final bestDealProducts =
            controller.getItemsForCategory("BEST DEAL PRODUCTS");

        if (controller.isCategoryItemsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bestDealProducts.isEmpty) {
          return Center(
            child: Text(
              'No offers available at the moment',
              style: TextStyle(fontSize: itemTitleSize),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75 * (1 / textScaleFactor).clamp(0.8, 1.0),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: bestDealProducts.length,
          itemBuilder: (context, index) {
            final product = bestDealProducts[index];
            return _buildOfferCard(
              context,
              product,
              itemTitleSize,
              priceSize,
            );
          },
        );
      }),
    );
  }

  Widget _buildOfferCard(
    BuildContext context,
    Map<String, dynamic> product,
    double titleSize,
    double priceSize,
  ) {
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
              service: product,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  getCompleteImageUrl(product['photo']),
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
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${product['discount_price']}',
                      style: TextStyle(
                        fontSize: priceSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (product['previous_price'] != 0)
                      Text(
                        '₹${product['previous_price']}',
                        style: TextStyle(
                          fontSize: titleSize * 0.85,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
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
