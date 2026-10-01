import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/owner_reviews_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/partner_plan_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/upgrade_plan_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/profile_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/ads_managing_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/ads_publish_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/app_pages_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/cancellAll_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/contact_us_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/complaints_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/coupon_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/timed_offers_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/connect_links_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/facilities_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/gallary_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/holiday_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/notification_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/product_history_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/inbox_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_individual_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/packages_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/premium_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/previous_appointments_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/products_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_business_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/review_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/slot_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/stylist_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/withdrawal_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_nav.dart';
import 'package:ultimate_salon_owner_flutter/app/util/tax_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class ProfileController extends GetxController
    with GetTickerProviderStateMixin
    implements GetxService {
  final ProfileParser parser;

  bool type = true;

  ProfileController({required this.parser});

  late TabController tabController;
  List<OwnerReviewsModel> _ownerReviewsList = <OwnerReviewsModel>[];
  List<OwnerReviewsModel> get ownerReviewsList => _ownerReviewsList;
  var name = ''.obs; // Reactive observable variable for the name
  var premium = false.obs;
  var cover = ''.obs;
  var uid = ''.obs;
  var planName = ''.obs;
  var planExpiresAt = ''.obs;
  var planDaysRemaining = 0.obs;
  var planCode = ''.obs;
  final availablePlans = <UpgradePlanModel>[].obs;

  void updateName(String newName) {
    name.value = newName; // Update the value of name
  }

  String getName() {
    return name.value;
  }

  void updatePremium(bool newPremium) {
    premium.value = newPremium;
  }

  bool getPremium() {
    return premium.value;
  }

  void applyPlan(PartnerPlanModel plan) {
    plan.save(parser.sharedPreferencesManager);
    premium.value = plan.isActivePremium;
    planName.value = plan.displayName;
    planExpiresAt.value = plan.upgradeExpiresAt ?? '';
    planDaysRemaining.value = plan.daysRemaining;
    planCode.value = plan.code ?? '';
    update();
  }

  void loadLocalPlan() {
    applyPlan(PartnerPlanModel.load(parser.sharedPreferencesManager));
  }

  Future<void> refreshPlan() async {
    if (!parser.sharedPreferencesManager.hasOwnerSession()) return;
    try {
      var response = await parser.getProfileById();
      if (response.statusCode != 200) {
        response = await parser.getOwnerInfo();
      }
      if (response.statusCode == 200) {
        TaxHelper.applyFromBody(response.body);
        availablePlans.assignAll(
          UpgradePlanModel.extractAvailablePlans(response.body),
        );
        if (Get.isRegistered<PremiumController>() &&
            availablePlans.isNotEmpty) {
          Get.find<PremiumController>().seedPlans(availablePlans);
        }
        final plan = PartnerPlanModel.extract(response.body);
        if (plan != null) {
          applyPlan(plan);
          await TaxHelper.refresh();
          return;
        }
      }
    } catch (_) {}
    loadLocalPlan();
    await TaxHelper.refresh();
  }

  @override
  void onInit() {
    name.value = parser.getName();
    uid.value = parser.getUID();
    cover.value = parser.getCover();
    loadLocalPlan();

    if (parser.sharedPreferencesManager.hasOwnerSession()) {
      getMyReviews();
      refreshPlan();
    }

    super.onInit();
    type = parser.getType();
    debugPrint('profile type is --> $type');
    tabController = TabController(length: 3, vsync: this);
  }

  Future<void> getMyReviews() async {
    var response = await parser.getMyReviews();
    // apiCalled = true;
    _ownerReviewsList = [];
    update();
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'];

      body.forEach((data) {
        OwnerReviewsModel reviews = OwnerReviewsModel.fromJson(data);
        _ownerReviewsList.add(reviews);
      });
      update();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onHistory() {
    AppNav.toNamed(AppRouter.getHistoryRoute());
  }

  void onSlot() {
    AppNav.toNamed(AppRouter.getSlotRoute());
  }

  void onServices() {
    AppNav.toNamed(AppRouter.getServicesRoute());
  }

  void onStylist() {
    AppNav.toNamed(AppRouter.getStylistRoute());
  }

  void onProducts() {
    AppNav.toNamed(AppRouter.getProductsRoute());
  }

  void onPackages() {
    AppNav.toNamed(AppRouter.getPackagesRoute());
  }

  void onEditProfile() {
    if (type == true) {
      AppNav.toNamed(AppRouter.getProfileCategoriesRoute());
    } else {
      AppNav.toNamed(AppRouter.getIndividualProfileRoute());
    }
  }

  void onUpgradeScreen({UpgradePlanModel? selected}) {
    if (Get.isRegistered<PremiumController>() && availablePlans.isNotEmpty) {
      Get.find<PremiumController>().seedPlans(availablePlans);
    }
    AppNav.toNamed(AppRouter.getPremiumRoute(), arguments: selected);
  }

  void onAppoitmentHistory() {
    AppNav.toNamed(AppRouter.getPreviousAppointmentsRoute(),
        arguments: ['search', 0, 0, 0]);
  }

  void onGallary() {
    AppNav.toNamed(AppRouter.getGallaryRoute());
  }

  void onPremiumRequired(BuildContext context) {
    Get.defaultDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: double.infinity,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Asset image at the top
              const Text(
                'Premium Account Required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 209, 165, 32),
                ),
              ),
              Image.asset(
                'assets/images/icon_logo.png',
                fit: BoxFit.contain,
                width: 100,
                height: 100,
              ),
              SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'You need a premium account to access this feature. Would you like to upgrade?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 209, 165, 32),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    icon: Icon(Icons.cancel, color: Colors.white),
                    label: Text('Cancel'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      onUpgradeScreen();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeProvider.golden,
                    ),
                    icon: Icon(Icons.workspace_premium, color: Colors.black),
                    label:
                        Text('Upgrade', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
      radius: 15.0,
      barrierDismissible: false,
    );
  }

  void onReview() {
    AppNav.toNamed(AppRouter.getReviewRoute());
  }

  void onInbox() {
    AppNav.toNamed(AppRouter.getInboxRoute());
  }

  void onAds() {
    // Get.delete<AdsPublishController>(force: true);
    // Get.toNamed(AppRouter.getAdsRoute());

    AppNav.toNamed(AppRouter.getAdsRoute(), arguments: ['new']);
  }

  void onManageAds() {
    // Get.delete<AdsPublishController>(force: true);
    // Get.toNamed(AppRouter.getAdsRoute());

    AppNav.toNamed(AppRouter.getAdsManageRoute(), arguments: ['new']);
  }

  void onWithdrawals() {
    AppNav.toNamed(AppRouter.getWithdrawalsRoute());
  }

  void onCancelAllAppointments() {
    AppNav.toNamed(AppRouter.getCancelAllAppointmentsRoute());
  }

  void onCoupons() {
    AppNav.toNamed(AppRouter.getCouponsRoute());
  }

  void onLimitedOffers() {
    AppNav.toNamed(AppRouter.getTimedOffersRoute());
  }

  void onConnectLinks() {
    AppNav.toNamed(AppRouter.getConnectLinksRoute());
  }

  void onHolidays() {
    AppNav.toNamed(AppRouter.getHolidayRoutes());
  }

  void onFacilities() {
    AppNav.toNamed(AppRouter.getFacilities());
  }

  void onComplaints() {
    AppNav.toNamed(AppRouter.getComplaintRoute());
  }

  void onNotifications() {
    AppNav.toNamed(AppRouter.getNotifications());
  }

  void onLanguages() {
    Get.toNamed(AppRouter.getLanguagesRoute());
  }

  void onContactUs() {
    AppNav.toNamed(AppRouter.getContactUsRoute());
  }

  void onDeleteAccount() {
    // First confirmation dialog - Warning about consequences
    Get.dialog(
      AlertDialog(
        //
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red[700],
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              'Delete Account?'.tr,
              style: const TextStyle(
                fontFamily: 'bold',
                fontSize: 20,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. Deleting your account will:'.tr,
              style: const TextStyle(
                fontFamily: 'semibold',
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            _buildWarningItem(
                'Permanently delete your profile and all data (Your account will be deleted within 30 days)'
                    .tr),
            _buildWarningItem('Remove all your services and appointments'.tr),
            _buildWarningItem('Delete all your reviews and ratings'.tr),
            _buildWarningItem('Cancel any active bookings'.tr),
            _buildWarningItem('Remove access to your account immediately'.tr),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action is permanent and cannot be reversed'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontFamily: 'medium',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel'.tr,
              style: const TextStyle(
                fontFamily: 'medium',
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showFinalConfirmation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Continue'.tr,
              style: const TextStyle(
                fontFamily: 'semibold',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.close,
            color: Colors.red,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalConfirmation() {
    final TextEditingController confirmController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Final Confirmation'.tr,
          style: const TextStyle(
            fontFamily: 'bold',
            fontSize: 20,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To confirm account deletion, please type DELETE below:'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'medium',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                hintText: 'Type DELETE'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel'.tr,
              style: const TextStyle(
                fontFamily: 'medium',
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (confirmController.text.toUpperCase() == 'DELETE') {
                Get.back();
                _performAccountDeletion();
              } else {
                Get.snackbar(
                  'Error'.tr,
                  'Please type DELETE to confirm'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete Account'.tr,
              style: const TextStyle(
                fontFamily: 'semibold',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _performAccountDeletion() async {
    Get.dialog(
        SimpleDialog(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                const CircularProgressIndicator(
                  color: ThemeProvider.appColor,
                ),
                const SizedBox(
                  width: 30,
                ),
                SizedBox(
                    child: Text(
                  "Deleting account...".tr,
                  style: const TextStyle(fontFamily: 'bold'),
                )),
              ],
            )
          ],
        ),
        barrierDismissible: false);

    Response response = await parser.onDelete();
    Get.back();

    if (response.statusCode == 200) {
      parser.clearAccount();
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                'Account Deleted'.tr,
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 20,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          content: Text(
            'Your account has been permanently deleted within 30 days. We\'re sorry to see you go.'
                .tr,
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                parser.clearAccount();
                Get.back();
                Get.toNamed(AppRouter.getInitialRoute());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeProvider.appColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'OK'.tr,
                style: const TextStyle(
                  fontFamily: 'semibold',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onAppPages(String name, String id) {
    debugPrint('$name = $id');
    AppNav.toNamed(AppRouter.getAppPagesRoute(),
        arguments: [name, id], preventDuplicates: false);
  }

  Future<void> onLogout() async {
    Get.dialog(
        SimpleDialog(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                const CircularProgressIndicator(
                  color: ThemeProvider.appColor,
                ),
                const SizedBox(
                  width: 30,
                ),
                SizedBox(
                    child: Text(
                  "Please wait".tr,
                  style: const TextStyle(fontFamily: 'bold'),
                )),
              ],
            )
          ],
        ),
        barrierDismissible: false);
    Response response = await parser.logout();
    Get.back();
    if (response.statusCode == 200) {
      parser.clearAccount();
      Get.toNamed(AppRouter.getInitialRoute());
      update();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }
}
