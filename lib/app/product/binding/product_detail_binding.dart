import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/product_detail_controller.dart';

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ProductDetailController(parser: Get.find()),
    );
  }
}
