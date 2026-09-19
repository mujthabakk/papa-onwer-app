import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/tabs_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/view/analytics.dart';
import 'package:ultimate_salon_owner_flutter/app/view/appointment.dart';
import 'package:ultimate_salon_owner_flutter/app/view/calendar.dart';
// PRODUCT RELATED — hidden for now
// import 'package:ultimate_salon_owner_flutter/app/view/product_order_listing.dart';
import 'package:ultimate_salon_owner_flutter/app/view/profile_menu.dart';
import 'package:ultimate_salon_owner_flutter/app/util/drawer.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({Key? key}) : super(key: key);
  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  // Keep page instances stable so Syncfusion charts are not disposed/recreated
  // on every GetBuilder rebuild (fixes RenderChartFadeTransition DISPOSED crash).
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      AppointmentScreen(),
      // HistoryScreen(), // PRODUCT / Orders tab — hidden
      AnalyticScreen(),
      CalendarScreen(),
      ProfileScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<LocaleController>()) {
        Get.find<LocaleController>().bootstrap(force: false, applyLocale: false);
      }
    });
  }

  double getResponsiveSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = (screenWidth / 375.0).clamp(0.8, 1.5);
    return baseSize * scaleFactor;
  }

  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  @override
  Widget build(BuildContext context) {
    bool isTabletDevice = isTablet(context);

    double fontSize = isTabletDevice
        ? getResponsiveSize(context, 14.0)
        : getResponsiveSize(context, 11.0);

    double iconSize = isTabletDevice
        ? getResponsiveSize(context, 30.0)
        : getResponsiveSize(context, 24.0);

    double gap = isTabletDevice
        ? getResponsiveSize(context, 8.0)
        : getResponsiveSize(context, 4.0);

    double horizontalPadding = isTabletDevice
        ? getResponsiveSize(context, 20.0)
        : getResponsiveSize(context, 12.0);

    double verticalPadding = isTabletDevice
        ? getResponsiveSize(context, 8.0)
        : getResponsiveSize(context, 5.0);

    double containerVerticalPadding = isTabletDevice
        ? getResponsiveSize(context, 15.0)
        : getResponsiveSize(context, 10.0);

    double containerHorizontalPadding = isTabletDevice
        ? getResponsiveSize(context, 10.0)
        : getResponsiveSize(context, 5.0);

    return GetBuilder<TabsController>(builder: (value) {
      return Scaffold(
        key: value.scaffoldKey,
        backgroundColor: Colors.white,
        drawer: const AppDrawer(),
        bottomNavigationBar: SafeArea(
          bottom: true,
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: containerVerticalPadding,
                  horizontal: containerHorizontalPadding),
              child: GetBuilder<LocaleController>(
                builder: (_) {
                  return GNav(
                      rippleColor: ThemeProvider.appColor,
                      hoverColor: ThemeProvider.appColor,
                      haptic: false,
                      curve: Curves.easeOutExpo,
                      tabBorderRadius: getResponsiveSize(context, 10.0),
                      textStyle: TextStyle(
                          fontFamily: 'bold',
                          color: Colors.white,
                          fontSize: fontSize),
                      duration: const Duration(milliseconds: 300),
                      gap: gap,
                      color: Colors.grey.shade400,
                      activeColor: ThemeProvider.golden,
                      iconSize: iconSize,
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding),
                      tabs: [
                        GButton(
                          icon: Icons.content_paste_outlined,
                          text: 'Appoinment'.tr,
                          backgroundColor: ThemeProvider.appColor,
                        ),
                        // PRODUCT / Orders tab — hidden
                        // GButton(
                        //   icon: Icons.shopping_cart_outlined,
                        //   text: 'Orders'.tr,
                        //   backgroundColor: ThemeProvider.appColor,
                        // ),
                        GButton(
                          icon: Icons.currency_exchange_outlined,
                          text: 'Earnings'.tr,
                          backgroundColor: ThemeProvider.appColor,
                        ),
                        GButton(
                          icon: Icons.calendar_today_outlined,
                          text: 'Calendar'.tr,
                          backgroundColor: ThemeProvider.appColor,
                        ),
                        GButton(
                          icon: Icons.person_outlined,
                          text: 'Profile'.tr,
                          backgroundColor: ThemeProvider.appColor,
                        ),
                      ],
                      selectedIndex: value.tabId,
                      onTabChange: (index) {
                        value.updateTabId(index);
                      },
                    );
                },
              ),
            ),
          ),
        ),
        body: IndexedStack(
          index: value.tabId,
          children: _pages,
        ),
      );
    });
  }
}
