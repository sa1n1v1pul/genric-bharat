// ignore_for_file: use_super_parameters, unnecessary_const

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:genric_bharat/app/core/theme/theme.dart';
import 'package:genric_bharat/app/modules/auth/controllers/auth_controller.dart';
import 'package:genric_bharat/app/modules/cart/view/cartscreen.dart';
import 'package:genric_bharat/app/modules/home/views/searchview.dart';
import 'package:genric_bharat/app/modules/home/views/verticaldiabetes.dart';
import 'package:genric_bharat/app/modules/widgets/loginrequireddialog.dart';
import 'package:genric_bharat/app/modules/widgets/socialmedia.dart';
import 'package:genric_bharat/main.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api_endpoints/api_endpoints.dart';
import '../../cart/controller/cartcontroller.dart';
import '../../location/controller/location_controller.dart';
import '../../prescription/controller/prescriptioncontroller.dart';
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
import '../../prescription/views/prescriptionview.dart';
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
  double getScaledFontSize(double originalSize) {
    return originalSize / MediaQuery.of(context).textScaleFactor;
  }

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
                  SystemNavigator.pop();
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
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
                            icon:
                                const Icon(Icons.settings, color: Colors.white),
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
                                await locationController
                                    .handleLocationRequest();
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
                                  if (locationController
                                              .currentPosition.value !=
                                          null &&
                                      !locationController
                                          .isLocationSkipped.value) {
                                    BackLatLng back = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LocationPage(
                                          locationController
                                                  .recentlyUpdatedViaButton
                                                  .value
                                              ? locationController
                                                  .currentPosition
                                                  .value!
                                                  .latitude
                                              : locationController
                                                      .selectedLocation
                                                      .value
                                                      ?.latitude ??
                                                  locationController
                                                      .currentPosition
                                                      .value!
                                                      .latitude,
                                          locationController
                                                  .recentlyUpdatedViaButton
                                                  .value
                                              ? locationController
                                                  .currentPosition
                                                  .value!
                                                  .longitude
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
                                        'Location not available. Please try again.',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                    );
                                  }
                                },
                                child: Obx(() {
                                  if (locationController.isLoading.value) {
                                    return Text('Loading...',
                                        style: TextStyle(
                                            fontSize: 16 /
                                                MediaQuery.of(context)
                                                    .textScaleFactor,
                                            color: Colors.white));
                                  } else if (locationController
                                      .isPermissionDenied.value) {
                                    return Text('Permissions denied',
                                        style: TextStyle(
                                            fontSize: 16 /
                                                MediaQuery.of(context)
                                                    .textScaleFactor,
                                            color: Colors.white));
                                  } else if (locationController
                                          .isLocationSkipped.value &&
                                      !locationController
                                          .currentAddress.value.isNotEmpty) {
                                    return Text('Location Skipped',
                                        style: TextStyle(
                                            fontSize: 14 /
                                                MediaQuery.of(context)
                                                    .textScaleFactor,
                                            color: Colors.white));
                                  } else if (locationController
                                      .cityName.value.isNotEmpty) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Current Location',
                                          style: TextStyle(
                                              fontSize: getScaledFontSize(14),
                                              color: Colors.white),
                                        ),
                                        Text(
                                          locationController.cityName.value,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Text('Location Unavailable',
                                        style: TextStyle(
                                            fontSize: 16 /
                                                MediaQuery.of(context)
                                                    .textScaleFactor,
                                            color: Colors.white));
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
                                      filter: ImageFilter.blur(
                                          sigmaX: 10, sigmaY: 10),
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText:
                                              'Search medicines, Brands...',
                                          hintStyle: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16 /
                                                MediaQuery.of(context)
                                                    .textScaleFactor,
                                          ),
                                          prefixIcon: const Icon(Icons.search),
                                          prefixIconColor: Colors.black54,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        style: TextStyle(
                                          fontSize: 16 /
                                              MediaQuery.of(context)
                                                  .textScaleFactor,
                                        ),
                                        onTap: () {
                                          Get.to(() => SearchScreen());
                                        },
                                        readOnly: true,
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildCarouselSection()),
                      SliverToBoxAdapter(child: _buildPrescriptionOrderCard()),
                      SliverToBoxAdapter(child: _buildCategoriesSection()),
                      SliverToBoxAdapter(child: _buildBestOffersSection()),
                      SliverToBoxAdapter(child: _buildPopularSection()),
                      SliverToBoxAdapter(child: _buildDiabetesCareSection()),
                      SliverToBoxAdapter(child: _buildVitaminsSection()),
                      SliverToBoxAdapter(child: _buildPersonalSection()),
                      SliverToBoxAdapter(child: _buildNeedHelpSection()),
                      SliverToBoxAdapter(
                          child: _buildHealthcareDevicesSection()),
                      SliverToBoxAdapter(
                          child: _buildCleaningPestControlSection()),
                      SliverToBoxAdapter(child: _buildCarouselAdds()),
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

  Widget _buildBestOffersSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Obx(() {
      final bestDealProducts =
          controller.getItemsForCategory("BEST DEAL PRODUCTS");

      if (controller.isCategoryItemsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (bestDealProducts.isEmpty) {
        return const Center(child: Text('No products available'));
      }

      return Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Subtitle
            LayoutBuilder(builder: (context, constraints) {
              final adjustedTitleFontSize = 16 / textScaleFactor;
              final adjustedSubtitleFontSize = 12 / textScaleFactor;

              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Best Offers',
                      style: TextStyle(
                        fontSize: adjustedTitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Hygienic & single-use products | low - contact services',
                      style: TextStyle(fontSize: adjustedSubtitleFontSize),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            // Products Container
            SizedBox(
              height: 520,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two rows
                  crossAxisSpacing: 12, // Vertical spacing between cards
                  mainAxisSpacing: 7, // Horizontal spacing between cards
                  mainAxisExtent: 180, // Card width
                ),
                itemCount: bestDealProducts.length,
                itemBuilder: (context, index) {
                  final product = bestDealProducts[index];
                  final originalPrice =
                      product['previous_price']?.toDouble() ?? 0.0;
                  final discountedPrice =
                      product['discount_price']?.toDouble() ?? 0.0;
                  final discount = originalPrice > 0
                      ? ((originalPrice - discountedPrice) /
                              originalPrice *
                              100)
                          .toStringAsFixed(0)
                      : '0';

                  return _buildMedicineCard(
                    discount: '$discount%',
                    name: product['name'],
                    originalPrice: originalPrice,
                    discountedPrice: discountedPrice,
                    image: getCompleteImageUrl(product['photo']),
                    product: product,
                    isNetworkImage: true,
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            // View All Button
            LayoutBuilder(builder: (context, constraints) {
              final adjustedButtonFontSize = 14 / textScaleFactor;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextButton(
                  onPressed: () => Get.to(() => const BestOffers()),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    backgroundColor:
                        isDarkMode ? Colors.blueGrey.shade700 : Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'View all Best Offers products',
                        style: TextStyle(
                          fontSize: adjustedButtonFontSize,
                          color: isDarkMode
                              ? Colors.white
                              : CustomTheme.loginGradientStart,
                        ),
                      ),
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
              );
            }),

            const SizedBox(height: 10),
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
    required Map<String, dynamic> product,
    bool isNetworkImage = false,
  }) {
    final cartController = Get.find<CartController>();
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final _authController = Get.find<AuthController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          color: isDarkMode ? Colors.blueGrey : Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Section
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: isNetworkImage
                          ? Image.network(
                              image,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                );
                              },
                            )
                          : Image.asset(
                              image,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    if (discount != '0%')
                      Container(
                        margin: const EdgeInsets.only(left: 8, top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$discount OFF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12 / textScaleFactor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content Section - Using Expanded to push the button to the bottom
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name with multiple lines
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14 / textScaleFactor,
                            fontWeight: FontWeight.w500,
                          ),
                          // Allow multiple lines (2-3)
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Price section
                      Row(
                        children: [
                          if (originalPrice > 0) ...[
                            Text(
                              '₹${originalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 13 / textScaleFactor,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            '₹${discountedPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14 / textScaleFactor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Add button always at the bottom
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!_authController.isLoggedIn.value) {
                              final shouldLogin =
                                  await LoginRequiredDialog.show(context);
                              if (shouldLogin) {
                                // User chose to login
                                return;
                              }
                              return;
                            }

                            if (!cartController.isLoading.value) {
                              await cartController.addToCart(product);
                              Get.to(() => const CartScreen());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: CustomTheme.loginGradientStart,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                                color: CustomTheme.loginGradientStart),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 14 / textScaleFactor,
                            ),
                          ),
                        ),
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

  Widget _buildCarouselAdds() {
    final List<Map<String, dynamic>> testimonialsList = [
      {
        'name': 'Rahul Gupta',
        'location': 'Pune',
        'rating': 5,
        'review':
            'Great discounts on long-term medications! Generic Bharat has helped me manage my healthcare expenses more effectively.',
        'initials': 'RG',
      },
      {
        'name': 'Ankit Kumar',
        'location': 'Bangalore',
        'rating': 5,
        'review':
            'As a working professional, I rely on their quick and discreet delivery. The packaging is always professional and confidential.',
        'initials': 'AK',
      },
      {
        'name': 'Sonali Malhotra',
        'location': 'Jaipur',
        'rating': 5,
        'review':
            'Their customer support is exceptional. I had a query about a medication, and they connected me with a pharmacist immediately.',
        'initials': 'SM',
      },
      {
        'name': 'Rajesh Kumar',
        'location': 'Delhi',
        'rating': 5,
        'review':
            'Generic Bharat has been a lifesaver! Their comprehensive range of medicines at affordable prices is truly remarkable. Quick delivery and genuine products make them my go-to pharmacy.',
        'initials': 'RK',
      },
      {
        'name': 'Preeti Sharma',
        'location': 'Mumbai',
        'rating': 5,
        'review':
            'Their online platform is user-friendly and intuitive. I can easily find and order my prescribed medications with just a few clicks. The 24/7 customer support is always helpful.',
        'initials': 'PS',
      },
      {
        'name': 'Dr. Amit Patel',
        'location': 'Ahmedabad',
        'rating': 5,
        'review':
            'As a healthcare professional, I appreciate Generic Bharat\'s commitment to quality. Their medicines are always authentic, and their pricing is incredibly competitive.',
        'initials': 'AP',
      },
    ];

    // Validation check for the testimonials list length
    if (testimonialsList.length < 2 || testimonialsList.length > 6) {
      return const Center(
        child: Text(
          'The number of testimonials should be between 2 and 6.',
          style: TextStyle(color: Colors.red, fontSize: 16.0),
        ),
      );
    }

    final isDarkMode = Get.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                  "Customer Testimonials",
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
        CarouselSlider(
          options: CarouselOptions(
            height: 220.0,
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
          items: testimonialsList.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.8),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                item['rating'],
                                (index) => Icon(
                                  Icons.star,
                                  color: CustomTheme.loginGradientStart,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['review'],
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                                height: 1.4,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        CustomTheme.loginGradientStart,
                                        CustomTheme.loginGradientEnd,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: CustomTheme.loginGradientStart
                                            .withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      item['initials'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item['location'],
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.white70
                                                : Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<int>(
          valueListenable: _currentIndexNotifier,
          builder: (context, currentIndex, child) {
            return Center(
              child: CarouselIndicator(
                count: testimonialsList.length,
                index: currentIndex,
                // color: isDarkMode ? Colors.grey : Colors.grey[300],
                activeColor: CustomTheme.loginGradientStart,
                width: 50.0,
                height: 4.0,
                space: 8.0,
                cornerRadius: 2.0,
              ),
            );
          },
        ),
        const SizedBox(height: 35),
      ],
    );
  }

  Widget _buildVitaminsSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Obx(() {
      final items =
          controller.getItemsForCategory("MULTIVITAMINS AND MULTIMINERALS");

      if (controller.isCategoryItemsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (items.isEmpty) {
        return const Center(child: Text('No products available'));
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        padding: const EdgeInsets.only(top: 15, right: 4, left: 4, bottom: 15),
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
            // Title Section with LayoutBuilder
            LayoutBuilder(builder: (context, constraints) {
              final adjustedTitleFontSize = 16 / textScaleFactor;
              final adjustedSubtitleFontSize = 14 / textScaleFactor;

              return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Vitamins & Supplements',
                          style: TextStyle(
                            fontSize: adjustedTitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(' 💊',
                            style: TextStyle(fontSize: adjustedTitleFontSize)),
                      ],
                    ),
                    Text(
                      'Essential vitamins for your health',
                      style: TextStyle(
                        fontSize: adjustedSubtitleFontSize,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 15),

            // Products Container
            Container(
              padding: const EdgeInsets.only(
                  top: 5, right: 1.5, left: 1.5, bottom: 5),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black45 : const Color(0xFFF7F1FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 520,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two rows
                        crossAxisSpacing: 12, // Vertical spacing between cards
                        mainAxisSpacing: 7, // Horizontal spacing between cards
                        mainAxisExtent: 180, // Card width
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final product = items[index];
                        final originalPrice =
                            product['previous_price']?.toDouble() ?? 0.0;
                        final discountedPrice =
                            product['discount_price']?.toDouble() ?? 0.0;
                        final discount = originalPrice > 0
                            ? ((originalPrice - discountedPrice) /
                                    originalPrice *
                                    100)
                                .toStringAsFixed(0)
                            : '0';

                        return _buildMedicineCard(
                          discount: '$discount%',
                          name: product['name'],
                          originalPrice: originalPrice,
                          discountedPrice: discountedPrice,
                          image: getCompleteImageUrl(product['photo']),
                          product: product,
                          isNetworkImage: true,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  // View All Button with LayoutBuilder
                  LayoutBuilder(builder: (context, constraints) {
                    final adjustedButtonFontSize = 14 / textScaleFactor;

                    return TextButton(
                      onPressed: () => Get.to(() => AllVitaminsScreen()),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        backgroundColor: isDarkMode
                            ? Colors.blueGrey.shade700
                            : Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'View all ',
                            style: TextStyle(
                              fontSize: adjustedButtonFontSize,
                              color: isDarkMode
                                  ? Colors.white
                                  : CustomTheme.loginGradientStart,
                            ),
                          ),
                          Icon(
                            CupertinoIcons.right_chevron,
                            size: 16,
                            color: isDarkMode
                                ? Colors.white
                                : CustomTheme.loginGradientStart,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    });
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScaleFactor = MediaQuery.of(context).textScaleFactor;
        final adjustedTitleFontSize = 18 / textScaleFactor;
        final adjustedSubtitleFontSize = 14 / textScaleFactor;
        final buttonFontSize = 14 / textScaleFactor;

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
                    Text(
                      'Order with\nprescription',
                      style: TextStyle(
                        fontSize: adjustedTitleFontSize,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload prescription to place your order',
                      style: TextStyle(
                        fontSize: adjustedSubtitleFontSize,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (!Get.isRegistered<PrescriptionController>()) {
                          Get.put(PrescriptionController());
                        }
                        Get.to(() => const UploadPrescriptionScreen());
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
                      child: Text(
                        'Order now',
                        style: TextStyle(
                          fontSize: buttonFontSize,
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
      },
    );
  }

  Widget _buildCategoriesSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController homeController = Get.find<HomeController>();
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final adjustedFontSize = 16 / textScaleFactor;

    return Obx(() {
      if (homeController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (homeController.categories.isEmpty) {
        return const Center(child: Text('No Brands available'));
      }

      return Container(
        margin: const EdgeInsets.only(top: 10),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final textScaleFactor = MediaQuery.of(context).textScaleFactor;
                final adjustedFontSize = 15 / textScaleFactor;

                return Padding(
                  padding: const EdgeInsets.only(left: 16, top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shop By Brands',
                              style: TextStyle(
                                fontSize: adjustedFontSize,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              'Explore services by brand',
                              style: TextStyle(
                                fontSize: adjustedFontSize * 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            homeController.categories,
                            index,
                          );
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => AllCategories());
                      },
                      child: Row(
                        children: [
                          Text(
                            'View all Brands',
                            style: TextStyle(
                              fontSize: 14 / textScaleFactor,
                              color: isDarkMode
                                  ? Colors.white
                                  : CustomTheme.loginGradientStart,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.right_chevron,
                            size: 14 / textScaleFactor,
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
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategoriesColumn(List<dynamic> categories, int columnIndex) {
    return SizedBox(
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

    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var category = categories[index];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                  color: isDarkMode
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
                      : 'assets/images/medicine3.jpg',
                  width: 100,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/medicine3.jpg',
                      width: 100,
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
                style: TextStyle(
                  fontSize: 13 / textScaleFactor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Obx(() {
      final demandProducts = controller.getItemsForCategory("Demand Products");

      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final adjustedFontSize = 16 / textScaleFactor;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Popular items',
                                style: TextStyle(
                                  fontSize: adjustedFontSize,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                ' ✨',
                                style: TextStyle(
                                  fontSize: adjustedFontSize,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Items bought in your city',
                            style: TextStyle(
                              fontSize: adjustedFontSize * 0.8,
                            ),
                          ),
                        ],
                      ),
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
                          fontSize: adjustedFontSize * 0.8,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 520,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 7,
                  mainAxisExtent: 180,
                ),
                itemCount: demandProducts.length,
                itemBuilder: (context, index) {
                  final product = demandProducts[index];
                  final discount = product['previous_price'] != 0
                      ? ((product['previous_price'] -
                                  product['discount_price']) /
                              product['previous_price'] *
                              100)
                          .toStringAsFixed(0)
                      : '0';

                  return _buildMedicineCard(
                    discount: '$discount%',
                    name: product['name'],
                    originalPrice: product['previous_price']?.toDouble() ?? 0.0,
                    discountedPrice:
                        product['discount_price']?.toDouble() ?? 0.0,
                    image: getCompleteImageUrl(product['photo']),
                    product: product,
                    isNetworkImage: true,
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

// Keeping the original _buildMedicineCard function as the base for all sections

  Widget _buildPersonalSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final screenSize = MediaQuery.of(context).size;

    return Obx(() {
      final personalCareProducts =
          controller.getItemsForCategory("Beauty & Personal Care");

      if (controller.isCategoryItemsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (personalCareProducts.isEmpty) {
        return const Center(child: Text('No products available'));
      }

      return Container(
        margin: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.02,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black45 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color.fromARGB(255, 223, 223, 223)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Beauty & Personal Care',
                style: TextStyle(
                  fontSize: 16 / textScaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Personal care products',
                style: TextStyle(
                  fontSize: 12 / textScaleFactor,
                ),
              ),
              trailing: TextButton(
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 12 / textScaleFactor,
                    color: isDarkMode
                        ? Colors.white
                        : CustomTheme.loginGradientStart,
                  ),
                ),
                onPressed: () => Get.to(() => const PersonalCareListScreen()),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                // Define fixed size for each card
                final cardWidth = constraints.maxWidth / 6;

                // Determine the optimal number of rows based on item count
                // But keep the card size consistent
                final int crossAxisCount =
                    personalCareProducts.length <= 1 ? 1 : 2;

                return Container(
                  padding: EdgeInsets.all(screenSize.width * 0.04),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? Colors.blueGrey : const Color(0xfffff7ec),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    maxHeight: screenSize.height * 0.44,
                  ),
                  child: GridView.builder(
                    padding: EdgeInsets.only(top: 5),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.30, // Keep this consistent
                      crossAxisSpacing: width * 0.02,
                      mainAxisSpacing: width * 0.02,
                    ),
                    itemCount: personalCareProducts.length,
                    itemBuilder: (context, index) {
                      final product = personalCareProducts[index];
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
                        child: _buildPersonalCareCard(
                          product,
                          cardWidth, // Use consistent card width
                          textScaleFactor,
                          isDarkMode,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // View All Button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.04,
                vertical: screenSize.height * 0.01,
              ),
              child: TextButton(
                onPressed: () => Get.to(() => const PersonalCareListScreen()),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.04,
                    vertical: screenSize.width * 0.025,
                  ),
                  backgroundColor:
                      isDarkMode ? Colors.blueGrey.shade700 : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'View all Beauty & Personal Care products',
                        style: TextStyle(
                          fontSize: 12 / textScaleFactor,
                          color: isDarkMode
                              ? Colors.white
                              : CustomTheme.loginGradientStart,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.right_chevron,
                      size: screenSize.width * 0.05,
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
      );
    });
  }

  Widget _buildPersonalCareCard(
    Map<String, dynamic> product,
    double maxWidth,
    double textScaleFactor,
    bool isDarkMode,
  ) {
    final price = product['discount_price']?.toDouble() ?? 0.0;
    final originalPrice = product['previous_price']?.toDouble() ?? 0.0;
    final discount = originalPrice > 0
        ? ((originalPrice - price) / originalPrice * 100).toStringAsFixed(0)
        : '0';

    return Container(
      width: maxWidth,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.blueGrey.shade700 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top part with name and price
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(maxWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String? ?? 'Unknown Product',
                    style: TextStyle(
                      fontSize: 13 / textScaleFactor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (discount != '0') ...[
                    Text(
                      '$discount% OFF',
                      style: TextStyle(
                        fontSize: 12 / textScaleFactor,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      if (originalPrice > 0) ...[
                        Text(
                          '₹${originalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12 / textScaleFactor,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 4 / textScaleFactor),
                      ],
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12 / textScaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Image part
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Image.network(
                getCompleteImageUrl(product['photo'] as String? ?? ''),
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.error,
                      size: 24 / textScaleFactor,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

// Refactored Cheap & Best Medicine Section
  Widget _buildCleaningPestControlSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final screenSize = MediaQuery.of(context).size;

    return Obx(() {
      final cheapMedicines =
          controller.getItemsForCategory("CHEAP AND BEST MEDICINES");

      if (controller.isCategoryItemsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (cheapMedicines.isEmpty) {
        return const Center(child: Text('No products available'));
      }

      return Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.all(16),
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
            // Title Section - Keep original styling
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cheap & Best Medicines',
                        style: TextStyle(
                          fontSize: 15 / textScaleFactor,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'Removes hard stains & more',
                        style: TextStyle(
                          fontSize: 12 / textScaleFactor,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Products Grid with original color scheme
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.black45
                    : Color.fromARGB(255, 236, 255, 237), // Keep original color
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Products Grid with horizontal scrolling
                  SizedBox(
                    height: 520, // Match the Popular section height
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Same as Popular section
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 7,
                        mainAxisExtent: 180, // Same as Popular section
                      ),
                      itemCount: cheapMedicines.length,
                      itemBuilder: (context, index) {
                        final medicine = cheapMedicines[index];
                        final discountedPrice =
                            medicine['discount_price']?.toDouble() ?? 0.0;
                        final originalPrice =
                            medicine['previous_price']?.toDouble() ?? 0.0;
                        final discount = originalPrice > 0
                            ? ((originalPrice - discountedPrice) /
                                    originalPrice *
                                    100)
                                .toStringAsFixed(0)
                            : '0';

                        return _buildMedicineCard(
                          discount: '$discount%',
                          name: medicine['name'],
                          originalPrice: originalPrice,
                          discountedPrice: discountedPrice,
                          image: getCompleteImageUrl(medicine['photo']),
                          product: medicine,
                          isNetworkImage: true,
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // View All Button - Keep original styling
                  TextButton(
                    onPressed: () => Get.to(() => const CheapMedicinesScreen()),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      backgroundColor:
                          isDarkMode ? Colors.blueGrey.shade700 : Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'View all Cheap & Best Medicines',
                            style: TextStyle(
                              fontSize: 12 / textScaleFactor,
                              color: isDarkMode
                                  ? Colors.white
                                  : CustomTheme.loginGradientStart,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
      );
    });
  }

  Widget _buildDiabetesCareSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final adjustedFontSize = 16 / textScaleFactor;

    return Obx(() {
      final diabetesItems =
          controller.getItemsForCategory("SUGAR AND ANTI DIABETES MEDICINES");
      final displayItems =
          diabetesItems.take(10).toList(); // Take more items for scrolling

      return Container(
        margin: const EdgeInsets.only(top: 16, bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black45 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color.fromARGB(255, 223, 223, 223)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diabetes Care',
                        style: TextStyle(
                          fontSize: adjustedFontSize,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'Medicines & Healthcare Products',
                        style: TextStyle(
                          fontSize: adjustedFontSize * 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Get.to(() => const DiabetesCareProductsScreen()),
                  child: Text(
                    'View all',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white
                          : CustomTheme.loginGradientStart,
                      fontSize: adjustedFontSize * 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black45 : const Color(0xfffce8e7),
                borderRadius: BorderRadius.circular(20),
              ),
              // No need for additional SizedBox since the carousel now manages its own height
              child: VerticalRollingCarousel(
                items: displayItems,
                isDarkMode: isDarkMode,
                textScaleFactor: textScaleFactor,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNeedHelpSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    Future<void> _makePhoneCall() async {
      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: '+919119772993',
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
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Need help with buying?',
                  style: TextStyle(
                    fontSize: 20 / textScaleFactor,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Call us between 9 AM and 9 PM to help you find your medicines',
                  style: TextStyle(
                    fontSize: 14 / textScaleFactor,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                FittedBox(
                  child: InkWell(
                    onTap: _makePhoneCall,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? CustomTheme.loginGradientStart.withOpacity(0.2)
                            : CustomTheme.loginGradientStart.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone,
                            color: isDarkMode
                                ? Colors.white
                                : CustomTheme.loginGradientStart,
                            size: 18 / textScaleFactor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Call us and order',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white
                                  : CustomTheme.loginGradientStart,
                              fontSize: 16 / textScaleFactor,
                              fontWeight: FontWeight.w500,
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
          Expanded(
            flex: 2,
            child: Image.asset(
              'assets/images/call.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthcareDevicesSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final HomeController controller = Get.find<HomeController>();
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final adjustedFontSize = 16 / textScaleFactor;

    return Obx(() {
      final devices = controller.getItemsForCategory("MEDICAL DEVICES");

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical Devices',
                        style: TextStyle(
                          fontSize: adjustedFontSize,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'Quality healthcare devices',
                        style: TextStyle(
                          fontSize: adjustedFontSize * 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => const MedicalDevicesScreen());
                  },
                  child: Text(
                    'View all',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white
                          : CustomTheme.loginGradientStart,
                      fontSize: adjustedFontSize * 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 500,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 180,
                ),
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
    required String imageUrl,
    required String price,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Calculate percentage discount
    double discountPercentage = 0.0;
    if (discount.isNotEmpty) {
      // Extract numeric values from price and previous price
      final priceValue = double.parse(price.replaceAll('₹', ''));
      final previousPriceValue =
          double.parse(discount.replaceAll('Save ₹', '')) + priceValue;
      discountPercentage =
          ((previousPriceValue - priceValue) / previousPriceValue * 100)
              .roundToDouble();
    }

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: isDarkMode ? Colors.blueGrey : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  getCompleteImageUrl(imageUrl),
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
            ),
            Container(
              color: const Color(0xffeff8ff),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 12, right: 12, top: 5, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14 / textScaleFactor,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (discountPercentage > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${discountPercentage.toStringAsFixed(0)}% off',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14 / textScaleFactor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 14 / textScaleFactor,
                        fontWeight: FontWeight.bold,
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
