import 'package:get/get.dart';
import 'package:handyman/app/modules/home/controller/homecontroller.dart';

class BookingBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
