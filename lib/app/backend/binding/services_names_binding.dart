/*Papabear*/
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_names_controller.dart';

class ServicesNamesBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => ServicesNamesController(parser: Get.find()),
    );
  }
}
