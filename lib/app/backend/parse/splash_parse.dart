import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class SplashParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  SplashParser(
      {required this.apiService, required this.sharedPreferencesManager});

  bool isNewUser() {
    return sharedPreferencesManager.getBool('welcome');
  }

  Future<bool> initAppSettings() {
    return Future.value(true);
  }

  void saveWelcome(bool value) {
    sharedPreferencesManager.putBool('welcome', value);
  }

  Future<Response> getAppSettings({String? lang}) async {
    final uid = sharedPreferencesManager.getString('uid');
    if (lang != null && lang.isNotEmpty) {
      return apiService.postPublic(
        AppConstants.getAppSettingsByLanguageId,
        {
          'lang': lang,
          if (uid != null && uid.isNotEmpty) 'uid': uid,
        },
      );
    }
    final uri = (uid != null && uid.isNotEmpty)
        ? '${AppConstants.getAppSettings}?uid=$uid'
        : AppConstants.getAppSettings;
    return apiService.getPublic(uri);
  }

  String getLanguagesCode() {
    return sharedPreferencesManager.getString('language') ?? 'en';
  }

  void saveBasicInfo(
      var currencyCode,
      var currencySide,
      var currencySymbol,
      var smsName,
      var verifyWith,
      var userLogin,
      var supportEmail,
      var appName,
      var shipping,
      var shippingPrice,
      var tax,
      var appLogo,
      var supportName,
      var supportId,
      var supportPhone,
      var allowDistance,
      var commissionPercentage) {
    sharedPreferencesManager.putString('currencyCode', currencyCode);
    sharedPreferencesManager.putString('currencySide', currencySide);
    sharedPreferencesManager.putString('currencySymbol', currencySymbol);
    sharedPreferencesManager.putString('smsName', smsName);
    sharedPreferencesManager.putInt('user_verify_with', verifyWith);
    sharedPreferencesManager.putInt('userLogin', userLogin);
    sharedPreferencesManager.putString('supportEmail', supportEmail);
    sharedPreferencesManager.putString('appName', appName);
    sharedPreferencesManager.putString(
        'commission_percentage', commissionPercentage);

    sharedPreferencesManager.putInt('shipping', shipping);
    sharedPreferencesManager.putDouble('shippingPrice', shippingPrice);
    sharedPreferencesManager.putDouble('tax', tax);
    sharedPreferencesManager.putString('appLogo', appLogo);
    sharedPreferencesManager.putInt('supportUID', supportId);
    sharedPreferencesManager.putString('supportName', supportName);
    sharedPreferencesManager.putString('supportPhone', supportPhone);
    sharedPreferencesManager.putDouble('allowDistance', allowDistance);
  }

  void saveDeviceToken(String token) {
    sharedPreferencesManager.putString('fcm_token', token);
  }

  bool haveLoggedIn() {
    final token = sharedPreferencesManager.getString('token') ?? '';
    final uid = sharedPreferencesManager.getString('uid') ?? '';
    return token.isNotEmpty && uid.isNotEmpty;
  }
}
