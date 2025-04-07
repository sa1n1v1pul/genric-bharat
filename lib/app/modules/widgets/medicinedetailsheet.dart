import 'package:flutter/material.dart';
import 'package:genric_bharat/app/modules/auth/controllers/auth_controller.dart';
import 'package:genric_bharat/app/modules/home/controller/homecontroller.dart';
import 'package:genric_bharat/app/modules/widgets/loginrequireddialog.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api_endpoints/api_endpoints.dart';
import 'package:genric_bharat/app/core/theme/theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../cart/controller/cartcontroller.dart';
import '../cart/view/cartscreen.dart';

class MedicineDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> service;
  const MedicineDetailsSheet({Key? key, required this.service})
      : super(key: key);

  @override
  State<MedicineDetailsSheet> createState() => _MedicineDetailsSheetState();
}

class _MedicineDetailsSheetState extends State<MedicineDetailsSheet> {
  final _authController = Get.find<AuthController>();
  final cartController = Get.find<CartController>();
  final homeController = Get.find<HomeController>();
  int? expandedIndex;
  RxInt quantity = 1.obs;
  RxList<Map<String, dynamic>> substituteProducts =
      <Map<String, dynamic>>[].obs;
  RxBool isLoadingSubstitutes = true.obs;

  @override
  void initState() {
    super.initState();
    findSubstituteProducts();
  }

  void findSubstituteProducts() async {
    isLoadingSubstitutes.value = true;

    try {
      // Get the composition of the current product
      final String currentComposition = widget.service['composition'] ?? '';
      if (currentComposition.isEmpty) {
        substituteProducts.value = [];
        isLoadingSubstitutes.value = false;
        return;
      }

      // Parse the composition into individual components
      final List<String> currentComponents =
          parseComposition(currentComposition);
      if (currentComponents.isEmpty) {
        substituteProducts.value = [];
        isLoadingSubstitutes.value = false;
        return;
      }

      // Get all available products from all categories
      final List<Map<String, dynamic>> allProducts = await getAllProducts();

      // Filter products with at least one matching component
      final List<Map<String, dynamic>> matchingProducts =
          allProducts.where((product) {
        // Skip the current product
        if (product['id'] == widget.service['id']) return false;

        final String productComposition = product['composition'] ?? '';
        if (productComposition.isEmpty) return false;

        final List<String> productComponents =
            parseComposition(productComposition);

        // Check if there's at least one matching component
        for (var component in currentComponents) {
          if (productComponents.contains(component)) {
            return true;
          }
        }

        return false;
      }).toList();

      substituteProducts.value = matchingProducts;
    } catch (e) {
      // Handle errors
      substituteProducts.value = [];
    } finally {
      isLoadingSubstitutes.value = false;
    }
  }

  // Helper method to parse composition string into individual components
  List<String> parseComposition(String composition) {
    if (composition.isEmpty) return [];

    // Split by + to get individual components
    final List<String> components = composition.split('+');

    // Trim each component and return
    return components.map((component) => component.trim()).toList();
  }

  // Method to get all products from all categories
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final List<Map<String, dynamic>> allProducts = [];

    // Ensure category items are loaded
    if (homeController.categoryItems.isEmpty &&
        !homeController.isCategoryItemsLoading.value) {
      await homeController.fetchCategoryItems();
    }

    // Wait until category items are loaded
    while (homeController.isCategoryItemsLoading.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Extract all products from all categories
    for (var category in homeController.categoryItems) {
      if (category['items'] != null && category['items'] is List) {
        final List<dynamic> items = category['items'];
        for (var item in items) {
          if (item is Map<String, dynamic>) {
            allProducts.add(item);
          }
        }
      }
    }

    return allProducts;
  }

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

