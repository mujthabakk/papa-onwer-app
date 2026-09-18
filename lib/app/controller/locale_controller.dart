import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/locale_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/locale_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_packages_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_services_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/analytics_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/appointment_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/calendar_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/order_details_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/premium_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/product_history_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/product_order_details_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/products_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/locale_helper.dart';

class LocaleController extends GetxController implements GetxService {
  final LocaleParser parser;
  final SharedPreferencesManager prefs;

  LocaleController({required this.parser, required this.prefs});

  String languageCode = AppConstants.defaultLanguageApp;
  String countryCode = 'IN';
  bool get isLoggedIn => parser.isLoggedIn();
  String direction = 'ltr';
  bool isRtl = false;
  int revision = 0;

  List<ApiLanguageModel> languages = [];
  List<LocaleCountryModel> countries = [];
  Map<String, String> uiStrings = {};
  bool isLoading = false;
  bool _bootstrapped = false;
  bool _uiScheduled = false;
  bool _pendingLocalePush = false;

  String get selectedCountryLabel {
    if (countries.isEmpty) return countryCode;
    final match = countries.where((c) => c.code == countryCode);
    if (match.isNotEmpty) {
      final country = match.first;
      return country.code.isNotEmpty ? country.code : country.name;
    }
    return countryCode;
  }

  LocaleCountryModel? get selectedCountry {
    final match = countries.where((c) => c.code == countryCode);
    return match.isEmpty ? null : match.first;
  }

  @override
  void onInit() {
    super.onInit();
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    languageCode = LocaleHelper.normalizeLanguageCode(
      prefs.getString('language') ?? AppConstants.defaultLanguageApp,
    );
    countryCode = prefs.getString('country') ?? 'IN';
    direction = prefs.getString('direction') ?? 'ltr';
    isRtl = prefs.getBool('is_rtl');
    _applyLanguageFlags(languageCode);
    _syncTranslations();
  }

  void _persistSelection() {
    prefs.putString('language', languageCode);
    prefs.putString('country', countryCode);
    prefs.putString('direction', direction);
    prefs.putBool('is_rtl', isRtl);
  }

  void _applyLanguageFlags(String code) {
    final match = languages.where((item) => item.code == code);
    if (match.isNotEmpty) {
      isRtl = match.first.isRtl;
      direction = match.first.direction;
      return;
    }
    if (code == 'ar') {
      isRtl = true;
      direction = 'rtl';
    } else {
      isRtl = false;
      direction = 'ltr';
    }
  }

  void _syncTranslations() {
    final maps = LocaleHelper.translationMaps(languageCode, uiStrings);
    Get.addTranslations(maps);
  }

  /// Always schedule after the current frame — never call update during build.
  void _scheduleUi({bool pushLocale = false}) {
    if (pushLocale) _pendingLocalePush = true;
    if (_uiScheduled) return;
    _uiScheduled = true;

    void run() {
      _uiScheduled = false;
      if (isClosed) return;
      _syncTranslations();
      revision++;
      if (_pendingLocalePush) {
        _pendingLocalePush = false;
        final locale = LocaleHelper.toFlutterLocale(languageCode);
        Get.updateLocale(locale);
      }
      update();
    }

    SchedulerBinding.instance.addPostFrameCallback((_) => run());
  }

  /// Apply locale meta from API. Do not override the user's selected language.
  void _applyResponseMeta(Map<String, dynamic> body) {
    if (body['direction'] != null) {
      direction = body['direction'].toString();
    }
    if (body.containsKey('is_rtl')) {
      isRtl = body['is_rtl'] == true ||
          body['is_rtl'].toString() == '1' ||
          body['is_rtl'].toString().toLowerCase() == 'true';
    }
    _persistSelection();
    _syncTranslations();
  }

  void applyCurrencyFromApi(Map<String, dynamic> body) {
    _saveCurrencyFromResponse(body);
    _refreshMoneyControllers();
    _scheduleUi();
  }

