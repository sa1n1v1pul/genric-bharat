import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handyman/app/core/theme/theme.dart';
import 'package:handyman/app/modules/api_endpoints/api_provider.dart';
import 'package:handyman/app/modules/widgets/providerlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    homeController.fetchServices(widget.categoryId, subcategoryId: 'All');
  }

  void _onSubcategorySelected(String subcategoryId) {
    setState(() {
      _selectedSubcategory = subcategoryId;
    });
    homeController.fetchServices(widget.categoryId, subcategoryId: subcategoryId);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[550] : const Color.fromARGB(255, 244, 243, 248),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: isDarkMode ? const Color.fromARGB(255, 244, 243, 248) : Colors.black,
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for services',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2.0, right: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CustomTheme.loginGradientStart,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    height: 50,
                    width: 50,
                    child: const Icon(Icons.filter, color: Colors.white),
                  ),
                ),
              ],
            ),
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
                    _buildSubcategoryChip({'id': 'All', 'title': 'All', 'photo': ''}),
                    ...homeController.subcategories.map(
                          (subcategory) => _buildSubcategoryChip(subcategory),
                    ),
                  ],
                ),
              );
            }),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Obx(() {
              if (homeController.isServicesLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              List<Map<String, dynamic>> filteredServices = homeController.services;
              if (_selectedSubcategory != 'All') {
                filteredServices = homeController.services.where((service) =>
                service['sub_category']['id'].toString() == _selectedSubcategory
                ).toList();
              }
              return Column(
                children: filteredServices.map((service) {
                  return InkWell(
                    onTap: () {
                      String serviceId = service['id'].toString();
                      SharedPreferences.getInstance().then((prefs) {
                        int? userId = prefs.getInt('user_id');
                        if (userId != null) {
                          Get.find<ApiProvider>().getUserProfile(userId).then((response) {
                            if (response.statusCode == 200) {
                              String userId = response.data['id'].toString();
                              Get.to(() => ProviderListScreen(serviceId: serviceId, userId: userId));
                            } else {
                              print('Error fetching user profile');
                            }
                          }).catchError((error) {
                            print('Error: $error');
                          });
                        } else {
                          print('User ID not found');

                        }
                      });
                    },
                    child: _buildServiceCard(
                      service['sub_category']['title'] ?? '',
                      service['name'] ?? '',
                      service['photo'] ?? '',
                    ),
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

    return GestureDetector(
      onTap: () => _onSubcategorySelected(subcategory['id'].toString()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
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
                  subcategory['photo'], // Use the photo URL directly
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
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
            Text(subcategory['title'], style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String category, String title, String imagePath) {
    bool isDarkMode = Get.isDarkMode;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imagePath,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey,
                  child: Icon(Icons.error),
                );
              },
            ),
          ),
          Positioned(
            top: 00,
            bottom: 0,
            left: 00,
            child: Container(
              width: 170,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.light
                      ? [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.0),
                  ]
                      : [
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.01),
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
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const Text(
                  ' > ',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 6, right: 6, top: 1, bottom: 1),
                  decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode
                          ? Colors.white
                          : CustomTheme.loginGradientStart,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 160,
            bottom: 0,
            left: 10,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}