  double get totalAmount =>
      _parseDouble(widget.service['discount_price']) * quantity.value;

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    String? content,
    Color? iconColor,
    Color? backgroundColor,
    Border? border,
    String? stripInfo, // New parameter for strip information
  }) {
    final String contentStr = content?.toString() ?? '';
    final bool hasContent = contentStr.isNotEmpty && contentStr != 'null';
    final bool hasStripInfo =
        stripInfo != null && stripInfo.isNotEmpty && stripInfo != 'null';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: border ?? Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor ?? Colors.blue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                // Display strip information if available
                if (hasStripInfo)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      stripInfo,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasContent)
              Text(
                contentStr,
                style: TextStyle(
                  fontSize: 14,
                  color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              )
            else
              Text(
                'No ${title.toLowerCase()} information available',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Get.isDarkMode ? Colors.white60 : Colors.black38,
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

    bool containsYouTubeLink = content.toLowerCase().contains('youtube.com') ||
        content.toLowerCase().contains('youtu.be');

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
            child: containsYouTubeLink
                ? _buildClickableYouTubeText(content)
                : Text(
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

  Widget _buildClickableYouTubeText(String content) {
    final RegExp youtubeLinkRegExp = RegExp(
      r'(https?:\/\/)?(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/)[\w\-]+',
      caseSensitive: false,
    );

    final Iterable<Match> matches = youtubeLinkRegExp.allMatches(content);
    if (matches.isEmpty) return Text(content);

    final String youtubeLink = matches.first.group(0) ?? '';

    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(youtubeLink.startsWith('http')
            ? youtubeLink
            : 'https://$youtubeLink');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: youtubeLink,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 14,
              ),
            ),
            if (content.substring(matches.first.end).isNotEmpty)
              TextSpan(
                text: content.substring(matches.first.end),
                style: TextStyle(
                  color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isEnabled ? Colors.white : Colors.grey[200],
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: isEnabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled ? CustomTheme.loginGradientStart : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(() => _buildQuantityButton(
                icon: Icons.remove,
                onTap: () {
                  if (quantity.value > 1) quantity.value--;
                },
                isEnabled: quantity.value > 1,
              )),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Obx(() => Text(
                  '${quantity.value}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                )),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onTap: () {
              final int stock = _parseInt(widget.service['stock']);
              if (quantity.value < stock) quantity.value++;
            },
            isEnabled: quantity.value < _parseInt(widget.service['stock']),
          ),
        ],
      ),
    );
  }

  // Widget for Substitute Products section
  Widget _buildSubstituteProductsSection() {
    return Obx(() {
      if (isLoadingSubstitutes.value) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Text(
                  'Loading Substitute Products...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        );
      }

      // Hide the section completely if no substitute products
      if (substituteProducts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Substitute Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${substituteProducts.length} found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Get.isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: substituteProducts.length,
                itemBuilder: (context, index) {
                  final product = substituteProducts[index];
                  return _buildSubstituteProductCard(product);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // Widget for individual substitute product card
  Widget _buildSubstituteProductCard(Map<String, dynamic> product) {
    final String name = product['name'] ?? 'Untitled';
    final String photoPath = product['photo'] ?? '';
    final String imagePath = _getFullImageUrl(photoPath);
    final double price = _parseDouble(product['discount_price']);
    final int stock = _parseInt(product['stock']);
    final String composition = product['composition'] ?? '';

    // Find matching components
    final List<String> currentComponents =
        parseComposition(widget.service['composition'] ?? '');
    final List<String> productComponents = parseComposition(composition);
    final List<String> matchingComponents = currentComponents
        .where((component) => productComponents.contains(component))
        .toList();

    return GestureDetector(
      onTap: () {
        // Close the current bottom sheet and open new one for the substitute product
        Navigator.pop(context);
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
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
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
            // Image section
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                image: DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.contain,
                  onError: (exception, stackTrace) =>
                      const AssetImage('assets/placeholder.png'),
                ),
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Price and stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: stock > 0 ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stock > 0 ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 8,
                            color:
                                stock > 0 ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Matching components
                  if (matchingComponents.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Contains: ${matchingComponents.first}${matchingComponents.length > 1 ? ' +${matchingComponents.length - 1} more' : ''}',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.blue[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  void onAddToCartPressed() async {
    if (!_authController.isLoggedIn.value) {
      final shouldLogin = await LoginRequiredDialog.show(context);
      if (shouldLogin) return; // User chose to login
      return;
    }

    if (!cartController.isLoading.value) {
      final Map<String, dynamic> serviceWithQuantity = Map.from(widget.service);
      serviceWithQuantity['quantity'] = quantity.value;
      await cartController.addToCart(serviceWithQuantity);
      Get.to(() => const CartScreen());
    }
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
                        icon: Icon(Icons.close,
                            color: isDarkMode ? Colors.white : Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Medicine Image Section with Stock Badge
                Stack(
                  children: [
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
                                child: Icon(Icons.error_outline,
                                    color: Colors.grey, size: 40),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Stock Badge
                    Positioned(
                      top: 10,
                      right: 26,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: stock > 0 ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          stock > 0 ? 'In Stock' : 'Out of Stock',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
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

                // Price Section and Quantity Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'MRP ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                Text(
                                  '₹${previousPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
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
                            const SizedBox(height: 8),
                            Text(
                              '₹${discountPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (stock > 0) _buildQuantityControls(),
                    ],
                  ),
                ),

                // Composition Card
                _buildInfoCard(
                  icon: PhosphorIcons.flask(),
                  title: 'Composition',
                  content: widget.service['composition'],
                  iconColor: Colors.blue,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),

                // Accordion Sections
                _buildAccordionSection(
                  'Introduction',
                  'Not available',
                  PhosphorIcons.info(),
                  0,
                ),
                _buildAccordionSection(
                  'Short Description',
                  widget.service['sort_details'],
                  PhosphorIcons.textAlignLeft(),
                  1,
                ),
                _buildAccordionSection(
                  'How it Works',
                  widget.service['how_it_work'],
                  PhosphorIcons.heartbeat(),
                  2,
                ),
                _buildAccordionSection(
                  'Direction for Use',
                  widget.service['direction_for_use'],
                  PhosphorIcons.clipboardText(),
                  3,
                ),
                _buildAccordionSection(
                  'Side Effects',
                  widget.service['side_effect'],
                  PhosphorIcons.warningCircle(),
                  4,
                ),
                _buildAccordionSection(
                  'Instructions Video',
                  widget.service['video_link'],
                  PhosphorIcons.video(),
                  5,
                ),

                // Substitute Products Section (only shown if products available)
                _buildSubstituteProductsSection(),

                // Add to Cart Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Obx(() => ElevatedButton(
                        onPressed: stock > 0 ? onAddToCartPressed : null,
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
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Add to Cart',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₹${totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
