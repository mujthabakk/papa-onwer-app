/*Papabear*/
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_country.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';


class AppointmentParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  AppointmentParser(
      {required this.sharedPreferencesManager, required this.apiService});

  String getType() {
    return sharedPreferencesManager.getString('type') ?? '';
  }

  String getName() {
    final saved = (sharedPreferencesManager.getString('name') ?? '').trim();
    if (saved.isNotEmpty) return saved;
    final first = (sharedPreferencesManager.getString('first_name') ?? '').trim();
    final last = (sharedPreferencesManager.getString('last_name') ?? '').trim();
    return '$first $last'.trim();
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

  Future<Response> getSalonList() async {
    var response = await apiService.postPrivate(
        AppConstants.getSalonAppointmentsList,
        {"id": sharedPreferencesManager.getString('uid')},
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> getIndividualAppointmentsList() async {
    var response = await apiService.postPrivate(
        AppConstants.getIndividualAppointmentsList,
        {"id": sharedPreferencesManager.getString('uid')},
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  String getCurrencyCode() {
    return sharedPreferencesManager.getString('currencyCode') ??
        AppConstants.defaultCurrencyCode;
  }

  String getCurrencySide() {
    return sharedPreferencesManager.getString('currencySide') ??
        AppConstants.defaultCurrencySide;
  }

  String getCurrencySymbol() {
    return CurrencyHelper.displaySymbol(sharedPreferencesManager);
  }

  String get token => sharedPreferencesManager.getString('token') ?? '';

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '0';
  }

  Map<String, dynamic> locationBody() {
    final uid = int.tryParse(getUID()) ?? 0;
    final country = AppCountry.headerValue(sharedPreferencesManager);
    final cid = sharedPreferencesManager.getString('cid') ??
        sharedPreferencesManager.getString('city_id');
    final lat = sharedPreferencesManager.getString('lat');
    final lng = sharedPreferencesManager.getString('lng');
    return {
      if (uid > 0) 'uid': uid,
      if (country.isNotEmpty) 'country': country,
      if (cid != null && cid.isNotEmpty)
        'city_id': int.tryParse(cid) ?? cid,
      if (lat != null && lat.isNotEmpty)
        'lat': double.tryParse(lat) ?? lat,
      if (lng != null && lng.isNotEmpty)
        'lng': double.tryParse(lng) ?? lng,
    };
  }

  Future<Response> getBannerData() async {
    final body = locationBody();
    var response = await apiService.postPrivate(
      AppConstants.partnerGetHomeAds,
      body,
      token,
    );
    if (response.statusCode == 200) return response;
    response = await apiService.getPrivate(
      '${AppConstants.partnerGetHomeAds}?uid=${getUID()}',
      token,
    );
    if (response.statusCode == 200) return response;
    return apiService.getPrivate(
      '${AppConstants.partnerAdsGetHome}?uid=${getUID()}',
      token,
    );
  }

  Future<Response> salonDetails(int id) async {
    return apiService.postPrivate(
      AppConstants.salonDetails,
      {'id': id},
      token,
    );
  }

  Future<Response> individualDetails(int id) async {
    return apiService.postPrivate(
      AppConstants.individualDetails,
      {'id': id},
      token,
    );
  }
}
