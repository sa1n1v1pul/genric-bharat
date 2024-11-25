import 'package:get/get.dart';
import '../controller/profile_controller.dart';

class VlogsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
          () => ProfileController(),
      fenix: true,
    );
  }
}