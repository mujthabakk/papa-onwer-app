/*Papabear*/
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_services_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/ads_publish_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/previous_appointments_controller.dart';

class PreviousAppointmentsBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => PreviousAppointmentController(parser: Get.find()),
    );
  }
}
