import 'package:get/get.dart';

import '../controller/cartcontroller.dart';

class CartMiddleware extends GetMiddleware {
  @override
  GetPageBuilder? onPageBuildStart(dynamic page) {
    Get.find<CartController>().refreshAddressStatus();
    return super.onPageBuildStart(page);
  }
}