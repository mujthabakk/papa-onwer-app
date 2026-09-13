/*Papabear*/
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/calendar_controller.dart';

import '../../controller/holiday_controller.dart';

class HolidayBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => HolidayController(parser: Get.find()),
    );
  }
}
