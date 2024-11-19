// ignore_for_file: use_super_parameters, unnecessary_const

import 'dart:math';
import 'dart:ui';
import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genric_bharat/app/core/theme/theme.dart';
import 'package:genric_bharat/app/modules/cart/view/cartscreen.dart';
import 'package:genric_bharat/app/modules/home/views/searchview.dart';
import 'package:genric_bharat/app/modules/widgets/socialmedia.dart';
import 'package:genric_bharat/main.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api_endpoints/api_endpoints.dart';
import '../../cart/controller/cartcontroller.dart';
import '../../location/controller/location_controller.dart';
import '../../wallet/views/walletscreen.dart';
import '../../widgets/allvitamins.dart';
import '../../widgets/bestoffers.dart';

import '../../widgets/cheapandbestmedicine.dart';

import '../../widgets/diabetescare.dart';
import '../../widgets/latlng.dart';
import '../../widgets/medicaldevices.dart';
import '../../widgets/medicinedetailsheet.dart';
import '../../widgets/personalcarelist.dart';
import '../../widgets/popularitem.dart';
import '../../widgets/prescriptionview.dart';
import '../../widgets/service_explore.dart';
import '../../widgets/categories.dart';
import '../controller/homecontroller.dart';
import '../controller/search_controller.dart';
import 'mapview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController homeController;
  late ProductSearchController searchController;
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  late LocationController locationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOnRight = true;
  String getCompleteImageUrl(String photoPath) {
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    return '${ApiEndpoints.imageBaseUrl}$photoPath';
  }

  String? cityName = 'Loading...';
  @override
  void initState() {
    super.initState();
    homeController = Get.put(HomeController());
    locationController = Get.put(LocationController());
    searchController = Get.put(ProductSearchController());
  }
  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop(); // This will close the app
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }
  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  void getBackResult(latss, lngss) async {
    locationController.updateSelectedLocation(LatLng(latss, lngss));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GetBuilder<GetMaterialController>(
        id: 'themeBuilder',
        builder: (controller) {
          return Obx(() => Scaffold(
                key: _scaffoldKey,
                backgroundColor: CustomTheme.backgroundColor,
                body: Padding(
                  padding: const EdgeInsets.only(bottom: 2, right: 2),
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        actions: [
                          IconButton(
                            onPressed: () => Get.to(() => WalletScreen()),
                            icon: const Icon(Icons.account_balance_wallet,
                                color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white),
                            onPressed: () {
                              if (_isDrawerOnRight) {
                                _scaffoldKey.currentState?.openEndDrawer();
                              } else {
                                _scaffoldKey.currentState?.openDrawer();
                              }
                            },
                          ),
                        ],
                        surfaceTintColor: Colors.transparent,
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                            gradient: CustomTheme.appBarGradient,
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        foregroundColor: CustomTheme.loginGradientEnd,
                        automaticallyImplyLeading: false,
                        floating: true,
                        pinned: true,
                        title: Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                await locationController
                                    .updateLocationFromHomepage();
                                locationController.isLoading.value = true;
                                await locationController.handleLocationRequest();
                                locationController.isLoading.value = false;
                              },
                              icon: const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (locationController.currentPosition.value !=
                                          null &&
                                      !locationController
                                          .isLocationSkipped.value) {
                                    BackLatLng back = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LocationPage(
                                          locationController.recentlyUpdatedViaButton
                                                  .value
                                              ? locationController
                                                  .currentPosition.value!.latitude
                                              : locationController
                                                      .selectedLocation
                                                      .value
                                                      ?.latitude ??
                                                  locationController
                                                      .currentPosition
                                                      .value!
                                                      .latitude,
                                          locationController
                                                  .recentlyUpdatedViaButton.value
                                              ? locationController.currentPosition
                                                  .value!.longitude
                                              : locationController
                                                      .selectedLocation
                                                      .value
                                                      ?.longitude ??
                                                  locationController
                                                      .currentPosition
                                                      .value!
                                                      .longitude,
                                        ),
                                      ),
                                    );
                                    getBackResult(back.lat, back.lng);
                                    locationController
                                        .recentlyUpdatedViaButton.value = false;
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Location not available. Please try again.')),
                                    );
                                  }
                                },
                                child: Obx(() {
                                  if (locationController.isLoading.value) {
                                    return const Text('Loading...',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white));
                                  } else if (locationController
                                      .isPermissionDenied.value) {
                                    return const Text('Permissions denied',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white));
                                  } else if (locationController
                                          .isLocationSkipped.value &&
                                      !locationController
                                          .currentAddress.value.isNotEmpty) {
                                    return const Text('Location Skipped',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white));
                                  } else if (locationController
                                      .cityName.value.isNotEmpty) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Current Location',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white)),
                                        Text(
                                          locationController.cityName.value,
                                          style: const TextStyle(
                                              fontSize: 16, color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const Text('Location Unavailable',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white));
                                  }
                                }),
                              ),
                            ),
                          ],
                        ),
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(56),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, bottom: 8),
                            child: SizedBox(
                              height: 48,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search medicines, categories...',
                                        hintStyle: TextStyle(color: Colors.black54),
                                        prefixIcon: const Icon(Icons.search),
                                        prefixIconColor: Colors.black54,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      onTap: () {
                                        Get.to(() => SearchScreen());
                                      },
                                      readOnly: true,
                                    ),

                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildCarouselSection()),
                      SliverToBoxAdapter(child: _buildPrescriptionOrderCard()),
                      SliverToBoxAdapter(child: _buildCategoriesSection()),
                      SliverToBoxAdapter(child: _buildVitaminsSection()),
                      SliverToBoxAdapter(child: _buildBestOffersSection()),
                      SliverToBoxAdapter(child: _buildPersonalSection()),
                      SliverToBoxAdapter(child: _buildCarouselAdds()),
                      SliverToBoxAdapter(child: _buildPopularSection()),
                      SliverToBoxAdapter(child: _buildDiabetesCareSection()),
                      SliverToBoxAdapter(child: _buildNeedHelpSection()),
                      SliverToBoxAdapter(child: _buildHealthcareDevicesSection()),
                      SliverToBoxAdapter(
                          child: _buildCleaningPestControlSection()),
                      const SliverToBoxAdapter(child: SocialMediaSection()),
                    ],
                  ),
                ),
                endDrawer: _isDrawerOnRight ? _buildDrawer() : null,
                drawer: !_isDrawerOnRight ? _buildDrawer() : null,
              ));
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: CustomTheme.themeMode == ThemeMode.light
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topRight:
                    _isDrawerOnRight ? const Radius.circular(15) : Radius.zero,
                bottomRight:
                    _isDrawerOnRight ? const Radius.circular(15) : Radius.zero,
                topLeft:
                    !_isDrawerOnRight ? const Radius.circular(15) : Radius.zero,
                bottomLeft:
                    !_isDrawerOnRight ? const Radius.circular(15) : Radius.zero,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_isDrawerOnRight)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      const Text(
                        'Themes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (_isDrawerOnRight)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                    ],
                  ),
                ),
                // Theme toggle button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // Dynamic text based on current theme
                        CustomTheme.themeMode == ThemeMode.light
                            ? 'Dark Mode'
                            : 'Light Mode',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          CustomTheme.themeMode == ThemeMode.light
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          CustomTheme.toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Light Mode Themes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    9,
                    (index) => GestureDetector(
                      onTap: () =>
                          Get.find<ThemeController>().changeTheme(index),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: CustomTheme.themeColors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CustomTheme.loginGradientStart ==
                                    CustomTheme.themeColors[index]
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Dark Mode Themes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    3,
                    (index) => GestureDetector(
                      onTap: () =>
                          Get.find<ThemeController>().changeTheme(index + 9),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: CustomTheme.themeColors[index + 9],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CustomTheme.loginGradientStart ==
                                    CustomTheme.themeColors[index + 9]
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isDrawerOnRight = !_isDrawerOnRight;
                      });
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_isDrawerOnRight) {
                          _scaffoldKey.currentState?.openEndDrawer();
                        } else {
                          _scaffoldKey.currentState?.openDrawer();
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: _isDrawerOnRight
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.start,
                      children: [
                        if (!_isDrawerOnRight)
                          const Text(
                            'Swipe to Right',
                            style: TextStyle(color: Colors.white),
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          _isDrawerOnRight
                              ? Icons.arrow_back
                              : Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        if (_isDrawerOnRight)
                          const Text(
                            'Swipe to Left',
                            style: TextStyle(color: Colors.white),
                          ),
                      ],
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

  Widget _buildCarouselSection() {
    return Obx(() {
      if (homeController.isSlidersLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (homeController.sliders.isEmpty) {
        return const Center(child: Text('No sliders available'));
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 170.0,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                aspectRatio: 16 / 9,
                onPageChanged: (index, reason) {
                  setState(() {});
                },
              ),
              items: homeController.sliders.map((slider) {
                // Construct full image URL
                String imageUrl =
                    '${ApiEndpoints.imageBaseUrl}${slider['photo']}';

                return LayoutBuilder(
                  builder: (context, constraints) {
                    double maxWidth = constraints.maxWidth;
                    double maxHeight = constraints.maxHeight;
                    double gradientWidth = maxWidth * 0.4;
                    double fontSize = maxWidth * 0.04;
                    double descFontSize = maxWidth * 0.04;

                    return Container(
                      width: maxWidth,
                      height: maxHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: maxWidth,
                              height: maxHeight,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/medicine11.jpg',
                                  fit: BoxFit.cover,
                                  width: maxWidth,
                                  height: maxHeight,
                                );
                              },
                            ),
                            if (slider['title'] != null ||
                                slider['details'] != null)
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  width: gradientWidth,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.95),
                                        Colors.black.withOpacity(0.01),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(maxWidth * 0.04),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (slider['title'] != null)
                                          Text(
                                            slider['title'] as String,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        if (slider['details'] != null)
                                          Expanded(
                                            child: Text(
                                              slider['details'] as String,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: descFontSize,
                                              ),
                                              overflow: TextOverflow.fade,
                                              maxLines: 3,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPrescriptionOrderCard() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black45 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 223, 223, 223),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order with\nprescription',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload prescription to place your order',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UploadPrescriptionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.loginGradientStart,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Order now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Image.asset(
              'assets/images/notes.png',
              height: 120,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController homeController = Get.find<HomeController>();

    return Obx(() {
      if (homeController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (homeController.categories.isEmpty) {
        return const Center(child: Text('No categories available'));
      }

      return Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black45 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 223, 223, 223),
          ),
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.blueGrey : const Color(0xffe8f3ed),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 278,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            (homeController.categories.length / 2).ceil(),
                        itemBuilder: (context, index) {
                          return _buildCategoriesColumn(
                              homeController.categories, index);
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.to(() => AllCategories());
                          },
                          child: Row(
                            children: [
                              Text(
                                'View all Categories',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isDarkMode
                                      ? Colors.white
                                      : CustomTheme.loginGradientStart,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                CupertinoIcons.right_chevron,
                                size: 16,
                                color: isDarkMode
                                    ? Colors.white
                                    : CustomTheme.loginGradientStart,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategoriesColumn(List<dynamic> categories, int columnIndex) {
    return Container(
      width: 125,
      child: Column(
        children: [
          _buildCategoriesItem(categories, columnIndex * 2),
          const SizedBox(height: 10),
          if (columnIndex * 2 + 1 < categories.length)
            _buildCategoriesItem(categories, columnIndex * 2 + 1),
        ],
      ),
    );
  }

  Widget _buildCategoriesItem(List<dynamic> categories, int index) {
    if (index >= categories.length) return const SizedBox(height: 120);

    var category = categories[index];
    return InkWell(
      onTap: () {
        Get.to(() => ServiceExplore(
              categoryId: category['id'].toString(),
              categoryTitle: category['name'] ?? 'Unknown Category',
            ));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        height: 134,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black45
                      : const Color.fromARGB(255, 190, 187, 187),
                ),
                borderRadius: const BorderRadius.all(Radius.elliptical(15, 15)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  category['photo'] != null
                      ? '${ApiEndpoints.imageBaseUrl}${category['photo']}'
                      : 'assets/images/temp1.png',
                  width: 100,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/temp1.png',
                      width: 120,
                      height: 60,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              width: 110,
              child: Text(
                category['name'] ?? 'Unknown Category',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitaminsSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      final items = controller.getItemsForCategory("MULTIVITAMINS AND MULTIMINERALS");

      if (controller.isCategoryItemsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (items.isEmpty) {
        return const Center(child: Text('No products available'));
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black45 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 223, 223, 223),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vitamins & Supplements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black45 : const Color(0xfffce8e7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: min(items.length, 6),
                      itemBuilder: (context, index) {
                        return _buildVitaminsItem(items[index]);
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        Get.to(() => AllCategories());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.to(() => AllVitaminsScreen());
                            },
                            child: Row(
                              children: [
                                Text(
                                  'View all Vitamins & Supplements products',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDarkMode
                                        ? Colors.white
                                        : CustomTheme.loginGradientStart,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  CupertinoIcons.right_chevron,
                                  size: 16,
                                  color: isDarkMode
                                      ? Colors.white
                                      : CustomTheme.loginGradientStart,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildVitaminsItem(Map<String, dynamic> item) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
            builder: (context, scrollController) => MedicineDetailsSheet(
              service: item,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.blueGrey : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String? ?? 'Unknown Product',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item['discount_percentage'] != null)
                    Text(
                      'Up to ${item['discount_percentage']}% off',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.amber : Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                child: Image.network(
                  getCompleteImageUrl(item['photo'] as String? ?? ''),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/temp1.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestOffersSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      final bestDealProducts =
          controller.getItemsForCategory("BEST DEAL PRODUCTS");

      return Column(
        children: [
          ListTile(
            title: const Text(
              'Best Offers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Hygienic & single-use products | low - contact services',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            trailing: TextButton(
              child: Text(
                'View all',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? Colors.white
                      : CustomTheme.loginGradientStart,
                ),
              ),
              onPressed: () {
                Get.to(() => const BestOffers());
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: bestDealProducts.map((product) {
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
                          service: product,
                        ),
                      ),
                    );
                  },
                  child: _buildOfferItem(
                    getCompleteImageUrl(product['photo']),
                    product['name'],
                    isNetworkImage: true,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      );
    });
  }

  Widget _buildOfferItem(String imagePath, String title,
      {bool isNetworkImage = false}) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            isNetworkImage
                ? Image.network(
                    imagePath,
                    height: 190,
                    width: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 190,
                        width: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  )
                : Image.asset(
                    imagePath,
                    height: 190,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
            Positioned(
              top: 10,
              bottom: 0,
              left: 0,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.01),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              left: 8,
              right: 8,
              child: Container(
                height: 40,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
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

  Widget _buildPersonalSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      final items = controller.getItemsForCategory("Beauty & Personal Care");

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black45 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 223, 223, 223),
          ),
        ),
        child: Column(
          children: [
            ListTile(
              title: const Text(
                'Beauty & Personal Care',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Personal care products',
                style: TextStyle(fontSize: 12),
              ),
              trailing: TextButton(
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? Colors.white
                        : CustomTheme.loginGradientStart,
                  ),
                ),
                onPressed: () {
                  Get.to(() => const PersonalCareListScreen());
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(
                  left: 16, right: 16, top: 5, bottom: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.blueGrey : const Color(0xfffff7ec),
                borderRadius: BorderRadius.circular(10),
              ),
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index != items.length - 1 ? 10 : 0,
                    ),
                    child: GestureDetector(
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
                      child: _buildPersonalItem(
                        item['photo'],
                        item['name'],
                        item['discount_price'].toString(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPersonalItem(String photoPath, String title, String price) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              getCompleteImageUrl(photoPath),
              height: 120,
              width: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  width: 160,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '₹$price',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselAdds() {
    final List<String> imgList = [
      'assets/images/medicine1.jpeg',
      'assets/images/medicine2.jpeg',
      'assets/images/medicine3.jpg',
      'assets/images/medicine4.jpg',
      'assets/images/medicine5.jpg',
      'assets/images/medicine6.jpg',
    ];

    // Validation check for the image list length
    if (imgList.length < 2 || imgList.length > 6) {
      return const Center(
        child: Text(
          'The number of images should be between 2 and 6.',
          style: TextStyle(color: Colors.red, fontSize: 16.0),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180.0,
            autoPlay: true,
            enlargeCenterPage: false,
            viewportFraction: 0.92,
            aspectRatio: 16 / 9,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            pauseAutoPlayOnTouch: true,
            scrollDirection: Axis.horizontal,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              _currentIndexNotifier.value = index;
            },
          ),
          items: imgList.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          item,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        ValueListenableBuilder<int>(
          valueListenable: _currentIndexNotifier,
          builder: (context, currentIndex, child) {
            return CarouselIndicator(
              count: imgList.length,
              index: currentIndex,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Colors.white,
              activeColor: CustomTheme.loginGradientStart,
              width: 50.0,
              height: 4.0,
              space: 8.0,
              cornerRadius: 2.0,
            );
          },
        ),
        const SizedBox(
          height: 35,
        )
      ],
    );
  }

  Widget _buildPopularSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      final demandProducts = controller.getItemsForCategory("Demand Products");

      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.only(left: 16,right: 16,top: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black45 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 223, 223, 223),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Popular items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const Text(
                          ' ✨',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Items bought in your city',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => const PopularItemsScreen());
                  },
                  child: Text(
                    'View all',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white
                          : CustomTheme.loginGradientStart,
                    ),
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: demandProducts.map((product) {
                  final discount = product['previous_price'] != 0
                      ? ((product['previous_price'] -
                                  product['discount_price']) /
                              product['previous_price'] *
                              100)
                          .toStringAsFixed(0)
                      : '0';

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
                            service: product,
                          ),
                        ),
                      );
                    },
                    child: _buildMedicineCard(
                      discount: '$discount%',
                      name: product['name'],
                      originalPrice:
                          product['previous_price']?.toDouble() ?? 0.0,
                      discountedPrice:
                          product['discount_price']?.toDouble() ?? 0.0,
                      image: getCompleteImageUrl(product['photo']),
                      product: product,
                      isNetworkImage: true,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMedicineCard({
    required String discount,
    required String name,
    required double originalPrice,
    required double discountedPrice,
    required String image,
    required Map<String, dynamic> product,  // Add this parameter
    bool isNetworkImage = false,
  }) {
    final cartController = Get.find<CartController>();  // Get cart controller instance

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blueGrey
            : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: isNetworkImage
                      ? Image.network(
                    image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  )
                      : Image.asset(
                    image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (discount != '0%')
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$discount OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (originalPrice > 0) ...[
                        Text(
                          '₹${originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '₹${discountedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add to cart and navigate
                        // cartController.addToCart(product);
                        Get.to(() => const CartScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: CustomTheme.loginGradientStart,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: CustomTheme.loginGradientStart),
                      ),
                      child: const Text('Add'),
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

  Widget _buildDiabetesCareSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      final diabetesItems =
      controller.getItemsForCategory("SUGAR AND ANTI DIABETES MEDICINES");

      final displayItems = diabetesItems.take(6).toList();

      return Container(
        margin: const EdgeInsets.only(top: 16, bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black45 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 223, 223, 223),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Diabetes Care',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 16,bottom: 16,right: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black38 : const Color(0xffeff8ff),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: displayItems
                        .map((item) => GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              DraggableScrollableSheet(
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
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      // Pass all diabetes items to the view all screen
                      Get.to(() => const DiabetesCareProductsScreen());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'View all Diabetes Care products',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white
                                  : CustomTheme.loginGradientStart,
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: isDarkMode
                                ? Colors.white
                                : CustomTheme.loginGradientStart,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDiabetesCard({
    required String title,
    required String discount,
    required String imageUrl,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.blueGrey : Colors.white,
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
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

  Widget _buildNeedHelpSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Function to handle phone call
    Future<void> _makePhoneCall() async {
      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: '+910123456789',
      );

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Could not launch phone dialer'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black45 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 223, 223, 223),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help with buying?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Call us between 9 AM and 9 PM to help you find your medicines',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _makePhoneCall, // Added the phone call function
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? CustomTheme.loginGradientStart.withOpacity(0.2)
                          : CustomTheme.loginGradientStart.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone,
                          color: isDarkMode
                              ? Colors.white
                              : CustomTheme.loginGradientStart,),
                        const SizedBox(width: 8),
                        Text(
                          'Call us and order',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                : CustomTheme.loginGradientStart,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/call.png',
            width: 120,
            height: 120,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthcareDevicesSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      final devices = controller.getItemsForCategory("MEDICAL DEVICES");

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black45 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 223, 223, 223),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Medical Devices',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              trailing: TextButton(
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white : CustomTheme.loginGradientStart,
                  ),
                ),
                onPressed: () {
                  Get.to(() => const MedicalDevicesScreen());
                },
              ),
            ),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
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
                                service: device,
                              ),
                        ),
                      );
                    },
                    child: _buildDeviceCard(
                      title: device['name'],
                      discount: device['previous_price'] != 0
                          ? 'Save ₹${device['previous_price'] - device['discount_price']}'
                          : '',
                      price: '₹${device['discount_price']}',
                      imageUrl: device['photo'],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDeviceCard({
    required String title,
    required String discount,
    required String price,
    required String imageUrl,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black38 : const Color(0xFFF7F1FF),
        borderRadius: BorderRadius.circular(20),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (discount.isNotEmpty) ...[
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
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

  Widget _buildCleaningPestControlSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      final cheapMedicines = controller.getItemsForCategory("CHEAP AND BEST MEDICINES");

      return Column(
        children: [
          ListTile(
            title: const Text(
              'Cheap & Best Medicines',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Removes hard stains & more',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            trailing: TextButton(
              child: Text(
                'View all',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white : CustomTheme.loginGradientStart,
                ),
              ),
              onPressed: () {
                Get.to(() => const CheapMedicinesScreen());
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cheapMedicines.map((medicine) {
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
                          service: medicine,
                        ),
                      ),
                    );
                  },
                  child: _buildCleaningPestItem(
                    getCompleteImageUrl(medicine['photo']),
                    medicine['name'],
                    isNetworkImage: true,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCleaningPestItem(
    String imagePath,
    String title, {
    bool isNetworkImage = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: isNetworkImage
                  ? Image.network(
                      imagePath,
                      height: 100,
                      width: 100, // Added width to maintain aspect ratio
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    )
                  : Image.asset(
                      imagePath,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
            ),
            Container(
              width: 100, // Match the image width
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}
