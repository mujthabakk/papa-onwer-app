import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/product/util/product_user.dart';


class HistoryParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  HistoryParser(
      {required this.sharedPreferencesManager, required this.apiService});

  String getType() {
    return sharedPreferencesManager.getString('type') ?? '';
  }

  bool isProductUser() => ProductUser.isProduct(sharedPreferencesManager);

  String get token => sharedPreferencesManager.getString('token') ?? '';
  String get uid => sharedPreferencesManager.getString('uid') ?? '';

  Future<Response> getSalonList() async {
    final uidVal = int.tryParse(uid) ?? uid;
    if (isProductUser()) {
      final now = DateTime.now();
      String two(int value) => value.toString().padLeft(2, '0');
      String ymd(DateTime date) =>
          '${date.year}-${two(date.month)}-${two(date.day)}';
      final historyBody = {
        'id': uidVal,
        'uid': uidVal,
        'start_date': ymd(DateTime(now.year - 1, now.month, now.day)),
        'end_date': ymd(DateTime(now.year + 1, now.month, now.day)),
      };
      return apiService.postPrivate(
        AppConstants.productHistoryGetMyList,
        historyBody,
        token,
      );
    }
    final body = {"id": uidVal};
    var response = await apiService.postPrivate(
        AppConstants.getSalonOrdersList, body, token);
    if (response.statusCode == 200) return response;
    return apiService.postPrivate(
        AppConstants.getFreelancerProductOrders, body, token);
  }

  bool getPremium() {
    return sharedPreferencesManager.getBool('premium');
  }

  Future<Response> getIndividualOrdersList() async {
    var response = await apiService.postPrivate(
        AppConstants.getIndividualOrdersList,
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
}
