import 'package:get/get.dart';
import 'package:handyman/app/modules/Message/controller/messagecontroller.dart';


class Messagebindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessageController>(() => MessageController());
  }
}
