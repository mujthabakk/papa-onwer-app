/*Papabear*/
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/stylist_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/stylist_service_controller.dart';

class StylistServicesBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => StylistServiceController(parser: Get.find()),
    );
  }
}
