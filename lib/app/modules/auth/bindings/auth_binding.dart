import 'package:get/get.dart';
import 'package:handyman/app/modules/auth/controllers/auth_controller.dart';

import '../../data/services/auth_services.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
