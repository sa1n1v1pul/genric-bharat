import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api_endpoints/api_endpoints.dart';
import 'package:genric_bharat/app/core/theme/theme.dart';

import '../cart/controller/cartcontroller.dart';
import '../cart/view/cartscreen.dart';

class MedicineDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> service;

  const MedicineDetailsSheet({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<MedicineDetailsSheet> createState() => _MedicineDetailsSheetState();
}

class _MedicineDetailsSheetState extends State<MedicineDetailsSheet> {
  String _getFullImageUrl(String photoPath) {
    if (photoPath.isEmpty) return '';
    return '${ApiEndpoints.imageBaseUrl}$photoPath';
  }
  final cartController = Get.find<CartController>();
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

  // Track the currently expanded item
  int? expandedIndex;

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    Color? iconColor,
    Color? backgroundColor,
    Border? border,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: border ?? Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (content.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: TextStyle(
                        color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionSection(
      String title, String? content, IconData icon, int index) {
    if (content == null) return const SizedBox.shrink();

    return ExpansionTile(
      key: Key(index.toString()),
      initiallyExpanded: expandedIndex == index,
      onExpansionChanged: (isExpanded) {
        setState(() {
          expandedIndex = isExpanded ? index : null;
        });
      },
      leading:
          Icon(icon, color: Get.isDarkMode ? Colors.white70 : Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Get.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              content,
              style: TextStyle(
                color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;
    final String title = widget.service['name'] ?? 'Untitled';
    final String photoPath = widget.service['photo'] ?? '';
    final String imagePath = _getFullImageUrl(photoPath);

    final double previousPrice = _parseDouble(widget.service['previous_price']);
    final double discountPrice = _parseDouble(widget.service['discount_price']);
    final int stock = _parseInt(widget.service['stock']);
    final int discountPercentage =
        _parseInt(widget.service['discount_percentage']);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
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

                // Medicine Image Section
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Medicine Name Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),

                // Price Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'MRP ',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Text(
                        '₹${previousPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$discountPercentage% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Discounted Price
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${discountPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${(discountPrice / 100).toStringAsFixed(2)}/ML',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stock and Composition Cards
                _buildInfoCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Stock Available',
                  content: '$stock units',
                  iconColor: Colors.green,
                  backgroundColor: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                _buildInfoCard(
                  icon: Icons.science_outlined,
                  title: 'Composition',
                  content: widget.service['composition'] ?? '',
                ),

                // Storage Temperature Card
                _buildInfoCard(
                  icon: Icons.thermostat_outlined,
                  title: 'Storage',
                  content: 'Store Below 30°C',
                  iconColor: Colors.orange,
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),

                const SizedBox(height: 16),

                // Accordion Sections
                _buildAccordionSection(
                  'Introduction',
                  'Not available',
                  Icons.info_outline,
                  0,
                ),
                _buildAccordionSection(
                  'How it Works',
                  widget.service['how_it_work'],
                  Icons.medical_information_outlined,
                  1,
                ),
                _buildAccordionSection(
                  'Direction for Use',
                  widget.service['direction_for_use'],
                  Icons.assignment_outlined,
                  2,
                ),
                _buildAccordionSection(
                  'Side Effects',
                  widget.service['side_effect'],
                  Icons.warning_amber_outlined,
                  3,
                ),
                _buildAccordionSection(
                  'Manufacturer Details',
                  widget.service['sort_details'],
                  Icons.factory_outlined,
                  4,
                ),

                // Add Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Obx(() => ElevatedButton(
                    onPressed: stock > 0 && !cartController.isLoading.value
                        ? () async {
                      await cartController.addToCart(widget.service);
                      Get.to(() => const CartScreen());
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: stock > 0
                          ? CustomTheme.loginGradientStart
                          : Colors.grey,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: cartController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
