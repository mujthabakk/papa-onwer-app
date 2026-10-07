import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';

/// Country value sent as `X-App-Country` and payment body `country`.
class AppCountry {
  AppCountry._();

  static String headerValue(SharedPreferencesManager prefs) {
    final preferred = (prefs.getString('preferred_country') ?? '').trim();
    if (preferred.isNotEmpty) return preferred;
    return fromCode(prefs.getString('country'));
  }

  static String fromCode(String? code) {
    final key = (code ?? '').trim().toUpperCase();
    if (key == 'QA' || key == 'QAT') return 'Qatar';
    if (key == 'IN' || key == 'IND') return 'India';
    if (key == 'AE' || key == 'ARE' || key == 'UAE') {
      return 'United Arab Emirates';
    }
    if (key.isEmpty) return '';
    return code!.trim();
  }
}
