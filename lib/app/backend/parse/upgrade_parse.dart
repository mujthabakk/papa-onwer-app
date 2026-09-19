import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
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

  String _planCountry() {
    if (Get.isRegistered<LocaleController>()) {
      final loc = Get.find<LocaleController>();
      final selected = loc.selectedCountry;
      if (selected != null) {
        if (selected.nameEn.trim().isNotEmpty) return selected.nameEn.trim();
        if (selected.name.trim().isNotEmpty) return selected.name.trim();
      }
      final code = loc.countryCode.toUpperCase();
      if (code == 'QA' || code == 'QAT') return 'Qatar';
    }
    return 'India';
  }

  Future<Response> getUpgradePlans() async {
    final body = {'uid': uid, 'country': _planCountry()};
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
      AppConstants.upgradeVerifyPayment,
      body,
      token,
    );
  }
}
