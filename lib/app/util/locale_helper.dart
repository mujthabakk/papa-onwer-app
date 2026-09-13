import 'package:flutter/material.dart';
import 'package:ultimate_salon_owner_flutter/app/util/translator.dart';

class LocaleHelper {
  static const Map<String, String> _apiKeyToLabel = {
    'success': 'Success',
    'validation_error': 'Validation Error',
    'data_not_found': 'Data not found',
    'booking_created': 'Booking created',
    'email_required': 'Email is required',
    'email_is_not_valid': 'Email is not valid',
    'password_required': 'Password is required',
    'password_does_not_match': 'Password does not match',
    'something_went_wrong': 'Something went wrong',
    'access_denied': 'Access denied',
    'please_wait': 'Please wait',
    'languages': 'Languages',
    'language': 'Language',
    'country': 'Country',
    'welcome_back': 'Welcome Back!',
    'login': 'Login',
    'sign_in': 'Sign In',
    'submit': 'Submit',
    'save': 'Save',
    'cancel': 'Cancel',
    'verify': 'Verify',
    'connection_failed': 'Connection Failed',
    'no_internet_connection': 'No Internet Connection',
    'select_language': 'Select Language',
    'select_country': 'Select Country',
    'select_country_code': 'Select Country Code',
    'language_and_country': 'Language & Country',
    'fields_required': 'Fields Required',
    'all_fields_are_required': 'All fields are required',
    'developed_by': 'Developed By ',
  };

  static String normalizeLanguageCode(String languageCode) {
    final raw = languageCode.trim().toLowerCase();
    if (raw.isEmpty) return 'en';
    final short = raw.split(RegExp(r'[_-]')).first;
    switch (short) {
      case 'ar':
      case 'arabic':
        return 'ar';
      case 'hi':
      case 'hindi':
        return 'hi';
      case 'es':
      case 'spanish':
        return 'es';
      case 'en':
      case 'english':
      default:
        if (short == 'en') return 'en';
        // Keep known short codes; fall back to first segment.
        return short.length <= 3 ? short : 'en';
    }
  }

  static String translationKey(String languageCode) {
    switch (normalizeLanguageCode(languageCode)) {
      case 'ar':
        return 'ar_AE';
      case 'hi':
        return 'hi_IN';
      case 'es':
        return 'es_DE';
      default:
        return 'en_US';
    }
  }

  static Locale toFlutterLocale(String languageCode) {
    switch (normalizeLanguageCode(languageCode)) {
      case 'ar':
        return const Locale('ar', 'AE');
      case 'hi':
        return const Locale('hi', 'IN');
      case 'es':
        return const Locale('es', 'DE');
      default:
        return const Locale('en', 'US');
    }
  }

  static Map<String, String> mergedTranslations(
    String languageCode,
    Map<String, String> apiStrings,
  ) {
    final localeKey = translationKey(languageCode);
    final baseKeys = LocaleString().keys;
    final enBase = baseKeys['en_US'] ?? {};
    final langBase = baseKeys[localeKey] ?? enBase;
    final merged = Map<String, String>.from(langBase);

    apiStrings.forEach((key, value) {
      if (value.isEmpty) return;
      _applyApiString(merged, key, value, enBase);
    });

    _apiKeyToLabel.forEach((apiKey, label) {
      final value = apiStrings[apiKey];
      if (value != null && value.isNotEmpty) {
        merged[label] = value;
      }
    });

    return merged;
  }

  /// Register both `ar` and `ar_AE` (and similar) so GetX always finds strings.
  static Map<String, Map<String, String>> translationMaps(
    String languageCode,
    Map<String, String> apiStrings,
  ) {
    final base = LocaleString().keys;
    final merged = mergedTranslations(languageCode, apiStrings);
    final fullKey = translationKey(languageCode);
    final shortKey = languageCode.split('_').first.toLowerCase();
    return {
      ...base,
      fullKey: merged,
      shortKey: merged,
    };
  }

  static void _applyApiString(
    Map<String, String> merged,
    String apiKey,
    String value,
    Map<String, String> enBase,
  ) {
    merged[apiKey] = value;
    merged[_titleCase(apiKey)] = value;

    final mapped = _apiKeyToLabel[apiKey];
    if (mapped != null) {
      merged[mapped] = value;
    }

    for (final entry in enBase.entries) {
      if (_normalize(entry.key) == apiKey) {
        merged[entry.key] = value;
      }
    }
  }

  static String? lookupApiString(
    String source,
    Map<String, String> apiStrings,
  ) {
    if (apiStrings.isEmpty) return null;

    if (apiStrings.containsKey(source)) {
      return apiStrings[source];
    }

    final normalized = _normalize(source);
    if (apiStrings.containsKey(normalized)) {
      return apiStrings[normalized];
    }

    for (final entry in apiStrings.entries) {
      final mapped = _apiKeyToLabel[entry.key];
      if (mapped == source) {
        return entry.value;
      }
    }
    return null;
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
  }

  static String _titleCase(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
