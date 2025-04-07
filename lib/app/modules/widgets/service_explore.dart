// import 'package:flutter/material.dart';
// import 'package:genric_bharat/app/core/theme/theme.dart';
// import 'package:genric_bharat/app/modules/api_endpoints/api_provider.dart';
// import 'package:genric_bharat/app/modules/widgets/providerlist.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../api_endpoints/api_endpoints.dart';
// import '../home/controller/homecontroller.dart';
// import 'medicinedetailsheet.dart';

// class ServiceExplore extends StatefulWidget {
//   final String categoryId;
//   final String categoryTitle;

//   const ServiceExplore({
//     Key? key,
//     required this.categoryId,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   State<ServiceExplore> createState() => _ServiceExploreState();
// }

// class _ServiceExploreState extends State<ServiceExplore> {
//   final HomeController homeController = Get.find<HomeController>();
//   String _selectedSubcategory = 'All';

//   @override
//   void initState() {
//     super.initState();
//     homeController.fetchSubcategories(widget.categoryId);
//     homeController.fetchItems(widget.categoryId, subcategoryId: 'All');
//   }

//   void _onSubcategorySelected(String subcategoryId) {
//     setState(() {
//       _selectedSubcategory = subcategoryId;
//     });
//     homeController.fetchItems(widget.categoryId, subcategoryId: subcategoryId);
//   }

//   String _getFullImageUrl(String photoPath) {
//     if (photoPath.isEmpty) return '';
//     return '${ApiEndpoints.imageBaseUrl}$photoPath';
//   }

