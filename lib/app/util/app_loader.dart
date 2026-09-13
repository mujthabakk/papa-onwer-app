import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class AppLoader {
  static OverlayEntry? _entry;

  static void show([String? message]) {
    if (_entry != null) return;
    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: ThemeProvider.appColor,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  (message ?? 'Please wait').tr,
                  style: const TextStyle(
                    fontFamily: 'bold',
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
    if (Get.isDialogOpen == true && Get.overlayContext != null) {
      Navigator.of(Get.overlayContext!).pop();
    }
  }

  static Future<T> run<T>(Future<T> Function() action, {String? message}) async {
    show(message);
    try {
      return await action();
    } finally {
      hide();
    }
  }
}
