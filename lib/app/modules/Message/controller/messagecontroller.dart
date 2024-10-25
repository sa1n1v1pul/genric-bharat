
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class MessageController extends GetxController {
  RxList<Map<String, dynamic>> chatMessages = <Map<String, dynamic>>[].obs;

  void sendMessage(String message) {
    chatMessages.add({
      'message': message,
      'isMe': true,
      'timestamp': DateTime.now(),
    });
  }

  void receiveMessage(String message) {
    chatMessages.add({
      'message': message,
      'isMe': false,
      'timestamp': DateTime.now(),
    });
  }
}