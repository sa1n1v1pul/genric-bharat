import 'package:get/get.dart';
import '../controllers/myordercontroller.dart';
import '../../delivery/controller/deliverycontroller.dart';
import '../../cart/controller/cartcontroller.dart';

class MyOrdersBinding implements Bindings {
  @override
  void dependencies() {
    // Ensure DeliveryDetailsController is registered first
    if (!Get.isRegistered<DeliveryDetailsController>()) {
      Get.put(DeliveryDetailsController(), permanent: true);
    }

    // Then register other controllers
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController(), permanent: true);
    }

    if (!Get.isRegistered<MyOrdersController>()) {
      Get.put(MyOrdersController(), permanent: true);
    }
  }
}