import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_services_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/ads_managing_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/ads_publish_controller.dart';

class AdsManagingBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => AdsManagingController(parser: Get.find()),
    );
  }
}
