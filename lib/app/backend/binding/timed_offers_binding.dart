import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/timed_offers_controller.dart';

class TimedOffersBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => TimedOffersController(parser: Get.find()),
    );
  }
}
