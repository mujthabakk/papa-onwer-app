import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/product/api/product_auth_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/product_signup_controller.dart';

class ProductSignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ProductSignupController(parser: Get.find<ProductAuthParser>()),
    );
  }
}