  void _saveCurrencyFromResponse(Map<String, dynamic> body) {
    final data = body['data'] is Map ? Map<String, dynamic>.from(body['data']) : null;
    final currency = body['currencyCode']?.toString() ??
        body['currency']?.toString() ??
        data?['currencyCode']?.toString() ??
        data?['currency']?.toString();
    final symbol = body['currencySymbol']?.toString() ??
        body['currency_symbol']?.toString() ??
        data?['currencySymbol']?.toString() ??
        data?['currency_symbol']?.toString();
    if (currency != null && currency.isNotEmpty) {
      CurrencyHelper.save(
        prefs,
        CurrencyHelper.fromCurrencyCode(currency, symbol: symbol),
      );
      return;
    }
    final country = body['preferred_country']?.toString() ??
        body['selected_country']?.toString() ??
        data?['preferred_country']?.toString() ??
        data?['selected_country']?.toString();
    if (country != null && country.isNotEmpty) {
      CurrencyHelper.save(prefs, CurrencyHelper.fromCountry(name: country));
    }
  }

  void _applyCountryCurrency() {
    final country = selectedCountry;
    CurrencyInfo info;
    if (country != null && country.currency.isNotEmpty) {
      info = CurrencyHelper.fromCurrencyCode(
        country.currency,
        symbol: country.currencySymbol,
      );
    } else {
      info = CurrencyHelper.fromCountry(
        code: country?.code ?? countryCode,
        name: country?.nameEn.isNotEmpty == true
            ? country!.nameEn
            : (country?.name ?? countryCode),
      );
    }
    CurrencyHelper.save(prefs, info);
  }

  /// GetX `lazyPut` registers a factory; `isRegistered` is true before the
  /// instance exists. `find()` would create home controllers and fire APIs
  /// while the user is still on splash/login.
  T? _createdInstance<T>() {
    if (!Get.isRegistered<T>()) return null;
    if (Get.isPrepared<T>()) return null;
    return Get.find<T>();
  }

  void _refreshMoneyControllers() {
    final info = CurrencyHelper.current(prefs);
    void apply(dynamic controller) {
      if (controller == null) return;
      try {
        controller.currencySymbol = CurrencyHelper.displaySymbol(prefs);
        controller.currencySide = info.side;
        controller.update();
      } catch (_) {}
    }

    apply(_createdInstance<AppointmentController>());
    apply(_createdInstance<ServicesController>());
    apply(_createdInstance<AnalyticsController>());
    apply(_createdInstance<CalendarsController>());
    apply(_createdInstance<ProductsController>());
    apply(_createdInstance<OrderDetailsController>());
    apply(_createdInstance<HistoryController>());
    apply(_createdInstance<ProductOrderDetailsController>());
    apply(_createdInstance<AddServicesController>());
    apply(_createdInstance<AddPackagesController>());
  }

  Map<String, dynamic>? _lastPickerBody;

  void reapplyPickerCurrency() {
    if (_lastPickerBody != null) {
      _saveCurrencyFromResponse(_lastPickerBody!);
      _refreshMoneyControllers();
    }
  }

  Future<void> bootstrap({bool force = false, bool applyLocale = false}) async {
    if (_bootstrapped && !force && languages.isNotEmpty && countries.isNotEmpty) {
      return;
    }
    if (isLoading && !force) return;

    isLoading = true;
    try {
      await fetchPicker(notify: false);
      if (languages.isEmpty) {
        await fetchLanguages(notify: false);
      }
      if (uiStrings.isEmpty) {
        unawaited(fetchUiStrings(notify: false));
      }
      final savedCurrency = prefs.getString('currencyCode');
      if (savedCurrency == null || savedCurrency.isEmpty) {
        _applyCountryCurrency();
      }
      _bootstrapped = true;
    } finally {
      isLoading = false;
      _scheduleUi(pushLocale: applyLocale);
    }
  }

  Future<void> fetchPicker({String? country, bool notify = true}) async {
    final response = await parser.getActiveCountries(
      lang: languageCode,
      country: country ?? countryCode,
    );
    if (response.statusCode == 200) {
      final body = Map<String, dynamic>.from(response.body);
      _applyResponseMeta(body);
      _parseCountries(body);
      _parseLanguages(body);
      _applySelectedCountry(body);
      _lastPickerBody = body;
      _saveCurrencyFromResponse(body);
      _persistSelection();
      _refreshMoneyControllers();
      if (notify) _scheduleUi();
    }
  }

