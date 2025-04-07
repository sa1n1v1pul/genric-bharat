import 'package:genric_bharat/app/modules/cart/controller/cartcontroller.dart';
import 'package:genric_bharat/app/modules/cart/controller/cartservice.dart';
import 'package:genric_bharat/app/modules/profile/controller/profile_controller.dart';
import 'package:get/get.dart';

class AppStateController extends GetxController {
  static AppStateController get to => Get.find();
  final _isInitialized = false.obs;

  bool get isInitialized => _isInitialized.value;

  Future<void> initializeApp({int? userId}) async {
    try {
      if (userId == null) {
        throw Exception('User ID is required for initialization');
      }

      // Ensure CartApiService is initialized first
      if (!Get.isRegistered<CartApiService>()) {
        final cartService = Get.put(CartApiService());
        await cartService.initializeService();
      }

      // Initialize ProfileController
      final profileController = Get.put(ProfileController());
      await profileController.initialize(userId);

      // Initialize CartController last
      final cartController = Get.put(CartController());
      cartController.currentUserId = userId;
      await cartController.initializeCart(userId: userId);

      _isInitialized.value = true;
      update();
    } catch (e) {
      print('Error initializing app state: $e');
      _isInitialized.value = false;
      throw e; // Rethrow the error to be handled by the caller
    }
  }

  void resetApp() {
    _isInitialized.value = false;
    update();
  }
}
