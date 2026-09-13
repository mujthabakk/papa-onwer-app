import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class LocaleParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  LocaleParser({
    required this.sharedPreferencesManager,
    required this.apiService,
  });

  String? getUid() => sharedPreferencesManager.getString('uid');

  String _withUid(String uri) {
    final uid = getUid();
    if (uid == null || uid.isEmpty) return uri;
    return uri.contains('?') ? '$uri&uid=$uid' : '$uri?uid=$uid';
  }

  Future<Response> getLanguages() async {
    return apiService.postPublic(AppConstants.localeGetLanguages, {});
  }

  Future<Response> getConfig({required String lang, String? country}) async {
    var uri = AppConstants.localeGetConfig;
    if (country != null && country.isNotEmpty) {
      uri = '$uri?country=$country';
    }
    return apiService.getPublic(_withUid(uri));
  }

  Future<Response> getUiStrings({required String lang}) async {
    return apiService.postPublic(AppConstants.localeGetUiStrings, {
      'lang': lang,
    });
  }

  Future<Response> getActiveCountries({
    required String lang,
    String? country,
  }) async {
    var uri = AppConstants.getActiveCountries;
    final qs = <String>[];
    if (country != null && country.isNotEmpty) {
      qs.add('country=$country');
    }
    if (lang.isNotEmpty) {
      qs.add('lang=$lang');
    }
    if (qs.isNotEmpty) {
      uri = '$uri?${qs.join('&')}';
    }
    return apiService.getPublic(uri);
  }

  Future<Response> getActiveStates({
    required String lang,
    required String country,
  }) async {
    return apiService.getPublic(
      '${AppConstants.getActiveStates}?country=$country',
    );
  }

  Future<Response> getAppSettingsByLanguageId({required String lang}) async {
    final uid = getUid();
    return apiService.postPublic(AppConstants.getAppSettingsByLanguageId, {
      'lang': lang,
      if (uid != null && uid.isNotEmpty) 'uid': uid,
    });
  }

  Future<Response> saveUserPreference({
    required int userId,
    required String language,
    required String country,
  }) async {
    final body = {
      'uid': userId,
      'user_id': userId,
      'language': language,
      'country': country,
    };
    final token = sharedPreferencesManager.getString('token') ?? '';
    if (token.isEmpty) {
      return apiService.postPublic(AppConstants.localeSaveUserPreference, body);
    }
    return apiService.postPrivate(
      AppConstants.localeSaveUserPreference,
      body,
      token,
    );
  }

  Future<Response> saveProfilePreference({
    required int userId,
    required String language,
    required String country,
  }) async {
    final token = sharedPreferencesManager.getString('token') ?? '';
    if (token.isEmpty) {
      return const Response(statusCode: 0);
    }
    return apiService.postPrivate(
      AppConstants.updateFCM,
      {
        'id': userId,
        'language': language,
        'country': country,
      },
      token,
    );
  }

  bool isLoggedIn() =>
      (sharedPreferencesManager.getString('token') ?? '').isNotEmpty;
}
