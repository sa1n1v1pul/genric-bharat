import 'package:get/get.dart';

import '../controller/messagecontroller.dart';

class Messagebindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessageController>(() => MessageController());
  }
}
