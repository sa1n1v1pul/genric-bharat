// cart_bindings.dart
import 'package:get/get.dart';

import '../../delivery/controller/deliverycontroller.dart';
import '../controller/cartcontroller.dart';

class CartBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => DeliveryDetailsController());

  }
}