import 'package:get/get.dart';

import '../controller/addresscontroller.dart';

class AddressBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressController>(() => AddressController());
  }
}