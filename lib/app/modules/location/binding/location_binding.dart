import 'package:get/get.dart';
import 'package:handyman/app/modules/api_endpoints/api_provider.dart';
import 'package:handyman/app/modules/home/views/mapview.dart';
import '../controller/location_controller.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {  Get.lazyPut(() => ApiProvider());
  Get.lazyPut(() => LocationPage(0, 0));
    // Ensure single instance
    if (!Get.isRegistered<LocationController>()) {
      Get.put<LocationController>(LocationController(), permanent: true);
      print("LocationController registered");
    }
  }
}
