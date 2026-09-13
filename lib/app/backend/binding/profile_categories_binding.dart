import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_business_controller.dart';

class ProfileCategoriesBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => ProfileCategoriesController(parser: Get.find()),
    );
  }
}
