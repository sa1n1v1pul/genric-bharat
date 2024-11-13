import 'package:flutter/material.dart';
import 'package:genric_bharat/app/core/theme/theme.dart';
import 'package:get/get.dart';
import '../api_endpoints/api_endpoints.dart';

class MedicineDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> service;

  const MedicineDetailsSheet({
    Key? key,
    required this.service,
  }) : super(key: key);

  String _getFullImageUrl(String photoPath) {
    if (photoPath.isEmpty) return '';
    return '${ApiEndpoints.imageBaseUrl}$photoPath';
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    final String title = service['name'] ?? 'Untitled';
    final String photoPath = service['photo'] ?? '';
    final String imagePath = _getFullImageUrl(photoPath);

    // Use the new parsing methods for numeric values
    final double previousPrice = _parseDouble(service['previous_price']);
    final double discountPrice = _parseDouble(service['discount_price']);
    final int stock = _parseInt(service['stock']);
    final int discountPercentage = _parseInt(service['discount_percentage']);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Flexible(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Medicine details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Medicine Image
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Center(
                      child: Image.network(
                        imagePath,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                    if (discountPercentage > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$discountPercentage% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (stock <= 10)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Only ${stock} left',
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

                // Medicine Title and Stock Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 16,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'In Stock: $stock units',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price Details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Discounted Price
                          Text(
                            '₹${discountPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Original Price
                          if (previousPrice > 0)
                            Text(
                              '₹${previousPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Add to Cart Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: stock > 0
                              ? () {
                            // Add to cart functionality
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: stock > 0
                                ? CustomTheme.loginGradientStart
                                : Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            stock > 0 ? 'Add to Cart' : 'Out of Stock',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Additional Details
                if (service['category_id'] != null)
                  _buildDetailSection(
                    'Category',
                    'Category ID: ${service['category_id']}',
                    Icons.category,
                  ),
                if (service['subcategory_id'] != null)
                  _buildDetailSection(
                    'Subcategory',
                    'Subcategory ID: ${service['subcategory_id']}',
                    Icons.subdirectory_arrow_right,
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Get.isDarkMode ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      color: Get.isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}