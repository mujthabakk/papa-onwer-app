import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';

class ProductOrderDetailsParse {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  ProductOrderDetailsParse(
      {required this.sharedPreferencesManager, required this.apiService});

  String get token => sharedPreferencesManager.getString('token') ?? '';

  /// PDF: POST product_order/getById — full order + status_label + tracking.
  Future<Response> getOrderDetails(var body) async {
    return apiService.postPrivate(
        AppConstants.productOrderGetById, body, token);
  }

  Future<Response> updateProductOrder(var body) async {
    return apiService.postPrivate(
        AppConstants.updateProductOrder, body, token);
  }

  Future<Response> getStatus(var body) async {
    return apiService.postPrivate(
        AppConstants.productOrderGetStatus, body, token);
  }

  Future<Response> getTracking(var body) async {
    final res = await apiService.postPrivate(
        AppConstants.productOrderGetTracking, body, token);
    if (res.statusCode == 200) return res;
    return apiService.postPrivate(
        AppConstants.productOrderGetTrackingDetails, body, token);
  }

  Future<Response> updateStatus(var body) async {
    return apiService.postPrivate(
        AppConstants.productOrderUpdateStatus, body, token);
  }

  Future<Response> updateTracking(var body) async {
    return apiService.postPrivate(
        AppConstants.productOrderUpdateTracking, body, token);
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

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? '';
  }

  int getAdminId() {
    return sharedPreferencesManager.getInt('supportUID') ?? 0;
  }

  String getAdminName() {
    return sharedPreferencesManager.getString('supportName') ?? '';
  }
}
