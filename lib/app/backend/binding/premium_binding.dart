/*Papabear*/
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/premium_controller.dart';

class PremiumBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => PremiumController(
        parser: Get.find(),
        upgradeParser: Get.find(),
      ),
    );
  }
}
