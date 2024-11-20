import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/core/theme/theme.dart';
import 'app/modules/api_endpoints/api_provider.dart';
import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/modules/auth/controllers/login_controller.dart';
import 'app/modules/cart/controller/cartcontroller.dart';
import 'app/modules/cart/controller/cartservice.dart';
import 'app/modules/location/binding/location_binding.dart';
import 'app/modules/onboarding/startup_view.dart';
import 'app/modules/routes/app_pages.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await InitializationService.initServices();
    runApp(const MyApp());
  } catch (e) {
    print('Fatal error during app initialization: $e');
  }
}

class InitializationService {
  static Future<void> initServices() async {
    try {
      print('Starting services initialization...');

      // Initialize GetStorage
      await GetStorage.init();
      print('✓ GetStorage initialized');

      // Initialize Location Services
      LocationBinding().dependencies();
      print('✓ Location services initialized');

      // Set Screen Orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      print('✓ Screen orientation set');

      // Initialize Theme
      CustomTheme.loadSavedTheme();
      print('✓ Theme loaded');

      // Initialize Core Controllers
      Get.put(ApiProvider());
      Get.put(ThemeController());
      Get.put(AuthController(), permanent: true);
      Get.put(LoginController());
      print('✓ Core controllers initialized');

      // Initialize User Service
      final userService = UserService();
      await userService.initialize();
      Get.put(userService);

      // Initialize CartApiService but don't initialize CartController yet
      final cartService = CartApiService();
      await cartService.initializeService();
      Get.put(cartService);
      print('✓ Cart service initialized');

    } catch (e, stackTrace) {
      print('❌ Error during initialization: $e');
      print('Stack trace: $stackTrace');
    }

    print('Services initialization completed');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Genric Bharat',
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: CustomTheme.themeMode,
      home: const StartupView(),
      getPages: AppPages.routes,
      initialBinding: BindingsBuilder(() {
        // Cart controller will be initialized after login
        Get.lazyPut(() => CartController(), fenix: true);
      }),
    );
  }
}
class ThemeController extends GetxController {
  void changeTheme(int colorIndex) {
    CustomTheme.changeTheme(colorIndex);
    update(['themeBuilder']);
  }
}