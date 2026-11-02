import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';

class ProductUser {
  ProductUser._();

  static String typeOf(SharedPreferencesManager prefs) {
    return (prefs.getString('type') ?? '').toLowerCase();
  }

  static bool isProduct(SharedPreferencesManager prefs) {
    return typeOf(prefs) == 'product';
  }

  static bool hideServices(SharedPreferencesManager prefs) => isProduct(prefs);

  static bool hideSlots(SharedPreferencesManager prefs) => isProduct(prefs);

  static bool hideBookingHistory(SharedPreferencesManager prefs) =>
      isProduct(prefs);

  static void saveSession(
    SharedPreferencesManager prefs,
    Map<String, dynamic> myMap,
  ) {
    final user = myMap['user'] is Map
        ? Map<String, dynamic>.from(myMap['user'] as Map)
        : <String, dynamic>{};
    final type = (user['type'] ?? myMap['type'] ?? myMap['user_type'] ?? '')
        .toString()
        .toLowerCase();
    final isProductUser = type == 'product';
    prefs.putString('type', type);
    prefs.putBool('is_product_user', isProductUser);
    prefs.putString('app_mode', isProductUser ? 'product' : type);
    prefs.putBool('hide_services', isProductUser);
    prefs.putBool('hide_slots', isProductUser);
    prefs.putBool('hide_booking_history', isProductUser);
  }
}
