import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_menu_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/tabs_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/env.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  void _closeAnd(VoidCallback action) {
    Get.back();
    action();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      return const Drawer(child: SizedBox());
    }

    return GetBuilder<LocaleController>(
      builder: (_) {
        return GetBuilder<ProfileController>(
      builder: (value) {
        final isPremium = value.premium.value;
        return Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(value, isPremium),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _section('Home'.tr),
                      _item(
                        icon: Icons.content_paste_outlined,
                        title: 'Appointments'.tr,
                        onTap: () => _closeAnd(() {
                          if (Get.isRegistered<TabsController>()) {
                            Get.find<TabsController>().updateTabId(0);
                          }
                        }),
                      ),
                      // PRODUCT / Orders — hidden
                      // _item(
                      //   icon: Icons.shopping_cart_outlined,
                      //   title: 'Orders'.tr,
                      //   onTap: () => _closeAnd(() {
                      //     if (Get.isRegistered<TabsController>()) {
                      //       Get.find<TabsController>().updateTabId(1);
                      //     }
                      //   }),
                      // ),
                      _item(
                        icon: Icons.currency_exchange_outlined,
                        title: 'Earnings'.tr,
                        onTap: () => _closeAnd(() {
                          if (Get.isRegistered<TabsController>()) {
                            Get.find<TabsController>().updateTabId(1);
                          }
                        }),
                      ),
                      _item(
                        icon: Icons.calendar_today_outlined,
                        title: 'Calendar'.tr,
                        onTap: () => _closeAnd(() {
                          if (Get.isRegistered<TabsController>()) {
                            Get.find<TabsController>().updateTabId(2);
                          }
                        }),
                      ),
                      _item(
                        icon: Icons.person_outlined,
                        title: 'Profile'.tr,
                        onTap: () => _closeAnd(() {
                          if (Get.isRegistered<TabsController>()) {
                            Get.find<TabsController>().updateTabId(3);
                          }
                        }),
                      ),
                      _section('Offers'.tr),
                      _item(
                        icon: Icons.bolt_outlined,
                        title: 'Limited Offer'.tr,
                        onTap: () => _closeAnd(value.onLimitedOffers),
                      ),
                      _item(
                        icon: Icons.local_offer_outlined,
                        title: 'Offers'.tr,
                        onTap: () => _closeAnd(value.onCoupons),
                      ),
                      _section('Business'.tr),
                      _item(
                        icon: Icons.history_toggle_off,
                        title: 'Appointment History'.tr,
                        onTap: () => _closeAnd(value.onAppoitmentHistory),
                      ),
                      _item(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile'.tr,
                        onTap: () => _closeAnd(value.onEditProfile),
                      ),
                      _item(
                        icon: Icons.link_outlined,
                        title: 'Connect & Social Links'.tr,
                        onTap: () => _closeAnd(value.onConnectLinks),
                      ),
                      _item(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Withdrawals'.tr,
                        onTap: () => _closeAnd(value.onWithdrawals),
                      ),
                      _item(
                        icon: Icons.image_outlined,
                        title: 'Gallery'.tr,
                        isPremium: !isPremium,
                        onTap: () => _closeAnd(() {
                          if (isPremium) {
                            value.onGallary();
                          } else {
                            value.onPremiumRequired(context);
                          }
                        }),
                      ),
                      _item(
                        icon: Icons.ads_click,
                        title: 'Publish Ads'.tr,
                        isPremium: !isPremium,
                        onTap: () => _closeAnd(() {
                          if (isPremium) {
                            value.onAds();
                          } else {
                            value.onPremiumRequired(context);
                          }
                        }),
                      ),
                      _item(
                        icon: Icons.campaign_outlined,
                        title: 'Manage Ads'.tr,
                        isPremium: !isPremium,
                        onTap: () => _closeAnd(() {
                          if (isPremium) {
                            value.onManageAds();
                          } else {
                            value.onPremiumRequired(context);
                          }
                        }),
                      ),
                      _item(
                        icon: Icons.event_busy_outlined,
                        title: 'Holidays'.tr,
                        onTap: () => _closeAnd(value.onHolidays),
                      ),
                      _item(
                        icon: Icons.room_service_outlined,
                        title: 'Facilities'.tr,
                        onTap: () => _closeAnd(value.onFacilities),
                      ),
                      _section('Services'.tr),
                      _item(
                        icon: Icons.access_time,
                        title: 'Slots'.tr,
                        onTap: () => _closeAnd(value.onSlot),
                      ),
                      _item(
                        icon: Icons.storefront_outlined,
                        title: 'Services'.tr,
                        onTap: () => _closeAnd(value.onServices),
                      ),
                      if (value.type == true)
                        _item(
                          icon: Icons.style_outlined,
                          title: 'Stylist'.tr,
                          onTap: () => _closeAnd(value.onStylist),
                        ),
                      // PRODUCT RELATED — hidden
                      // _item(
                      //   icon: Icons.list_alt,
                      //   title: 'Products'.tr,
                      //   isPremium: !isPremium,
                      //   onTap: () => _closeAnd(() {
                      //     if (isPremium) {
                      //       value.onProducts();
                      //     } else {
                      //       value.onPremiumRequired(context);
                      //     }
                      //   }),
                      // ),
                      _item(
                        icon: Icons.receipt_long_outlined,
                        title: 'Packages'.tr,
                        onTap: () => _closeAnd(value.onPackages),
                      ),
                      _section('Communication'.tr),
                      _item(
                        icon: Icons.chat_outlined,
                        title: 'Chats'.tr,
                        onTap: () => _closeAnd(value.onInbox),
                      ),
                      _item(
                        icon: Icons.rate_review_outlined,
                        title: 'Reviews'.tr,
                        onTap: () => _closeAnd(value.onReview),
                      ),
                      // PRODUCT RELATED — Order History hidden
                      // _item(
                      //   icon: Icons.history,
                      //   title: 'Order History'.tr,
                      //   onTap: () => _closeAnd(value.onHistory),
                      // ),
                      _item(
                        icon: Icons.report_outlined,
                        title: 'Complaints'.tr,
                        onTap: () => _closeAnd(value.onComplaints),
                      ),
                      _item(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications'.tr,
                        onTap: () => _closeAnd(value.onNotifications),
                      ),
                      _section('Quick Actions'.tr),
                      _item(
                        icon: Icons.free_cancellation,
                        title: 'Cancel All Appointments'.tr,
                        destructive: true,
                        onTap: () => _closeAnd(value.onCancelAllAppointments),
                      ),
                      if (!isPremium)
                        _item(
                          icon: Icons.workspace_premium,
                          title: 'Upgrade to Premium'.tr,
                          onTap: () => _closeAnd(value.onUpgradeScreen),
                        ),
                      _section('Support'.tr),
                      _item(
                        icon: Icons.translate,
                        title: 'Languages'.tr,
                        onTap: () => _closeAnd(value.onLanguages),
                      ),
                      _item(
                        icon: Icons.contact_page_outlined,
                        title: 'Contact Us'.tr,
                        onTap: () => _closeAnd(value.onContactUs),
                      ),
                      _item(
                        icon: Icons.help_outline,
                        title: 'Help'.tr,
                        onTap: () => _closeAnd(
                            () => value.onAppPages('Help'.tr, '6')),
                      ),
                      _item(
                        icon: Icons.flag_outlined,
                        title: 'FAQ'.tr,
                        onTap: () => _closeAnd(() => value.onAppPages(
                            'Frequently Asked Questions'.tr, '5')),
                      ),
                      _item(
                        icon: Icons.security_outlined,
                        title: 'Privacy Policy'.tr,
                        onTap: () => _closeAnd(
                            () => value.onAppPages('Privacy Policy'.tr, '2')),
                      ),
                      _item(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Terms & Conditions'.tr,
                        onTap: () => _closeAnd(() =>
                            value.onAppPages('Terms & Conditions'.tr, '3')),
                      ),
                      _item(
                        icon: Icons.info_outline,
                        title: 'About'.tr,
                        onTap: () => _closeAnd(
                            () => value.onAppPages('About us'.tr, '1')),
                      ),
                      const SizedBox(height: 8),
                      _item(
                        icon: Icons.logout,
                        title: 'Logout'.tr,
                        destructive: true,
                        onTap: () => _closeAnd(value.onLogout),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
      },
    );
  }

  Widget _buildHeader(ProfileController value, bool isPremium) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: ThemeProvider.appColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: AppNetImage(
                   path: value.cover.value,
                    fit: BoxFit.cover,
                    placeholder: Image.asset(
                      'assets/images/placeholder.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.name.value.isEmpty
                            ? Environments.appName
                            : value.name.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'bold',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${value.uid.value}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPremium ? ThemeProvider.golden : Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPremium
                    ? (value.planName.value.isNotEmpty
                        ? value.planName.value.toUpperCase()
                        : 'PREMIUM'.tr)
                    : 'STANDARD'.tr,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'bold',
                  color: isPremium ? Colors.black : Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontFamily: 'bold',
          letterSpacing: 0.8,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isPremium = false,
    bool destructive = false,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        size: 22,
        color: destructive ? Colors.red : ThemeProvider.appColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'medium',
          color: destructive ? Colors.red : Colors.black87,
        ),
      ),
      trailing: isPremium
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontFamily: 'bold',
                ),
              ),
            )
          : const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}

void openAppDrawer() {
  if (Get.isRegistered<TabsController>()) {
    Get.find<TabsController>().scaffoldKey.currentState?.openDrawer();
  }
}