//   Widget _buildServiceCard(Map<String, dynamic> service) {
//     bool isDarkMode = Get.isDarkMode;
//     final String title = service['name'] ?? 'Untitled';
//     final String photoPath = service['photo'] ?? '';
//     final String imagePath = _getFullImageUrl(photoPath);
//     final String subcategoryName = service['subcategory_id']?.toString() ?? '';

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.network(
//               imagePath,
//               fit: BoxFit.contain,
//               height: 200,
//               width: double.infinity,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   height: 200,
//                   width: double.infinity,
//                   color: Colors.grey,
//                   child: const Icon(Icons.error),
//                 );
//               },
//             ),
//           ),
//           Positioned(
//             top: 0,
//             bottom: 0,
//             left: 0,
//             child: Container(
//               width: 170,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: isDarkMode
//                       ? [
//                           Colors.black.withOpacity(0.9),
//                           Colors.black.withOpacity(0.01),
//                         ]
//                       : [
//                           Colors.white.withOpacity(0.9),
//                           Colors.white.withOpacity(0.0),
//                         ],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   bottomLeft: Radius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             top: 8,
//             left: 8,
//             child: Row(
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.6),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Text(
//                     widget.categoryTitle,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 if (subcategoryName.isNotEmpty) ...[
//                   const Text(
//                     ' > ',
//                     style: TextStyle(fontSize: 13),
//                   ),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
//                     decoration: BoxDecoration(
//                       color: isDarkMode
//                           ? Colors.black.withOpacity(0.5)
//                           : Colors.white.withOpacity(0.7),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       subcategoryName,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: isDarkMode
//                             ? Colors.white
//                             : CustomTheme.loginGradientStart,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 16,
//             left: 16,
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isDarkMode = Get.isDarkMode;

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         iconTheme: IconThemeData(
//           color: isDarkMode
//               ? const Color.fromARGB(255, 244, 243, 248)
//               : Colors.black,
//         ),
//         centerTitle: true,
//         scrolledUnderElevation: 0,
//         leading: Builder(
//           builder: (BuildContext context) {
//             final ThemeData theme = Theme.of(context);
//             final bool isDarkMode = theme.brightness == Brightness.dark;

//             return Container(
//               padding: const EdgeInsets.only(left: 4),
//               margin: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isDarkMode ? Colors.grey[800] : Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: (isDarkMode ? Colors.black : Colors.white)
//                         .withOpacity(0.3),
//                     spreadRadius: 5,
//                     blurRadius: 3,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: IconButton(
//                 icon: Icon(
//                   Icons.arrow_back_ios,
//                   size: 18,
//                   color: isDarkMode ? Colors.white : Colors.black,
//                 ),
//                 onPressed: () => Navigator.of(context).pop(),
//                 padding: EdgeInsets.zero,
//               ),
//             );
//           },
//         ),
//         toolbarHeight: 60,
//         title: Text(
//           widget.categoryTitle,
//           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
//         foregroundColor: isDarkMode ? Colors.white : Colors.black,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text(
//                 'Subcategories',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             Obx(() {
//               if (homeController.isSubcategoriesLoading.value) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               return SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     _buildSubcategoryChip({
//                       'id': 'All',
//                       'name': 'All',
//                       'photo': '',
//                     }),
//                     ...homeController.subcategories.map(
//                         (subcategory) => _buildSubcategoryChip(subcategory)),
//                   ],
//                 ),
//               );
//             }),
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text(
//                 'Items',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             Obx(() {
//               if (homeController.isServicesLoading.value) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (homeController.errorMessage.value.isNotEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         homeController.errorMessage.value,
//                         textAlign: TextAlign.center,
//                       ),
//                       ElevatedButton(
//                         onPressed: () => homeController.fetchItems(
//                           widget.categoryId,
//                           subcategoryId: _selectedSubcategory,
//                         ),
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               final services = homeController.services;
//               if (services.isEmpty) {
//                 return const Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Text('No services found'),
//                   ),
//                 );
//               }

//               final filteredServices = _selectedSubcategory == 'All'
//                   ? services
//                   : services
//                       .where((service) =>
//                           service['subcategory_id'].toString() ==
//                           _selectedSubcategory)
//                       .toList();

//               return Column(
//                 children: filteredServices.map((service) {
//                   return InkWell(
//                     onTap: () {
//                       showModalBottomSheet(
//                         context: context,
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                         builder: (context) => DraggableScrollableSheet(
//                           initialChildSize: 0.8,
//                           minChildSize: 0.6,
//                           maxChildSize: 0.8,
//                           builder: (context, scrollController) =>
//                               MedicineDetailsSheet(
//                             service: service,
//                           ),
//                         ),
//                       );
//                     },
//                     child: _buildServiceCard(service),
//                   );
//                 }).toList(),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSubcategoryChip(Map<String, dynamic> subcategory) {
//     bool isSelected = _selectedSubcategory == subcategory['id'].toString();
//     bool isAllCategory = subcategory['id'] == 'All';
//     bool isDarkMode = Get.isDarkMode;

//     String photoPath = subcategory['photo'] ?? '';
//     String fullImageUrl = _getFullImageUrl(photoPath);

//     return GestureDetector(
//       onTap: () => _onSubcategorySelected(subcategory['id'].toString()),
//       child: Container(
//         width: 90,
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Glowing effect container
//             Container(
//               decoration: isSelected
//                   ? BoxDecoration(
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color:
//                               CustomTheme.loginGradientStart.withOpacity(0.7),
//                           spreadRadius: 3,
//                           blurRadius: 12,
//                           offset: const Offset(0, 0),
//                         ),
//                       ],
//                     )
//                   : null,
//               child: CircleAvatar(
//                 radius: 35,
//                 backgroundColor: isSelected
//                     ? CustomTheme.loginGradientStart
//                     : Colors.grey[200],
//                 child: isAllCategory
//                     ? Icon(
//                         Icons.check_circle,
//                         color: isSelected
//                             ? Colors.white
//                             : CustomTheme.loginGradientStart,
//                         size: 30,
//                       )
//                     : ClipOval(
//                         child: Image.network(
//                           fullImageUrl,
//                           fit: BoxFit.cover,
//                           width: 70,
//                           height: 70,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Icon(
//                               Icons.error,
//                               color: isSelected
//                                   ? Colors.white
//                                   : CustomTheme.loginGradientStart,
//                             );
//                           },
//                         ),
//                       ),
//               ),
//             ),
//             const SizedBox(height: 4),
//             // Text with special styling for selected item
//             SizedBox(
//               height: 15,
//               child: Text(
//                 subcategory['name'] ?? '',
//                 style: TextStyle(
//                   fontSize: 12,
//                   height: 1.2,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   color: isSelected
//                       ? isDarkMode
//                           ? Colors.white
//                           : CustomTheme.loginGradientStart
//                       : null,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             // Indicator dot for selected item
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:genric_bharat/app/core/theme/theme.dart';
import 'package:genric_bharat/app/modules/api_endpoints/api_provider.dart';
import 'package:genric_bharat/app/modules/widgets/providerlist.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_endpoints/api_endpoints.dart';
import '../home/controller/homecontroller.dart';
import 'medicinedetailsheet.dart';
import 'dart:ui';

class ServiceExplore extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const ServiceExplore({
    Key? key,
    required this.categoryId,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  State<ServiceExplore> createState() => _ServiceExploreState();
}

class _ServiceExploreState extends State<ServiceExplore> {
  final HomeController homeController = Get.find<HomeController>();
  String _selectedSubcategory = 'All';

  @override
  void initState() {
    super.initState();
    homeController.fetchSubcategories(widget.categoryId);
    homeController.fetchItems(widget.categoryId, subcategoryId: 'All');
  }

  void _onSubcategorySelected(String subcategoryId) {
    setState(() {
      _selectedSubcategory = subcategoryId;
    });
    homeController.fetchItems(widget.categoryId, subcategoryId: subcategoryId);
  }

  String _getFullImageUrl(String photoPath) {
    if (photoPath.isEmpty) return '';
    return '${ApiEndpoints.imageBaseUrl}$photoPath';
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    bool isDarkMode = Get.isDarkMode;
    final String title = service['name'] ?? 'Untitled';
    final String photoPath = service['photo'] ?? '';
    final String imagePath = _getFullImageUrl(photoPath);
    // final String subcategoryName = service['subcategory_id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black38 : Colors.grey.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.5),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        Colors.grey[800]!.withOpacity(0.5),
                        Colors.grey[900]!.withOpacity(0.5),
                      ]
                    : [
                        Colors.white.withOpacity(0.7),
                        Colors.white.withOpacity(0.3),
                      ],
              ),
            ),
            child: Stack(
              children: [
                // Shimmering Effect
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.transparent,
                        isDarkMode
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.white.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                // Main Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.contain,
                    height: 200,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        child: Icon(
                          Icons.error,
                          color: isDarkMode ? Colors.white60 : Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                // Gradient Overlay
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 170,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ]
                            : [
                                CustomTheme.loginGradientStart.withOpacity(0.6),
                                Colors.transparent,
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),

                // Title with glass effect background
                Positioned(
                  bottom: 1,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black87,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.3)
                                : Colors.white.withOpacity(0.8),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FE),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.8),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
              ),
            );
          },
        ),
        toolbarHeight: 70,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.8),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                widget.categoryTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background design elements
          Positioned.fill(
            child: isDarkMode
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A1A2E),
                          Color(0xFF16213E),
                        ],
                      ),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF8F9FE),
                          Color(0xFFEDF1FD),
                        ],
                      ),
                    ),
                  ),
          ),
          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomTheme.loginGradientStart.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomTheme.loginGradientEnd.withOpacity(0.1),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Only show subcategory section if there are subcategories
                  Obx(() {
                    // Check if subcategories exist and are not empty (excluding the "All" option)
                    bool hasSubcategories =
                        !homeController.isSubcategoriesLoading.value &&
                            homeController.subcategories.isNotEmpty;

                    if (!hasSubcategories) {
                      return const SizedBox
                          .shrink(); // Hide the entire subcategory section
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (homeController.isSubcategoriesLoading.value)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: CustomTheme.loginGradientStart,
                              ),
                            ),
                          )
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                _buildSubcategoryChip({
                                  'id': 'All',
                                  'name': 'All',
                                  'photo': '',
                                }),
                                ...homeController.subcategories.map(
                                    (subcategory) =>
                                        _buildSubcategoryChip(subcategory)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),

                  Obx(() {
                    if (homeController.isServicesLoading.value) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: CustomTheme.loginGradientStart,
                          ),
                        ),
                      );
                    }
                    if (homeController.errorMessage.value.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                homeController.errorMessage.value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => homeController.fetchItems(
                                  widget.categoryId,
                                  subcategoryId: _selectedSubcategory,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      CustomTheme.loginGradientStart,
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                  shadowColor: CustomTheme.loginGradientStart
                                      .withOpacity(0.5),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final services = homeController.services;
                    if (services.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No services found',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }

                    final filteredServices = _selectedSubcategory == 'All'
                        ? services
                        : services
                            .where((service) =>
                                service['subcategory_id'].toString() ==
                                _selectedSubcategory)
                            .toList();

                    return Column(
                      children: filteredServices.map((service) {
                        return InkWell(
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
                                  service: service,
                                ),
                              ),
                            );
                          },
                          child: _buildServiceCard(service),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryChip(Map<String, dynamic> subcategory) {
    bool isSelected = _selectedSubcategory == subcategory['id'].toString();
    bool isAllCategory = subcategory['id'] == 'All';
    bool isDarkMode = Get.isDarkMode;

    String photoPath = subcategory['photo'] ?? '';
    String fullImageUrl = _getFullImageUrl(photoPath);

    return GestureDetector(
      onTap: () => _onSubcategorySelected(subcategory['id'].toString()),
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3D glassy effect container
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  // Outer glow for selected items
                  if (isSelected)
                    BoxShadow(
                      color: CustomTheme.loginGradientStart.withOpacity(0.6),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  // Drop shadow for 3D effect
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? CustomTheme.loginGradientStart
                              .withOpacity(isDarkMode ? 0.7 : 0.9)
                          : (isDarkMode
                              ? Colors.grey[800]!.withOpacity(0.3)
                              : Colors.white.withOpacity(0.7)),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : (isDarkMode
                                ? Colors.white.withOpacity(0.2)
                                : Colors.white.withOpacity(0.9)),
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isSelected
                            ? [
                                CustomTheme.loginGradientStart,
                                CustomTheme.loginGradientEnd,
                              ]
                            : isDarkMode
                                ? [
                                    Colors.grey[800]!.withOpacity(0.7),
                                    Colors.grey[900]!.withOpacity(0.7),
                                  ]
                                : [
                                    Colors.white.withOpacity(0.9),
                                    Colors.white.withOpacity(0.5),
                                  ],
                      ),
                    ),
                    child: isAllCategory
                        ? Icon(
                            Icons.check_circle,
                            color: isSelected
                                ? Colors.white
                                : (isDarkMode
                                    ? Colors.white.withOpacity(0.8)
                                    : CustomTheme.loginGradientStart),
                            size: 34,
                          )
                        : ClipOval(
                            child: Image.network(
                              fullImageUrl,
                              fit: BoxFit.contain,
                              width: 70,
                              height: 70,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.error,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDarkMode
                                          ? Colors.white.withOpacity(0.8)
                                          : CustomTheme.loginGradientStart),
                                  size: 28,
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Text with glassy effect for selected item
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: isSelected ? 5 : 0, sigmaY: isSelected ? 5 : 0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.2)
                                : Colors.white.withOpacity(0.8),
                            width: 1,
                          ),
                        )
                      : null,
                  child: Text(
                    subcategory['name'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? isDarkMode
                              ? Colors.white
                              : CustomTheme.loginGradientStart
                          : isDarkMode
                              ? Colors.white.withOpacity(0.8)
                              : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
