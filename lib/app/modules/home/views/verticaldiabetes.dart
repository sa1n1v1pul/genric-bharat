import 'package:flutter/material.dart';
import 'package:genric_bharat/app/core/theme/theme.dart';
import 'package:genric_bharat/app/modules/api_endpoints/api_endpoints.dart';
import 'package:genric_bharat/app/modules/cart/controller/cartcontroller.dart';
import 'package:genric_bharat/app/modules/cart/view/cartscreen.dart';
import 'package:genric_bharat/app/modules/widgets/medicinedetailsheet.dart';
import 'package:get/get.dart';

class VerticalRollingCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final bool isDarkMode;
  final double textScaleFactor;

  const VerticalRollingCarousel({
    Key? key,
    required this.items,
    required this.isDarkMode,
    required this.textScaleFactor,
  }) : super(key: key);

  @override
  State<VerticalRollingCarousel> createState() =>
      _VerticalRollingCarouselState();
}

class _VerticalRollingCarouselState extends State<VerticalRollingCarousel> {
  late final ScrollController _scrollController;
  int _focusedIndex = 0;
  Color _shadowColor = Colors.black.withOpacity(0.5);
  int _tappedIndex = -1;
  double _backgroundScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _backgroundScrollOffset = _scrollController.offset / 2;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToIndex(int index) {
    double offset = 120 * index.toDouble();
    _scrollController.animateTo(
      offset,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 500),
    );
  }

  void changeShadowColor(int index) {
    setState(() {
      _tappedIndex = index;
      _shadowColor = const Color.fromARGB(255, 70, 164, 242).withOpacity(0.5);
    });
  }

  void _updateFocusedIndex(int value) {
    setState(() {
      _focusedIndex = value;
    });
    scrollToIndex(value);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            return true;
          }
          return false;
        },
        child: ListWheelScrollView.useDelegate(
          clipBehavior: Clip.antiAlias,
          controller: _scrollController,
          itemExtent: 120.0,
          diameterRatio: 1.5,
          perspective: 0.002,
          onSelectedItemChanged: (value) {
            _updateFocusedIndex(value);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index >= widget.items.length) {
                return null;
              }

              bool isCenter = index == _focusedIndex;

              return GestureDetector(
                onTap: () {
                  changeShadowColor(index);
                  _updateFocusedIndex(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _tappedIndex == index
                            ? const Color.fromARGB(255, 153, 191, 222)
                                .withOpacity(0.3)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: _buildDiabetesCardContent(
                    context: context,
                    item: widget.items[index],
                    isDarkMode: widget.isDarkMode,
                    textScaleFactor: widget.textScaleFactor,
                    isCenter: isCenter,
                  ),
                ),
              );
            },
            childCount: widget.items.length,
          ),
        ),
      ),
    );
  }

  // Card content with image and details
  Widget _buildDiabetesCardContent({
    required BuildContext context,
    required Map<String, dynamic> item,
    required bool isDarkMode,
    required double textScaleFactor,
    required bool isCenter,
  }) {
    String getCompleteImageUrl(String photoPath) {
      if (photoPath.startsWith('http')) {
        return photoPath;
      }
      return '${ApiEndpoints.imageBaseUrl}$photoPath';
    }

    // Calculate percentage discount
    double discountPercentage = 0.0;
    if (item['previous_price'] != 0) {
      final previousPrice = item['previous_price'].toDouble();
      final discountPrice = item['discount_price'].toDouble();
      discountPercentage =
          ((previousPrice - discountPrice) / previousPrice * 100)
              .roundToDouble();
    }

    final cartController = Get.find<CartController>();

    // Card sizing and styling based on focus state
    double cardHeight = isCenter ? 120 : 100;
    double cardElevation = isCenter ? 8.0 : 2.0;
    Color cardColor = isCenter
        ? (isDarkMode ? Colors.blueGrey.shade700 : Colors.white)
        : (isDarkMode ? Colors.blueGrey.shade900 : Colors.grey.shade100);

    // Create a card with image on left, details on right
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: cardHeight,
      child: Card(
        color: cardColor,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isCenter
              ? BorderSide(
                  color: isDarkMode
                      ? Colors.white30
                      : CustomTheme.loginGradientStart.withOpacity(0.5),
                  width: 1.5,
                )
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: isCenter
              ? () {
                  // Show details sheet on card tap
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.8,
                      minChildSize: 0.6,
                      maxChildSize: 0.8,
                      builder: (context, scrollController) => Material(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        child: MedicineDetailsSheet(
                          service: item,
                        ),
                      ),
                    ),
                  );
                }
              : null, // Only make tappable if it's the center card
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              // Left side - Image
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(12)),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    height: double.infinity,
                    color: isDarkMode
                        ? Colors.blueGrey.shade800
                        : const Color(0xfff5f5f5),
                    child: Image.network(
                      getCompleteImageUrl(item['photo']),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: isDarkMode ? Colors.white54 : Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Right side - Details
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Product name
                      Text(
                        item['name'],
                        style: TextStyle(
                          fontSize: (isCenter ? 16 : 14) / textScaleFactor,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Price and discount section
                      Row(
                        children: [
                          Text(
                            '₹${item['discount_price'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: (isCenter ? 16 : 14) / textScaleFactor,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (item['previous_price'] != 0)
                            Text(
                              '₹${item['previous_price'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12 / textScaleFactor,
                                decoration: TextDecoration.lineThrough,
                                color:
                                    isDarkMode ? Colors.white54 : Colors.grey,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Bottom row with discount and button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Discount percentage
                          if (discountPercentage > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${discountPercentage.toStringAsFixed(0)}% off',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10 / textScaleFactor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 0),

                          // Add to cart button - only on center card
                          if (isCenter)
                            SizedBox(
                              height: 30,
                              width: 100,
                              child: ElevatedButton.icon(
                                onPressed: (isCenter)
                                    ? () {
                                        // Stop event propagation to parent
                                        cartController.addToCart(item);
                                        Future.delayed(
                                            const Duration(milliseconds: 300),
                                            () {
                                          Get.to(() => CartScreen());
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.shopping_cart_outlined,
                                    size: 14),
                                label: const Text('Add',
                                    style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? Colors.tealAccent.shade700
                                      : CustomTheme.loginGradientStart,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  elevation: 4,
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 100),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
