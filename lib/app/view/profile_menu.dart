import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_menu_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/view/widgets/locale_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocaleController>(builder: (_) {
    return GetBuilder<ProfileController>(
      builder: (value) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: CustomScrollView(
            slivers: [
              // Modern Header with Profile Info
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 250,
                floating: false,
                pinned: true,
                actions: const [
                  LocalePickerBar(
                    foregroundColor: Colors.white,
                    compact: true,
                  ),
                  SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ThemeProvider.appColor,
                          ThemeProvider.appColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background Image with Overlay
                        Container(
                            height: double.infinity,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/h4.jpg'),
                                fit: BoxFit.cover,
                              ),
                            )),
                        // Dark Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        // Profile Content
                        Positioned(
                          bottom: 30,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              // Profile Image with Modern Border
                              Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Obx(
                                    () => ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: SizedBox.fromSize(
                                        size: const Size.fromRadius(45),
                                        child: AppNetImage(
                                         path: value.cover.value,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )),
                              const SizedBox(height: 12),
                              // Name
                              Obx(() => Text(
                                    '${value.name.value} # ${value.uid.value}',
                                    style: const TextStyle(
                                      fontFamily: 'bold',
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                              const SizedBox(height: 8),
                              // Rating
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${value.ownerReviewsList.length} Reviews',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          Icons.star,
                                          size: 14,
                                          color:
                                              value.parser.getRating() > index
                                                  ? Colors.amber
                                                  : Colors.grey[300],
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Pinned App Bar
                // bottom: PreferredSize(
                //   preferredSize: const Size.fromHeight(60),
                //   child: Container(
                //     decoration: const BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.only(
                //         topLeft: Radius.circular(25),
                //         topRight: Radius.circular(25),
                //       ),
                //     ),
                //     child: AppBar(
                //       backgroundColor: Colors.transparent,
                //       elevation: 0,
                //       automaticallyImplyLeading: false,
                //       centerTitle: true,
                //       title: Text(
                //         'Your Profile'.tr,
                //         style: const TextStyle(
                //           fontFamily: 'bold',
                //           fontSize: 18,
                //           color: Colors.black87,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Premium/Pro Banner
                      Obx(() => value.premium.value
                          ? _buildProBanner(value)
                          : _buildPremiumBanner(value)),
                      // Menu Sections
                      _buildMenuSection(
                        title: 'Account Management'.tr,
                        icon: Icons.account_circle_outlined,
                        children: [
                          // if (!value.premium.value)
                          //   _buildMenuItem(
                          //     icon: Icons.workspace_premium,
                          //     title: 'Upgrade Account',
                          //     onTap: () => value.onUpgradeScreen(),
                          //     isPremium: true,
                          //   ),
                          _buildMenuItem(
                            icon: Icons.history_toggle_off,
                            title: 'Appointment History'.tr,
                            onTap: () => value.onAppoitmentHistory(),
                          ),
                          _buildMenuItem(
                            icon: Icons.edit_outlined,
                            title: 'Edit Profile'.tr,
                            onTap: () => value.onEditProfile(),
                          ),
                          _buildMenuItem(
                            icon: Icons.currency_exchange,
                            title: 'Withdrawal Request'.tr,
                            onTap: () => value.onWithdrawals(),
                          ),
                        ],
                      ),
                      _buildMenuSection(
                        title: 'Business Tools'.tr,
                        icon: Icons.business_center_outlined,
                        children: [
                          _buildMenuItem(
                            icon: Icons.image_outlined,
                            title: 'Gallery'.tr,
                            onTap: () {
                              if (value.parser.getPremium()) {
                                value.onGallary();
                              } else {
                                value.onPremiumRequired(context);
                              }
                            },
                            requiresPremium: !value.parser.getPremium(),
                          ),
/////////////////////////// remove for test version/////////////////////
                          _buildMenuItem(
                            icon: Icons.ads_click,
                            title: 'Publish Ads'.tr,
                            onTap: () {
                              if (value.parser.getPremium()) {
                                value.onAds();
                              } else {
                                value.onPremiumRequired(context);
                              }
                            },
                            requiresPremium: !value.parser.getPremium(),
                          ),
                          _buildMenuItem(
                            icon: Icons.edit,
                            title: 'Manage Ads'.tr,
                            onTap: () {
                              if (value.parser.getPremium()) {
                                value.onManageAds();
                              } else {
                                value.onPremiumRequired(context);
                              }
                            },
                            requiresPremium: !value.parser.getPremium(),
                          ),
////////////////////////////////////////////////////////////

                          _buildMenuItem(
                            icon: Icons.local_offer_outlined,
                            title: 'Offers'.tr,
                            onTap: () => value.onCoupons(),
                          ),
                          _buildMenuItem(
                            icon: Icons.bolt_outlined,
                            title: 'Limited Offer'.tr,
                            onTap: () => value.onLimitedOffers(),
                          ),
                          _buildMenuItem(
                            icon: Icons.event_busy_outlined,
                            title: 'Holidays'.tr,
                            onTap: () => value.onHolidays(),
                          ),
                          _buildMenuItem(
                            icon: Icons.room_service_outlined,
                            title: 'Facilities'.tr,
                            onTap: () => value.onFacilities(),
                          ),
                        ],
                      ),
                      _buildMenuSection(
                        title: 'Services'.tr,
                        icon: Icons.store_outlined,
                        children: [
                          _buildMenuItem(
                            icon: Icons.access_time,
                            title: 'Slots'.tr,
                            onTap: () => value.onSlot(),
                          ),
                          _buildMenuItem(
                            icon: Icons.shop,
                            title: 'Services'.tr,
                            onTap: () => value.onServices(),
                          ),
                          if (value.type == true)
                            _buildMenuItem(
                              icon: Icons.style_outlined,
                              title: 'Stylist'.tr,
                              onTap: () => value.onStylist(),
                            ),
                          // PRODUCT RELATED — hidden
                          // _buildMenuItem(
                          //   icon: Icons.list_alt,
                          //   title: 'Products'.tr,
                          //   onTap: () {
                          //     if (value.parser.getPremium()) {
                          //       value.onProducts();
                          //     } else {
                          //       value.onPremiumRequired(context);
                          //     }
                          //   },
                          //   requiresPremium: !value.parser.getPremium(),
                          // ),
                          _buildMenuItem(
                            icon: Icons.receipt_long_outlined,
                            title: 'Packages'.tr,
                            onTap: () => value.onPackages(),
                          ),
                        ],
                      ),
                      _buildMenuSection(
                        title: 'Communication'.tr,
                        icon: Icons.chat_outlined,
                        children: [
                          _buildMenuItem(
                            icon: Icons.link_outlined,
                            title: 'Connect & Social Links'.tr,
                            onTap: () => value.onConnectLinks(),
                          ),
                          _buildMenuItem(
                            icon: Icons.chat_outlined,
                            title: 'Chats'.tr,
                            onTap: () => value.onInbox(),
                          ),
                          _buildMenuItem(
                            icon: Icons.rate_review_outlined,
                            title: 'Review'.tr,
                            onTap: () => value.onReview(),
                          ),
                          _buildMenuItem(
                            icon: Icons.report_outlined,
                            title: 'Complaints'.tr,
                            onTap: () => value.onComplaints(),
                          ),
                          _buildMenuItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications'.tr,
                            onTap: () => value.onNotifications(),
                          ),
                          _buildMenuItem(
                            icon: Icons.translate,
                            title: 'Languages'.tr,
                            onTap: () => value.onLanguages(),
                          ),
                          // PRODUCT RELATED — Order History hidden
                          // _buildMenuItem(
                          //   icon: Icons.history,
                          //   title: 'Order History'.tr,
                          //   onTap: () => value.onHistory(),
                          // ),
                        ],
                      ),
                      _buildMenuSection(
                        title: 'Quick Actions'.tr,
                        icon: Icons.flash_on_outlined,
                        children: [
                          _buildMenuItem(
                            icon: Icons.free_cancellation,
                            title: 'Cancel All Appointments'.tr,
                            onTap: () => value.onCancelAllAppointments(),
                            isDestructive: true,
                          ),
                        ],
                      ),
                      _buildMenuSection(
                        title: 'Support & Legal'.tr,
                        icon: Icons.help_outline,
                        children: [
                          _buildMenuItem(
                            icon: Icons.flag_outlined,
                            title: 'Frequently Asked Questions'.tr,
                            onTap: () => value.onAppPages(
                                'Frequently Asked Questions'.tr, '5'),
                          ),
                          _buildMenuItem(
                            icon: Icons.free_cancellation,
                            title: 'Cancellation & Refund Policy'.tr,
                            onTap: () => value.onAppPages(
                                'Cancellation & Refund Policy'.tr, '4'),
                          ),
                          _buildMenuItem(
                            icon: Icons.contact_page_outlined,
                            title: 'Contact Us'.tr,
                            onTap: () => value.onContactUs(),
                          ),
                          _buildMenuItem(
                            icon: Icons.delete_outline,
                            title: 'Delete My Account'.tr,
                            onTap: () => value.onDeleteAccount(),
                          ),
                          _buildMenuItem(
                            icon: Icons.help_outline,
                            title: 'Help'.tr,
                            onTap: () => value.onAppPages('Help'.tr, '6'),
                          ),
                          _buildMenuItem(
                            icon: Icons.security_outlined,
                            title: 'Privacy Policy'.tr,
                            onTap: () =>
                                value.onAppPages('Privacy Policy'.tr, '2'),
                          ),
                          _buildMenuItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Terms & Conditions'.tr,
                            onTap: () =>
                                value.onAppPages('Terms & Conditions'.tr, '3'),
                          ),
                          _buildMenuItem(
                            icon: Icons.cookie_outlined,
                            title: 'Cookie Policy'.tr,
                            onTap: () =>
                                value.onAppPages('Cookie Policy'.tr, '8'),
                          ),
                          _buildMenuItem(
                            icon: Icons.info_outline,
                            title: 'About'.tr,
                            onTap: () => value.onAppPages('About us'.tr, '1'),
                          ),
                        ],
                      ),
                      // Logout Section
                      Container(
                        margin: const EdgeInsets.all(20),
                        child: _buildMenuItem(
                          icon: Icons.logout,
                          title: 'Logout'.tr,
                          onTap: () => value.onLogout(),
                          isDestructive: true,
                          showBorder: true,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    });
  }

  String _planExpiryLine(ProfileController value) {
    final parts = <String>[];
    if (value.planExpiresAt.value.isNotEmpty) {
      parts.add('Expires ${value.planExpiresAt.value}');
    }
    if (value.planDaysRemaining.value > 0) {
      parts.add('${value.planDaysRemaining.value} days left');
    }
    if (parts.isEmpty) {
      return 'You have access to all premium features';
    }
    return parts.join(' · ');
  }

  Widget _buildProBanner(ProfileController value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 44, 123, 196),
            Color.fromARGB(255, 15, 179, 255),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 39, 123, 176).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.diamond,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value.planName.value.isNotEmpty
                            ? value.planName.value
                            : 'Premium Account',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        (value.planCode.value.isNotEmpty
                                ? value.planCode.value
                                : 'PRO')
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 27, 143, 194),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _planExpiryLine(value),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner(ProfileController value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 109, 137, 223),
            Color.fromARGB(255, 169, 105, 237),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 144, 62, 232).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Premium'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Unlock all features and grow your business'.tr,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => value.onUpgradeScreen(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color.fromARGB(255, 46, 46, 46),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text('Upgrade'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: ThemeProvider.appColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool requiresPremium = false,
    bool isPremium = false,
    bool isDestructive = false,
    bool showBorder = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: showBorder
            ? BoxDecoration(
                border: Border.all(
                  color: isDestructive
                      ? Colors.red.shade200
                      : Colors.grey.shade200,
                ),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPremium
                    ? Colors.amber.shade100
                    : isDestructive
                        ? Colors.red.shade50
                        : ThemeProvider.appColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isPremium
                    ? Colors.amber.shade700
                    : isDestructive
                        ? Colors.red.shade600
                        : ThemeProvider.appColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red.shade600 : Colors.black87,
                ),
              ),
            ),
            if (requiresPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.deepPurple.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
