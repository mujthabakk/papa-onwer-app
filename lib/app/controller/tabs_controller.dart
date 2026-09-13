import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/tabs_parse.dart';

class TabsController extends GetxController
    with GetTickerProviderStateMixin
    implements GetxService {
  final TabsParser parser;
  int tabId = 0;
  late TabController tabController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TabsController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    // 4 tabs: Appointment, Earnings, Calendar, Profile (Orders/Products hidden)
    tabController = TabController(length: 4, vsync: this, initialIndex: tabId);
  }

  void cleanLoginCreds() {
    // parser.cleanData();
  }

  void updateTabId(int id) {
    tabId = id.clamp(0, 3);
    if (tabController.length > tabId) {
      tabController.animateTo(tabId);
    }
    update();
  }
}
