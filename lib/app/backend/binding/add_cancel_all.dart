import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_packages_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/cancellAll_controller.dart';

class CancelAllBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => CancelAllAppointmentController(parser: Get.find()),
    );
  }
}
