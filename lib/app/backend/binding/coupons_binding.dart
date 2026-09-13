/*Papabear*/
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_services_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/ads_managing_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/ads_publish_controller.dart';

import '../../controller/coupon_controller.dart';

class CouponsBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => CouponsController(parser: Get.find()),
    );
  }
}
