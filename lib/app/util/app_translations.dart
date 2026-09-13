import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/locale_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/translator.dart';

/// Base translations merged with API UI strings at runtime.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys {
    if (!Get.isRegistered<LocaleController>()) {
      final base = LocaleString().keys;
      // Alias short codes so Locale('ar') still resolves.
      return {
        ...base,
        'en': base['en_US'] ?? {},
        'ar': base['ar_AE'] ?? {},
        'hi': base['hi_IN'] ?? {},
        'es': base['es_DE'] ?? {},
      };
    }
    final locale = Get.find<LocaleController>();
    return LocaleHelper.translationMaps(
      locale.languageCode,
      locale.uiStrings,
    );
  }
}

/// Prefer API UI string, then GetX translation.
extension LocaleText on String {
  String get trL {
    if (Get.isRegistered<LocaleController>()) {
      final translated = Get.find<LocaleController>().translate(this);
      if (translated != null) {
        return translated;
      }
    }
    return tr;
  }
}
