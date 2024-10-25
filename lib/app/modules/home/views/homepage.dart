// ignore_for_file: use_super_parameters, unnecessary_const

import 'dart:ui';

import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handyman/app/core/theme/theme.dart';
import 'package:handyman/app/modules/location/controller/location_controller.dart';
import 'package:handyman/app/modules/widgets/appliances.dart';
import 'package:handyman/app/modules/widgets/bestoffers.dart';
import 'package:handyman/app/modules/widgets/cleaning.dart';
import 'package:handyman/app/modules/widgets/latlng.dart';
import 'package:handyman/app/modules/widgets/service_explore.dart';
import 'package:handyman/app/modules/widgets/services.dart';

import 'package:handyman/main.dart';

import '../controller/homecontroller.dart';
import 'mapview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController homeController;
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  late LocationController locationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOnRight = true;

  String? cityName = 'Loading...';
  @override
  void initState() {
    super.initState();
    homeController = Get.put(HomeController());
    locationController = Get.put(LocationController());
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
    return GetBuilder<GetMaterialController>(
      id: 'themeBuilder',
      builder: (controller) {
        return Obx(() => Scaffold(
          key: _scaffoldKey,
          backgroundColor: CustomTheme.backgroundColor,
          body: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  actions: [
                    Obx(() => IconButton(
                      icon: Icon(
                        CustomTheme.themeMode == ThemeMode.light
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      onPressed: () {
                        CustomTheme.toggleTheme();
                      },
                    )),
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
                        onPressed: () async {await locationController.updateLocationFromHomepage();
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
                            // Only navigate to map if location is available
                            if (locationController.currentPosition.value != null &&
                                !locationController.isLocationSkipped.value) {
                              BackLatLng back = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocationPage(
                                    locationController.recentlyUpdatedViaButton.value
                                        ? locationController.currentPosition.value!.latitude
                                        : locationController.selectedLocation.value?.latitude ?? locationController.currentPosition.value!.latitude,
                                    locationController.recentlyUpdatedViaButton.value
                                        ? locationController.currentPosition.value!.longitude
                                        : locationController.selectedLocation.value?.longitude ?? locationController.currentPosition.value!.longitude,
                                  ),
                                ),
                              );
                              getBackResult(back.lat, back.lng);
                              locationController.recentlyUpdatedViaButton.value = false; // Reset the flag after use
                            } else {
                              // Handle the case when location is not available
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Location not available. Please try again.')),
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
                                  hintText: 'Search Product Name',
                                  suffixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.3),
                                  contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildCarouselSection(),
                ),
                SliverToBoxAdapter(
                  child: _buildServicesSection(),
                ),
                SliverToBoxAdapter(
                  child: _buildCleaningSection(),
                ),
                SliverToBoxAdapter(
                  child: _buildBestOffersSection(),
                ),
                SliverToBoxAdapter(
                  child: _buildCarouselAdds(),
                ),
                SliverToBoxAdapter(
                  child: _buildAppliancesSection(),
                ),
                SliverToBoxAdapter(
                  child: _buildCleaningPestControlSection(),
                ),
              ],
            ),
          ),
          endDrawer: _isDrawerOnRight ? _buildDrawer() : null,
          drawer: !_isDrawerOnRight ? _buildDrawer() : null,
        ));
      },
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
                const SizedBox(
                  height: 8,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    9, // First 9 colors for light mode
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
                const SizedBox(
                  height: 8,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    3, // Last 3 colors for dark mode
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
                onPageChanged: (index, reason) {
                  setState(() {

                  });
                },
              ),
              items: homeController.sliders.map((slider) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    double maxWidth = constraints.maxWidth;
                    double gradientWidth = maxWidth * 0.4; // 40% of screen width
                    double fontSize = maxWidth * 0.04; // 4% of screen width for title
                    double descFontSize = maxWidth * 0.04; // 3% of screen width for description

                    return ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Stack(
                        children: [
                          Image.network(
                            slider['photo'] as String,
                            fit: BoxFit.fitWidth,
                            width: maxWidth,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/Painting2.jpg',
                                fit: BoxFit.fitWidth,
                                width: maxWidth,
                              );
                            },
                          ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      slider['title'] as String,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Divider(color: Colors.white, thickness: maxWidth * 0.002),
                                    Expanded(
                                      child: Text(
                                        slider['description'] as String,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: descFontSize,
                                        ),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
  Widget _buildCarouselAdds() {
    final List<String> imgList = [
      'assets/images/Painting2.jpg',
      'assets/images/Painting1.jpg',
      'assets/images/Painting3.jpg',
      'assets/images/Grooming1.jpg',
      'assets/images/Grooming2.jpg',
      'assets/images/Grooming4.jpg',
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

  Widget _buildServicesSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController homeController = Get.find<HomeController>();

    return Obx(() {
      if (homeController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (homeController.categories.isEmpty) {
        return const Center(child: Text('No services available'));
      }

      return Column(
        children: [
          ListTile(
            title: const Text(
              'Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                Get.to(() => AllServices());
              },
            ),
          ),
          SizedBox(
            height: 278, // Increased height to accommodate two lines of text
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (homeController.categories.length / 2).ceil(),
              itemBuilder: (context, index) {
                return _buildServiceColumn(homeController.categories, index);
              },
            ),
          ),
          const SizedBox(height: 10),
          const Divider(
            color: Color.fromARGB(255, 241, 241, 241),
            thickness: 5,
          ),
          const SizedBox(height: 5),
        ],
      );
    });
  }

  Widget _buildServiceColumn(List<dynamic> categories, int columnIndex) {
    return Container(
      width: 130, // Fixed width for each column
      child: Column(
        children: [
          _buildServiceItem(categories, columnIndex * 2),
          const SizedBox(height: 10),
          if (columnIndex * 2 + 1 < categories.length)
            _buildServiceItem(categories, columnIndex * 2 + 1),
        ],
      ),
    );
  }

  Widget _buildServiceItem(List<dynamic> categories, int index) {
    if (index >= categories.length)
      return const SizedBox(height: 120); // Placeholder to maintain alignment

    var category = categories[index];
    return InkWell(
      onTap: () {
        Get.to(() => ServiceExplore(
          categoryId: category['id'].toString(),
          categoryTitle: category['title'] ?? 'Unknown Service',
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
                border:
                Border.all(color: const Color.fromARGB(255, 223, 223, 223)),
                borderRadius: const BorderRadius.all(Radius.elliptical(15, 15)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  category['image'] as String? ?? 'assets/images/temp1.png',
                  width: 120,
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
                category['title'] as String? ?? 'Unknown Service',
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

  Widget _buildCleaningSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Cleaning & Pest Control',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle:  Text('Removes hard stains & more', style: TextStyle(fontSize: 12,)),
          trailing: TextButton(
            child: Text(
              'View all',
              style: TextStyle(fontSize: 12,
                color:
                isDarkMode ? Colors.white : CustomTheme.loginGradientStart,
              ),
            ),
            onPressed: () {
              Get.to(() => const AllCleaning());
            },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCleaningItem(
                  'assets/images/temp3.png', 'Bathroom and Kitchen'),
              _buildCleaningItem(
                  'assets/images/temp3.png', 'Full Home Cleaning'),
              _buildCleaningItem(
                  'assets/images/temp3.png', 'Sofa & Carpet Cleaning'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Divider(
          color: Color.fromARGB(255, 241, 241, 241),
          thickness: 5,
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildCleaningItem(String imagePath, String title) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(imagePath, height: 120, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(title,
              style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBestOffersSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Best Offers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
              'Hygienic & single-use products | low - contact services', style: TextStyle(fontSize: 12,)),
          trailing: TextButton(
            child: Text(
              'View all',
              style: TextStyle(fontSize: 12,
                color:
                isDarkMode ? Colors.white : CustomTheme.loginGradientStart,
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
            children: [
              _buildOfferItem('assets/images/Grooming1.jpg', 'Salon At Home'),
              _buildOfferItem(
                  'assets/images/Grooming2.jpg', 'Massage Therapy For Men'),
              _buildOfferItem('assets/images/Maintenance3.jpg',
                  'Bathroom & Kitchen Cleaning'),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(
          color: Color.fromARGB(255, 241, 241, 241),
          thickness: 5,
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }

  Widget _buildOfferItem(String imagePath, String title) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Image.asset(
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
                width: 120, // Adjust the width as needed
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
              right: 8, // Added to limit the text within the container
              child: Container(
                height: 40, // Fixed height to align the text vertically
                child: Align(
                  alignment: Alignment.topLeft, // Align text to the top left
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

  Widget _buildAppliancesSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Appliances',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle:
          const Text('Servicing Repair, Installation & Uninstallation...', style: TextStyle(fontSize: 12,)),
          trailing: TextButton(
            child: Text(
              'View all',
              style: TextStyle(fontSize: 12,
                color:
                isDarkMode ? Colors.white : CustomTheme.loginGradientStart,
              ),
            ),
            onPressed: () {
              Get.to(() => const Appliances());
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildApplianceItem('assets/images/temp4.png', 'Geyser'),
            _buildApplianceItem('assets/images/temp5.png', 'Water Purifier'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildApplianceItem('assets/images/temp6.png', 'Washing Machine'),
            _buildApplianceItem('assets/images/temp7.png', 'Microwave'),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(
          color: Color.fromARGB(255, 241, 241, 241),
          thickness: 5,
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }

  Widget _buildApplianceItem(String imagePath, String title) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: SizedBox(
              height: 180,
              width: MediaQuery.of(context).size.width / 2.22,
              child: Card(
                child: Image.asset(imagePath, height: 80),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildCleaningPestControlSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Cleaning & Pest Control',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Removes hard stains & more',style: TextStyle(fontSize: 12,)),
          trailing: TextButton(
            child: Text(
              'View all',
              style: TextStyle(fontSize: 12,
                color:
                isDarkMode ? Colors.white : CustomTheme.loginGradientStart,
              ),
            ),
            onPressed: () {
              Get.to(() => const AllCleaning());
            },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCleaningPestItem(
                  'assets/images/temp8.png', 'Full Home Cleaning'),
              _buildCleaningPestItem(
                  'assets/images/temp8.png', 'Sofa & Carpet Cleaning'),
              _buildCleaningPestItem(
                  'assets/images/temp8.png', 'Sofa & Carpet Cleaning'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCleaningPestItem(String imagePath, String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          children: [
            ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Image.asset(
                  imagePath,
                  height: 100,
                  fit: BoxFit.cover,
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
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
