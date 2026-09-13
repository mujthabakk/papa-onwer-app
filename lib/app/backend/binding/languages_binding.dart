import 'package:get/get.dart';

class LanguagesBinding extends Bindings {
  @override
  void dependencies() {
    // LocaleController is registered permanently in MainBinding.
    // Bootstrap is deferred to LanguagesScreen after the first frame.
  }
}
