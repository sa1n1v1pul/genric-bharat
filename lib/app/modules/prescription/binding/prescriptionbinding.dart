import 'package:get/get.dart';
import '../controller/prescriptioncontroller.dart';


class PrescriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrescriptionController>(() => PrescriptionController());
  }
}