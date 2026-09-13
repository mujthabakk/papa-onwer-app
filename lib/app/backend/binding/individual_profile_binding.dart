/*Papabear*/
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_individual_controller.dart';

class IndividualProfileBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => IndividualProfileController(parser: Get.find()),
    );
  }
}
