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
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  LocationBinding().dependencies();

  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  CustomTheme.loadSavedTheme();
  Get.put(ThemeController());
  Get.lazyPut(() => ApiProvider());
  Get.put(AuthController());
  Get.put(LoginController());
  Get.put(CartController());
  Get.put(CartApiService());
  runApp(const MyApp());
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
    );
  }
}

class ThemeController extends GetxController {
  void changeTheme(int colorIndex) {
    CustomTheme.changeTheme(colorIndex);
    update(['themeBuilder']);
  }
}
