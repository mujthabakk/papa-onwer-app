/*Papabear*/
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_services_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/ads_managing_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/ads_publish_controller.dart';

import '../../controller/withdrawal_controller.dart';

class WithdrawalsBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => WithdrawalsController(parser: Get.find()),
    );
  }
}
