import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/login_controller.dart';
import '../../data/services/auth_services.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize services first
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);

    // Then controllers that depend on the services
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
  }
}
