/*Papabear*/
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class PremiumParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  PremiumParser(
      {required this.sharedPreferencesManager, required this.apiService});

  String get token => sharedPreferencesManager.getString('token') ?? '';

  int get uid => int.tryParse(getUID()) ?? 0;

  String getType() {
    return sharedPreferencesManager.getString('type') ?? '';
  }

  bool getUserType() {
    return sharedPreferencesManager.getString('type') == 'salon' ? true : false;
  }

  void premiumStat(bool premium) {
    sharedPreferencesManager.putBool('premium', premium);
  }

  bool getPremium() {
    return sharedPreferencesManager.getBool('premium');
  }

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '0';
  }

  String _planCountry() {
    return sharedPreferencesManager.getString('country') ?? 'IN';
  }

  Future<Response> getUpgradePlans() async {
    final country = _planCountry();
    String countryName = country;
    if (country.toUpperCase() == 'QA' || country.toUpperCase() == 'QAT') {
      countryName = 'Qatar';
    } else if (country.toUpperCase() == 'IN' ||
        country.toUpperCase() == 'IND') {
      countryName = 'India';
    }
    final body = {'uid': uid, 'country': countryName};
    if (token.isNotEmpty) {
      return apiService.postPrivate(AppConstants.upgradePlans, body, token);
    }
    return apiService.postPublic(AppConstants.upgradePlans, body);
  }

  Future<Response> createPaymentLink({
    required int planId,
    required num amount,
  }) async {
    return apiService.postPrivate(
      AppConstants.upgradeCreatePaymentLink,
      {
        "uid": uid,
        "plan_id": planId,
        "plan_amount": amount,
      },
      token,
    );
  }

  Future<Response> verifyPayment({
    int? orderId,
    String? paymentLinkId,
  }) async {
    final body = <String, dynamic>{"uid": uid};
    if (orderId != null) body["order_id"] = orderId;
    if (paymentLinkId != null && paymentLinkId.isNotEmpty) {
      body["payment_link_id"] = paymentLinkId;
    }
    return apiService.postPrivate(
      AppConstants.upgradeVerifyPayment,
      body,
      token,
    );
  }

  Future<Response> postSalonUpgrade(String premium) async {
    print('salon id -${sharedPreferencesManager.getString('uid')}');

    var response = await apiService.postPrivate(
        AppConstants.upgradeSalon,
        {"id": sharedPreferencesManager.getString('uid'), "premium": premium},
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> postIndividualUpgrade(String premium) async {
    var response = await apiService.postPrivate(
        AppConstants.upgradeFreelancer,
        {"id": sharedPreferencesManager.getString('uid'), "premium": premium},
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }
}
