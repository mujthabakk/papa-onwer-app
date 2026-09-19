import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';

class AppNav {
  static void closeOverlays() {
    try {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (_) {}
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  static Future<T?>? toNamed<T>(
    String route, {
    dynamic arguments,
    bool preventDuplicates = true,
  }) {
    closeOverlays();
    if (preventDuplicates && Get.currentRoute == route) return null;
    return Get.toNamed<T>(
      route,
      arguments: arguments,
      preventDuplicates: preventDuplicates,
    );
  }

  static Future<T?>? openPremium<T>() {
    return toNamed<T>(AppRouter.getPremiumRoute());
  }
}
