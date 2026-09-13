import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class UpgradeParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  UpgradeParser({
    required this.sharedPreferencesManager,
    required this.apiService,
  });

  String get token => sharedPreferencesManager.getString('token') ?? '';

  int get uid => int.tryParse(getUID()) ?? 0;

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '0';
  }

  Future<Response> getUpgradePlans() async {
    return apiService.getPublic('${AppConstants.upgradeGetPlans}?uid=$uid');
  }

  Future<Response> createPaymentLink({
    required int planId,
    required num amount,
  }) async {
    return apiService.postPrivate(
      AppConstants.upgradeCreatePaymentLink,
      {
        'uid': uid,
        'plan_id': planId,
        'plan_amount': amount,
      },
      token,
    );
  }

  Future<Response> verifyPayment({
    int? orderId,
    String? paymentLinkId,
  }) async {
    final body = <String, dynamic>{'uid': uid};
    if (orderId != null) body['order_id'] = orderId;
    if (paymentLinkId != null && paymentLinkId.isNotEmpty) {
      body['payment_link_id'] = paymentLinkId;
    }
    return apiService.postPrivate(
      'api/v1/upgrade/verifyPayment',
      body,
      token,
    );
  }
}
