import 'package:get/get.dart';

import '../../cart/controller/cartcontroller.dart';
import '../controller/deliverycontroller.dart';

class DeliveryDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => DeliveryDetailsController());

  }
}