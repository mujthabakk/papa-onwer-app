/*Papabear*/
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

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
    return sharedPreferencesManager.getString('currencySymbol') ??
        AppConstants.defaultCurrencySymbol;
  }

  Future<Response> getBannerData() async {
    var response = await apiService.getPublic(AppConstants.getBannerData);
    return response;
  }
}
