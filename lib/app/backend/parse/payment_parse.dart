import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class PaymentParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  PaymentParser({
    required this.sharedPreferencesManager,
    required this.apiService,
  });

  String get token => sharedPreferencesManager.getString('token') ?? '';
  String? getUid() => sharedPreferencesManager.getString('uid');

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
      token,
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
      token,
    );
  }

  Future<Response> payNow({
    required int customerUid,
    required int bookId,
    double? amount,
  }) async {
    return apiService.postPrivate(
      AppConstants.payNow,
      {
        'uid': customerUid,
        'appointment_id': bookId,
        'book_id': bookId,
        if (amount != null) 'amount': amount,
      },
      token,
    );
  }

  Future<Response> verifyCheckoutPayment({
    required int customerUid,
    required int bookId,
  }) async {
    return apiService.postPrivate(
      AppConstants.verifyCheckoutPayment,
      {
        'uid': customerUid,
        'book_id': bookId,
      },
      token,
    );
  }

  Future<Response> markCashPaid({
    required int bookId,
    String remarks = 'Cash received',
  }) async {
    final partnerUid = int.tryParse(getUid() ?? '') ?? 0;
    return apiService.postPrivate(
      AppConstants.markCashPaid,
      {
        'uid': partnerUid,
        'book_id': bookId,
        'appointment_id': bookId,
        'remarks': remarks,
      },
      token,
    );
  }

  Future<Response> getByCountry({int? uid, String? country}) async {
    return apiService.postPrivate(
      AppConstants.getPaymentsByCountry,
      {
        if (uid != null) 'uid': uid,
        if (country != null && country.isNotEmpty) 'country': country,
      },
      token,
    );
  }

  Future<Response> cancelCheckoutPayment({
    required int customerUid,
    required int bookId,
  }) async {
    return apiService.postPrivate(
      AppConstants.cancelCheckoutPayment,
      {
        'uid': customerUid,
        'book_id': bookId,
      },
      token,
    );
  }

  Future<Response> generateCheckoutPaymentUrl({
    required int customerUid,
    required int bookId,
  }) async {
    return apiService.postPrivate(
      AppConstants.generateCheckoutPaymentUrl,
      {
        'uid': customerUid,
        'book_id': bookId,
      },
      token,
    );
  }

  Future<Response> getSocketConfig() async {
    return apiService.getPublic(AppConstants.paymentSocketConfig);
  }
}
