import 'package:flutter/material.dart';
import 'package:genric_bharat/app/core/theme/theme.dart';
import 'package:genric_bharat/app/modules/api_endpoints/api_provider.dart';
import 'package:genric_bharat/app/modules/widgets/providerlist.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_endpoints/api_endpoints.dart';
import '../home/controller/homecontroller.dart';

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
    final String subcategoryName = service['subcategory_id']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imagePath,
              fit: BoxFit.contain,
              height: 200,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey,
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
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
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.01),
                  ]
                      : [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.0),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.categoryTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (subcategoryName.isNotEmpty) ...[
                  const Text(
                    ' > ',
                    style: TextStyle(fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.5)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      subcategoryName,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? Colors.white
                            : CustomTheme.loginGradientStart,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor:
      isDarkMode ? Colors.grey[550] : const Color.fromARGB(255, 244, 243, 248),
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
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (keep existing search bar and filter button)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Subcategories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Obx(() {
              if (homeController.isSubcategoriesLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSubcategoryChip({
                      'id': 'All',
                      'name': 'All',
                      'photo': '',
                    }),
                    ...homeController.subcategories
                        .map((subcategory) => _buildSubcategoryChip(subcategory)),
                  ],
                ),
              );
            }),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Obx(() {
              if (homeController.isServicesLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final services = homeController.services;
              if (services.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No services found'),
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
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt('user_id');
                      if (userId != null) {
                        try {
                          final response =
                          await Get.find<ApiProvider>().getUserProfile(userId);
                          if (response.statusCode == 200) {
                            final profileUserId = response.data['id'].toString();
                            Get.to(() => ProviderListScreen(
                                serviceId: service['id'].toString(),
                                userId: profileUserId));
                          }
                        } catch (e) {
                          print('Error navigating to provider list: $e');
                        }
                      }
                    },
                    child: _buildServiceCard(service),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryChip(Map<String, dynamic> subcategory) {
    bool isSelected = _selectedSubcategory == subcategory['id'].toString();
    bool isAllCategory = subcategory['id'] == 'All';

    String photoPath = subcategory['photo'] ?? '';
    String fullImageUrl = _getFullImageUrl(photoPath);

    return GestureDetector(
      onTap: () => _onSubcategorySelected(subcategory['id'].toString()),
      child: Container(
        width: 90, // Fixed width for uniform spacing
        margin: const EdgeInsets.symmetric(horizontal: 4), // Reduced horizontal margin
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: isSelected
                  ? CustomTheme.loginGradientStart
                  : Colors.grey[200],
              child: isAllCategory
                  ? Icon(
                Icons.check_circle,
                color: isSelected
                    ? Colors.white
                    : CustomTheme.loginGradientStart,
              )
                  : ClipOval(
                child: Image.network(
                  fullImageUrl,
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.error,
                      color: isSelected
                          ? Colors.white
                          : CustomTheme.loginGradientStart,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 50, // Fixed height for two lines of text
              child: Text(
                subcategory['name'] ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.2, // Reduced line height for better spacing
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}