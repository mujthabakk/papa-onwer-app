import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';


class HolidayParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  HolidayParser(
      {required this.sharedPreferencesManager, required this.apiService});

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '';
  }

  String getType() {
    return sharedPreferencesManager.getString('type') ?? '';
  }

  Future<Response> markHoliday(String date, int status) async {
    var response;

    print('status $status');

    response = await apiService.postPrivate(
        AppConstants.markHoliday,
        {"uid": getUID(), "date": date, "status": status},
        sharedPreferencesManager.getString('token') ?? '');

    return response;
  }

  Future<Response> getHolidays() async {
    return await apiService.postPrivate(
        AppConstants.getHolidays,
        {
          'uid': getUID(),
        },
        sharedPreferencesManager.getString('token') ?? '');
  }

  Future<Response> getByDate(var body) async {
    return await apiService.postPrivate(AppConstants.getByDate, body,
        sharedPreferencesManager.getString('token') ?? '');
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
}
