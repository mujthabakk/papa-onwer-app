import 'package:get/get.dart';

import '../../controller/facilities_controller.dart';

class FacilitiesBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => FacilitiesController(parser: Get.find()),
    );
  }
}
