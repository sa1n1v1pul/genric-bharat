import 'package:get/get.dart';

import '../controller/deliverycontroller.dart';

class DeliveryDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryDetailsController>(() => DeliveryDetailsController());
  }
}