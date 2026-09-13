import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/upgrade_plan_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/premium_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/upgrade_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_menu_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/view/upgrade_payment.dart';

class PremiumController extends GetxController implements GetxService {
  final PremiumParser parser;
  final UpgradeParser upgradeParser;

  PremiumController({
    required this.parser,
    required this.upgradeParser,
  });

  final box = GetStorage();

  var isLoadingPlans = true.obs;
  var isCreatingPayment = false.obs;
  var plans = <UpgradePlanModel>[].obs;

  int? activeOrderId;
  String? activePaymentLinkId;

  static const defaultBenefits = [
    'Cash Payment at shop',
    'Gallery Listing',
    'Coupon Discount',
    'Run Ads on customer app',
    'Shop QR Code Option',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    isLoadingPlans.value = true;
    update();
    try {
      final response = await upgradeParser.getUpgradePlans();
      if (response.statusCode == 200) {
        final body = response.body;
        List? list;
        if (body is Map) {
          if (body['data'] is List) {
            list = body['data'] as List;
          } else if (body['plans'] is List) {
            list = body['plans'] as List;
          }
        }
        if (list != null) {
          plans.value = list
              .whereType<Map>()
              .map((item) =>
                  UpgradePlanModel.fromJson(Map<String, dynamic>.from(item)))
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        } else {
          ApiChecker.checkApi(response);
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoadingPlans.value = false;
      update();
    }
  }

  Future<void> purchasePlan(UpgradePlanModel plan) async {
    if (isCreatingPayment.value) return;
    isCreatingPayment.value = true;
    EasyLoading.show(status: 'Creating payment link...');
    update();

    try {
      final response = await upgradeParser.createPaymentLink(
        planId: plan.id,
        amount: plan.amount,
      );

      if (response.statusCode != 200 || response.body['success'] != true) {
        ApiChecker.checkApi(response);
        return;
      }

      final payment = UpgradePaymentLinkModel.fromJson(
          Map<String, dynamic>.from(response.body['data']));
      if (payment.paymentLink.isEmpty) {
        Fluttertoast.showToast(msg: 'Payment link not available');
        return;
      }

      activeOrderId = payment.orderId;
      activePaymentLinkId = payment.paymentLinkId;

      EasyLoading.dismiss();
      final paid = await Get.to<bool>(() => UpgradePaymentScreen(
            paymentLink: payment.paymentLink,
            orderId: payment.orderId,
            paymentLinkId: payment.paymentLinkId,
            planName: payment.planName,
            onVerify: verifyPayment,
          ));

      if (paid == true) {
        return;
      }

      await verifyPayment(
        orderId: payment.orderId,
        paymentLinkId: payment.paymentLinkId,
        showPendingMessage: true,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      EasyLoading.dismiss();
      isCreatingPayment.value = false;
      update();
    }
  }

  Future<bool> verifyPayment({
    int? orderId,
    String? paymentLinkId,
    bool showPendingMessage = false,
    bool showSuccessDialog = true,
  }) async {
    final response = await upgradeParser.verifyPayment(
      orderId: orderId ?? activeOrderId,
      paymentLinkId: paymentLinkId ?? activePaymentLinkId,
    );

    if (response.statusCode != 200 || response.body['success'] != true) {
      if (showPendingMessage) {
        ApiChecker.checkApi(response);
      }
      return false;
    }

    final result = UpgradeVerifyModel.fromJson(
        Map<String, dynamic>.from(response.body['data']));

    if (result.isPaid && result.isPremium) {
      _applyPremiumSuccess(
        expiresAt: result.upgradeExpiresAt,
        showDialog: showSuccessDialog,
      );
      return true;
    }

    if (showPendingMessage) {
      Fluttertoast.showToast(
        msg: 'Payment is still pending. Please complete payment and try again.',
      );
    }
    return false;
  }

  void _applyPremiumSuccess({
    String? expiresAt,
    bool showDialog = true,
  }) {
    parser.premiumStat(true);
    box.write('premium', true);

    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().premium.value = true;
    }

    final expiryText = expiresAt != null && expiresAt.isNotEmpty
        ? '\nValid until $expiresAt'
        : '';

    if (showDialog && Get.context != null) {
          showDialogScreen(
        Get.context!,
        'Premium Activated',
        'Your upgrade is successful.$expiryText\nEnjoy all premium benefits.',
              Icons.check_circle,
        Colors.green,
      );
    }
    update();
  }

  void showUpgradeDialog(BuildContext context) {
    Get.toNamed(AppRouter.getPremiumRoute());
  }

  void showDialogScreen(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color iconColor,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 16,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iconColor.withOpacity(0.1),
                        iconColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(icon, color: iconColor, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
