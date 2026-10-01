import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

/// Country/partner tax gate from `pricing/getTaxAvailability`.
/// When [isAvailable] is false, all tax-related UI must be hidden.
class TaxHelper {
  TaxHelper._();

  static const _keyAvailable = 'tax_available';
  static const _keyType = 'tax_type';

  static SharedPreferencesManager? get _prefs =>
      Get.isRegistered<SharedPreferencesManager>()
          ? Get.find<SharedPreferencesManager>()
          : null;

  /// Defaults to `true` until the API says otherwise (keeps existing markets).
  static bool get isAvailable {
    final prefs = _prefs;
    if (prefs == null || prefs.isKeyExists(_keyAvailable) != true) {
      return true;
    }
    return prefs.getBool(_keyAvailable);
  }

  static String get taxType {
    final raw = _prefs?.getString(_keyType) ?? '';
    return raw.trim().isEmpty ? 'VAT' : raw.trim();
  }

  static void save({required bool available, String? type}) {
    final prefs = _prefs;
    if (prefs == null) return;
    prefs.putBool(_keyAvailable, available);
    if (type != null && type.trim().isNotEmpty) {
      prefs.putString(_keyType, type.trim());
    }
  }

  static void applyFromBody(dynamic body) {
    if (body is! Map) return;
    final map = Map<String, dynamic>.from(body);
    Map<String, dynamic>? data;
    if (map['data'] is Map) {
      data = Map<String, dynamic>.from(map['data'] as Map);
    }
    final availableRaw = data?['tax_available'] ?? map['tax_available'];
    final typeRaw = data?['tax_type'] ?? map['tax_type'];
    if (availableRaw == null && typeRaw == null) return;

    bool available = isAvailable;
    if (availableRaw is bool) {
      available = availableRaw;
    } else if (availableRaw != null) {
      final text = availableRaw.toString().toLowerCase();
      available = text == '1' || text == 'true' || text == 'yes';
    }
    save(
      available: available,
      type: typeRaw?.toString(),
    );
  }

  static Future<void> refresh({dynamic uid}) async {
    if (!Get.isRegistered<ApiService>() || _prefs == null) return;
    final prefs = _prefs!;
    if (!prefs.hasOwnerSession()) return;

    final api = Get.find<ApiService>();
    final token = prefs.getString('token') ?? '';
    final ownerId = uid ??
        int.tryParse(prefs.getString('uid') ?? '') ??
        prefs.getString('uid');
    if (token.isEmpty || ownerId == null || '$ownerId'.isEmpty) return;

    try {
      final response = await api.postPrivate(
        AppConstants.getTaxAvailability,
        {'uid': ownerId},
        token,
      );
      if (response.statusCode == 200) {
        applyFromBody(response.body);
      }
    } catch (_) {}
  }
}
