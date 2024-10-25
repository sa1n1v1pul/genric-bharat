import 'package:get/get.dart';

import '../../home/controller/homecontroller.dart';

class BookingBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
