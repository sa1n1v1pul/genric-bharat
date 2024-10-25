import 'package:get/get.dart';
import 'package:handyman/app/modules/offers/controller/offerscontroller.dart';

class OffersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OffersController>(() => OffersController());
  }
}