  void _parseCountries(Map<String, dynamic> body) {
    List? list;
    if (body['countries'] is List) {
      list = body['countries'] as List;
    } else if (body['data'] is List) {
      list = body['data'] as List;
    } else if (body['data'] is Map &&
        (body['data'] as Map)['countries'] is List) {
      list = (body['data'] as Map)['countries'] as List;
    }
    if (list == null) return;

    countries = [];
    for (final item in list) {
      if (item is Map) {
        countries.add(
            LocaleCountryModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }
  }

  void _parseLanguages(Map<String, dynamic> body) {
    List? list;
    if (body['languages'] is List) {
      list = body['languages'] as List;
    } else if (body['data'] is Map &&
        (body['data'] as Map)['languages'] is List) {
      list = (body['data'] as Map)['languages'] as List;
    } else if (body['data'] is List &&
        body['data'].isNotEmpty &&
        body['data'].first is Map &&
        (body['data'].first as Map).containsKey('native_name')) {
      list = body['data'] as List;
    }
    if (list == null) return;

    languages = [];
    for (final item in list) {
      if (item is Map) {
        languages
            .add(ApiLanguageModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }
  }

  void _applySelectedCountry(Map<String, dynamic> body) {
    final selected = body['selected_country']?.toString() ?? '';
    if (selected.isEmpty) return;
    final lower = selected.toLowerCase();
    final match = countries.where((c) =>
        c.code.toLowerCase() == lower ||
        c.name.toLowerCase() == lower ||
        c.nameEn.toLowerCase() == lower);
    if (match.isNotEmpty) {
      countryCode = match.first.code;
    }
  }

  Future<void> fetchLanguages({bool notify = true}) async {
    final response = await parser.getLanguages();
    if (response.statusCode == 200) {
      final body = Map<String, dynamic>.from(response.body);
      _applyResponseMeta(body);
      languages = [];
      if (body['data'] is List) {
        for (final item in body['data'] as List) {
          if (item is Map) {
            languages.add(ApiLanguageModel.fromJson(
                Map<String, dynamic>.from(item)));
          }
        }
      }
      if (notify) _scheduleUi();
    }
  }

  Future<void> fetchConfig({
    String? lang,
    String? country,
    bool notify = true,
  }) async {
    final response = await parser.getConfig(
      lang: lang ?? languageCode,
      country: country ?? countryCode,
    );
    if (response.statusCode == 200) {
      final body = Map<String, dynamic>.from(response.body);
      _applyResponseMeta(body);
      _saveCurrencyFromResponse(body);
      if (body['data'] is Map) {
        final config = LocaleConfigData.fromJson(
            Map<String, dynamic>.from(body['data'] as Map));
        if (config.countries.isNotEmpty) {
          countries = config.countries;
        }
        prefs.putString('country', countryCode);
        _syncTranslations();
      }
      if (notify) _scheduleUi(pushLocale: true);
    }
  }

  Future<void> fetchCountries({bool notify = true}) async {
    await fetchPicker(notify: notify);
  }

  Future<void> fetchUiStrings({String? lang, bool notify = true}) async {
    final response = await parser.getUiStrings(lang: lang ?? languageCode);
    if (response.statusCode == 200) {
      final body = Map<String, dynamic>.from(response.body);
      _applyResponseMeta(body);
      uiStrings = {};
      final data = body['data'];
      if (data is Map && data['strings'] is Map) {
        (data['strings'] as Map).forEach((key, value) {
          uiStrings[key.toString()] = value.toString();
        });
      }
      _syncTranslations();
      if (notify) _scheduleUi(pushLocale: true);
    }
  }

  Future<void> changeLanguage(
    String code, {
    String? country,
    bool saveRemote = true,
  }) async {
    final previousLang = languageCode;
    languageCode = LocaleHelper.normalizeLanguageCode(code);
    if (country != null && country.isNotEmpty) {
      await _resolveCountry(country);
    }
    _applyLanguageFlags(languageCode);
    _persistSelection();
    _syncTranslations();
    _scheduleUi(pushLocale: true);

    if (uiStrings.isEmpty || previousLang != languageCode) {
      await fetchUiStrings(lang: languageCode, notify: false);
    }
    if (countries.isEmpty) {
      await fetchPicker(country: countryCode, notify: false);
    }

    if (saveRemote && parser.isLoggedIn()) {
      await _saveRemotePreference();
    }
    _scheduleUi(pushLocale: true);
  }

  /// Apply language/country/currency returned by backend (login / profile).
  Future<void> applyPreferredFromServer({
    String? language,
    String? country,
    Map<String, dynamic>? responseBody,
    bool fetchRemoteStrings = true,
  }) async {
    final previousLang = languageCode;
    final previousCountry = countryCode;

    if ((language ?? '').trim().isNotEmpty) {
      languageCode = LocaleHelper.normalizeLanguageCode(language!);
    }
    if (country != null && country.trim().isNotEmpty) {
      await _resolveCountry(country.trim());
    }
    _applyLanguageFlags(languageCode);
    _persistSelection();
    if (responseBody != null) {
      _applyResponseMeta(responseBody);
      _saveCurrencyFromResponse(responseBody);
    }
    _syncTranslations();

    final langChanged = previousLang != languageCode;
    final countryChanged = previousCountry != countryCode;

    if (fetchRemoteStrings) {
      if (countryChanged || countries.isEmpty) {
        await fetchPicker(country: countryCode, notify: false);
        if (responseBody != null) {
          _saveCurrencyFromResponse(responseBody);
        }
      }
      if (langChanged || uiStrings.isEmpty) {
        await fetchUiStrings(lang: languageCode, notify: false);
      }
    }
    _refreshMoneyControllers();
    if (countryChanged) {
      await _refreshPlans();
    }
    Get.updateLocale(LocaleHelper.toFlutterLocale(languageCode));
    _scheduleUi(pushLocale: true);
  }

  Future<void> _resolveCountry(String country) async {
    if (countries.isEmpty) {
      await fetchPicker(notify: false);
    }
    final lower = country.toLowerCase();
    final match = countries.where((c) =>
        c.code.toLowerCase() == lower ||
        c.name.toLowerCase() == lower ||
        c.nameEn.toLowerCase() == lower);
    if (match.isNotEmpty) {
      countryCode = match.first.code;
    } else if (country.length <= 3) {
      countryCode = country.toUpperCase();
    }
  }

  Future<void> changeCountry(String code) async {
    if (code.isEmpty || code.toUpperCase() == countryCode.toUpperCase()) {
      return;
    }
    countryCode = code;
    _applyCountryCurrency();
    _refreshMoneyControllers();
    _persistSelection();
    _scheduleUi();

    await fetchPicker(country: countryCode, notify: false);
    _refreshMoneyControllers();
    if (parser.isLoggedIn()) {
      await _saveRemotePreference();
    }
    await _refreshPlans();
    _scheduleUi();
  }

  Future<void> _refreshPlans() async {
    if (!Get.isRegistered<PremiumController>()) return;
    final premium = Get.find<PremiumController>();
    premium.plans.clear();
    await premium.fetchPlans();
  }

  Future<void> _saveRemotePreference() async {
    final uid = int.tryParse(parser.getUid() ?? '');
    if (uid == null) return;
    final countryName = selectedCountry?.nameEn.isNotEmpty == true
        ? selectedCountry!.nameEn
        : (selectedCountry?.name.isNotEmpty == true
            ? selectedCountry!.name
            : countryCode);
    final response = await parser.saveUserPreference(
      userId: uid,
      language: languageCode,
      country: countryName,
    );
    if (response.statusCode != 200) {
      ApiChecker.checkApi(response);
    } else if (response.body is Map) {
      _saveCurrencyFromResponse(Map<String, dynamic>.from(response.body));
    }
    final profileRes = await parser.saveProfilePreference(
      userId: uid,
      language: languageCode,
      country: countryName,
    );
    if (profileRes.statusCode == 200 && profileRes.body is Map) {
      _saveCurrencyFromResponse(Map<String, dynamic>.from(profileRes.body));
    }
    _refreshMoneyControllers();
  }

  String? translate(String source) {
    final api = LocaleHelper.lookupApiString(source, uiStrings);
    if (api != null && api.isNotEmpty) {
      return api;
    }
    return null;
  }

  String uiString(String key, {String fallback = ''}) {
    return uiStrings[key] ?? fallback;
  }

  String messageFromResponse(Map<String, dynamic> body,
      {String fallback = ''}) {
    final message = body['message']?.toString();
    if (message != null && message.isNotEmpty) {
      return message;
    }
    return fallback;
  }
}
