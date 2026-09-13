import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/connect_links_controller.dart';

class ConnectLinksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConnectLinksController(parser: Get.find()));
  }
}
