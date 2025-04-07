// ignore_for_file: library_private_types_in_public_api, use_super_parameters

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:genric_bharat/app/modules/MyOrders/controllers/myordercontroller.dart';
import 'package:genric_bharat/app/modules/auth/controllers/auth_controller.dart';
import 'package:genric_bharat/app/modules/cart/controller/cartcontroller.dart';
import 'package:genric_bharat/app/modules/cart/view/cartscreen.dart';
import 'package:genric_bharat/app/modules/delivery/controller/deliverycontroller.dart';
import 'package:genric_bharat/app/modules/home/controller/addresscontroller.dart';
import 'package:genric_bharat/app/modules/home/controller/homecontroller.dart';
import 'package:genric_bharat/app/modules/location/controller/location_controller.dart';
import 'package:genric_bharat/app/modules/profile/controller/profile_controller.dart';
import 'package:genric_bharat/app/modules/profile/views/profile_view.dart';
import 'package:genric_bharat/app/modules/profile/views/vlogsitem.dart';
import 'package:genric_bharat/app/modules/widgets/loginrequireddialog.dart';
import 'package:get/get.dart';
import '../MyOrders/views/myorderview.dart';
import '../home/views/homepage.dart';

import 'bottombar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late final AuthController _authController;
  late final HomeController _homeController;
  late final CartController _cartController;

  int _selectedIndex = 2; // Start with Home selected
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers safely in initState
    _authController = Get.find<AuthController>();
    // Ensure HomeController exists
    _homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    // Ensure CartController exists
    _cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
  }

  Future<void> _refreshData() async {
    // Show loading indicator

    // Refresh data from HomeController
    await _homeController.fetchCategories();
    await _homeController.fetchCategoryItems();
    await _homeController.fetchSliders();

    // Refresh cart data if user is logged in
    if (_authController.isLoggedIn.value) {
      await _cartController.fetchCart();
      await _cartController.fetchAddresses();
      await _cartController.fetchPromoCodes();

      // Refresh MyOrders data
      if (Get.isRegistered<MyOrdersController>()) {
        try {
          final myOrdersController = Get.find<MyOrdersController>();
          await myOrdersController.fetchOrders();
        } catch (e) {
          // Handle error silently if MyOrdersController is not found
        }
      }

      // Refresh Profile data
      if (Get.isRegistered<ProfileController>()) {
        try {
          final profileController = Get.find<ProfileController>();
          await profileController.getUserData();
          await profileController.fetchVlogs();
        } catch (e) {
          // Handle error silently if ProfileController is not found
        }
      }

      // Refresh Address data
      if (Get.isRegistered<AddressController>()) {
        try {
          final addressController = Get.find<AddressController>();
          await addressController.loadSavedAddress();
        } catch (e) {
          // Handle error silently if AddressController is not found
        }
      }

      // Refresh Location data
      if (Get.isRegistered<LocationController>()) {
        try {
          final locationController = Get.find<LocationController>();
          await locationController.getCurrentLocation();
        } catch (e) {
          // Handle error silently if LocationController is not found
        }
      }

      // Refresh Delivery Details data
      if (Get.isRegistered<DeliveryDetailsController>()) {
        try {
          final deliveryDetailsController =
              Get.find<DeliveryDetailsController>();
          await deliveryDetailsController.loadUserDetails();
          deliveryDetailsController.updateOrderAmounts();
        } catch (e) {
          // Handle error silently if DeliveryDetailsController is not found
        }
      }
    }
    // Show success message
  }

  Widget _buildScreen(int index) {
    // Wrap each screen with RefreshIndicator
    Widget screen;
    switch (index) {
      case 0:
        screen = GetBuilder<AuthController>(
          builder: (controller) {
            return controller.isLoggedIn.value
                ? const CartScreen(fromBottomNav: true)
                : const HomePage();
          },
        );
        break;
      case 1:
        screen = GetBuilder<AuthController>(
          builder: (controller) {
            return controller.isLoggedIn.value
                ? const VlogsListScreen(fromBottomNav: true)
                : const HomePage();
          },
        );
        break;
      case 2:
        screen = const HomePage();
        break;
      case 3:
        screen = GetBuilder<AuthController>(
          builder: (controller) {
            return controller.isLoggedIn.value
                ? MyOrdersView(fromBottomNav: true)
                : const HomePage();
          },
        );
        break;
      case 4:
        screen = GetBuilder<AuthController>(
          builder: (controller) {
            return controller.isLoggedIn.value
                ? ProfileView()
                : const HomePage();
          },
        );
        break;
      default:
        screen = const HomePage();
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshData,
      color: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      displacement: 40,
      strokeWidth: 3,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: screen,
    );
  }

  // Show exit confirmation dialog
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
        ) ??
        false;
  }

  void _onItemTapped(int index) async {
    if (index == 2) {
      setState(() => _selectedIndex = index);
      return;
    }

    if (!_authController.isLoggedIn.value) {
      final shouldLogin = await LoginRequiredDialog.show(context);
      if (shouldLogin) {
        // User chose to login
        return;
      }
      return;
    }

    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _buildScreen(_selectedIndex),
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          onPressed: () => _onItemTapped(2),
          backgroundColor: _selectedIndex == 2 ? primaryColor : Colors.grey,
          child: const Icon(
            FontAwesome.home,
            color: Colors.white,
            size: 30,
          ).animate(target: _selectedIndex == 2 ? 1 : 0).custom(
                duration: 300.ms,
                builder: (context, value, child) => Transform.translate(
                  offset: Offset(
                    4 * sin(value * 2 * 3.14159),
                    2 * sin(value * 4 * 3.14159),
                  ),
                  child: child,
                ),
              ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
