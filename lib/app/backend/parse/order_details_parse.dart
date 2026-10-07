import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';


class OrderDetailsParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  OrderDetailsParser(
      {required this.sharedPreferencesManager, required this.apiService});

  Future<Response> getAppointmentDetails(var body) async {
    var response = await apiService.postPrivate(
        AppConstants.getAppointmnetsDetails,
        body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> updateAppointments(var body) async {
    var response = await apiService.postPrivate(AppConstants.updateAppointments,
        body, sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> getAppointmentStatus(var body) async {
    return apiService.postPrivate(
      AppConstants.getAppointmentStatus,
      body,
      sharedPreferencesManager.getString('token') ?? '',
    );
  }

  Future<Response> getByID(var body) async {
    var response = await apiService.postPrivate(AppConstants.getById, body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> getBySalonId(var body) async {
    var response = await apiService.postPrivate(AppConstants.getBySalonId, body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> completionAppointments(var body) async {
    var response = await apiService.postPrivate(
        AppConstants.completeAppointments,
        body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> markCashPaid({
    required int bookId,
    String remarks = 'Cash received',
  }) async {
    final uid = int.tryParse(sharedPreferencesManager.getString('uid') ?? '') ??
        0;
    return apiService.postPrivate(
      AppConstants.markCashPaid,
      {
        'uid': uid,
        'book_id': bookId,
        'appointment_id': bookId,
        'remarks': remarks,
      },
      sharedPreferencesManager.getString('token') ?? '',
    );
  }

  Future<Response> getPaymentOptions({
    required int customerUid,
    required int bookId,
  }) async {
    return apiService.postPrivate(
      AppConstants.getPaymentOptions,
      {
        'uid': customerUid,
        'book_id': bookId,
      },
      sharedPreferencesManager.getString('token') ?? '',
    );
  }

  Future<Response> getPaymentStatus({
    required int customerUid,
    required int bookId,
  }) async {
    return apiService.postPrivate(
      AppConstants.getPaymentStatus,
      {
        'uid': customerUid,
        'book_id': bookId,
      },
      sharedPreferencesManager.getString('token') ?? '',
    );
  }

  Future<Response> getPaymentsByCountry() async {
    return apiService.postPrivate(
      AppConstants.getPaymentsByCountry,
      {},
      sharedPreferencesManager.getString('token') ?? '',
    );
  }

  String? getUid() => sharedPreferencesManager.getString('uid');

  // Future<Response> sendNotification(var body) async {
  //   var response = await apiService.postPrivate(AppConstants.sendNotification,
  //       body, sharedPreferencesManager.getString('token') ?? '');
  //   return response;
  // }

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

  bool getUserType() {
    return sharedPreferencesManager.getString('type') == 'salon' ? true : false;
  }
}
