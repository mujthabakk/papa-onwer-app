class ApiLanguageModel {
  final int id;
  final String code;
  final String name;
  final String nativeName;
  final String direction;
  final bool isRtl;

  ApiLanguageModel({
    required this.id,
    required this.code,
    required this.name,
    this.nativeName = '',
    this.direction = 'ltr',
    this.isRtl = false,
  });

  factory ApiLanguageModel.fromJson(Map<String, dynamic> json) {
    return ApiLanguageModel(
      id: _toInt(json['id']),
      code: json['code']?.toString() ?? 'en',
      name: json['name']?.toString() ?? '',
      nativeName:
          json['native_name']?.toString() ?? json['name']?.toString() ?? '',
      direction: json['direction']?.toString() ?? 'ltr',
      isRtl: _parseBool(json['is_rtl']) ||
          json['direction']?.toString().toLowerCase() == 'rtl',
    );
  }
}

class LocaleCountryModel {
  final int id;
  final String name;
  final String nameEn;
  final String code;
  final String countryCode;
  final String currency;
  final String currencySymbol;
  final List<String> languages;

  LocaleCountryModel({
    this.id = 0,
    required this.name,
    this.nameEn = '',
    required this.code,
    this.countryCode = '',
    this.currency = '',
    this.currencySymbol = '',
    this.languages = const [],
  });

  factory LocaleCountryModel.fromJson(Map<String, dynamic> json) {
    return LocaleCountryModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      currency: json['currency']?.toString() ??
          json['currency_code']?.toString() ??
          '',
      currencySymbol: json['currency_symbol']?.toString() ?? '',
      languages: _toStringList(json['languages']),
    );
  }
}

class LocaleConfigData {
  final String locale;
  final String defaultLanguage;
  final String defaultCountry;
  final String selectedLanguage;
  final String selectedCountry;
  final List<LocaleCountryModel> countries;

  LocaleConfigData({
    this.locale = 'en',
    this.defaultLanguage = 'en',
    this.defaultCountry = 'India',
    this.selectedLanguage = 'en',
    this.selectedCountry = 'India',
    this.countries = const [],
  });

  factory LocaleConfigData.fromJson(Map<String, dynamic> json) {
    final countries = <LocaleCountryModel>[];
    if (json['countries'] is List) {
      for (final item in json['countries'] as List) {
        if (item is Map) {
          countries.add(LocaleCountryModel.fromJson(
              Map<String, dynamic>.from(item)));
        }
      }
    }
    return LocaleConfigData(
      locale: json['locale']?.toString() ?? 'en',
      defaultLanguage: json['default_language']?.toString() ?? 'en',
      defaultCountry: json['default_country']?.toString() ?? 'India',
      selectedLanguage: json['selected_language']?.toString() ?? 'en',
      selectedCountry: json['selected_country']?.toString() ?? 'India',
      countries: countries,
    );
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  final text = value?.toString().toLowerCase() ?? '';
  return text == 'true' || text == '1';
}

int _toInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

List<String> _toStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList();
}
