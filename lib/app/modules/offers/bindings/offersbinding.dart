import 'package:get/get.dart';

import '../controller/offerscontroller.dart';

class OffersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OffersController>(() => OffersController());
  }
}
