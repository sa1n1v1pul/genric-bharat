// cart_bindings.dart
import 'package:get/get.dart';

import '../controller/cartcontroller.dart';

class CartBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
  }
}