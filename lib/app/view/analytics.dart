import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/analytics_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class AnalyticScreen extends StatefulWidget {
  const AnalyticScreen({super.key});

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen>
    with AutomaticKeepAliveClientMixin {
  TooltipBehavior? _tooltipBehavior;
  final ScrollController _scrollControllerAppointments = ScrollController();
  final ScrollController _scrollControllerProducts = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _tooltipBehavior =
        TooltipBehavior(enable: true, header: '', canShowMarker: false);
    super.initState();
  }

  @override
  void dispose() {
    _scrollControllerAppointments.dispose();
    _scrollControllerProducts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<AnalyticsController>(builder: (value) {
      Map<int, Widget> myTabs = <int, Widget>{
        0: Text(
          "Daily".tr,
          style: TextStyle(
              color:
                  Get.find<AnalyticsController>().segmentedControlGroupValue ==
                          0
                      ? ThemeProvider.whiteColor
                      : ThemeProvider.blackColor),
        ),
        1: Text("Monthly".tr,
            style: TextStyle(
                color: Get.find<AnalyticsController>()
                            .segmentedControlGroupValue ==
                        1
                    ? ThemeProvider.whiteColor
                    : ThemeProvider.blackColor)),
        2: Text("Yearly".tr,
            style: TextStyle(
                color: Get.find<AnalyticsController>()
                            .segmentedControlGroupValue ==
                        2
                    ? ThemeProvider.whiteColor
                    : ThemeProvider.blackColor)),
      };
      Map<int, Widget> myTabsProducts = <int, Widget>{
        0: Text(
          "Daily".tr,
          style: TextStyle(
              color: Get.find<AnalyticsController>()
                          .segmentedControlGroupValueProducts ==
                      0
                  ? ThemeProvider.whiteColor
                  : ThemeProvider.blackColor),
        ),
        1: Text("Monthly".tr,
            style: TextStyle(
                color: Get.find<AnalyticsController>()
                            .segmentedControlGroupValueProducts ==
                        1
                    ? ThemeProvider.whiteColor
                    : ThemeProvider.blackColor)),
        2: Text("Yearly".tr,
            style: TextStyle(
                color: Get.find<AnalyticsController>()
                            .segmentedControlGroupValueProducts ==
                        2
                    ? ThemeProvider.whiteColor
                    : ThemeProvider.blackColor)),
      };
      return Scaffold(
          backgroundColor: ThemeProvider.backgroundColor,
          appBar: AppBar(
              backgroundColor: ThemeProvider.appColor,
              iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
              elevation: 0,
              centerTitle: true,
              title: Row(
                children: [
                  Image.asset(
                    'assets/images/icon_logo.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Analyze'.tr,
                      style: ThemeProvider.titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                          if (value.parser.getPremium()) {
                              value.showDialogScreen(
                                  context,
                                  'Premium User',
                                  'Congratulations,\nEnjoy all premium benefits',
                                  Icons.star,
                                  Colors.green);
                          } else {
                              value.onUpgradeScreen();
                          }
                            },
                            child: Container(
                          padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: ThemeProvider.golden,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                          child: Row(
                                children: [
                                  Icon(
                                value.parser.getPremium()
                                    ? Icons.star
                                    : Icons.workspace_premium,
                                    color: ThemeProvider.golden,
                                    size: 22,
                                  ),
                                  Text(
                                value.parser.getPremium()
                                    ? ' Premium'
                                    : ' Upgrade',
                                style: const TextStyle(
                                      color: ThemeProvider.golden,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              value.onOpenNotifications();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.notifications_active,
                                color: ThemeProvider.golden,
                                size: 22,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              value.onInbox();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.chat,
                                color: ThemeProvider.golden,
                                size: 22,
                              ),
                            ),
                          ),
                    const SizedBox(width: 10),
                        ],
                      ),
              ],
              ),
          body: SingleChildScrollView(
                controller: _scrollControllerAppointments,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Earnings'.tr,
                        style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'medium',
                            color: ThemeProvider.blackColor),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl(
                          groupValue: value.segmentedControlGroupValue,
                          children: myTabs,
                          thumbColor: ThemeProvider.appColor,
                          onValueChanged: (i) {
                            value.updateSegments(i as int);
                          }),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 260,
                      child: IndexedStack(
                        index: value.segmentedControlGroupValue.clamp(0, 2),
                        children: [
                          _stableChart(
                            ready: value.dailyApiCalled,
                            chart: _buildChart(),
                          ),
                          _stableChart(
                            ready: value.monthlyApiCalled,
                            chart: _buildChartForMonths(),
                          ),
                          _stableChart(
                            ready: value.yearlyApiCalled,
                            chart: _buildChartForYearly(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    value.segmentedControlGroupValue == 0
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        value.backMonth();
                                      },
                                      icon: const Icon(Icons.chevron_left)),
                                  Text(value.getName()),
                                  IconButton(
                                      onPressed: () {
                                        value.nextMonth();
                                      },
                                      icon: const Icon(Icons.chevron_right))
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              value.list.isNotEmpty
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              value.currencySide == 'left'
                                                  ? '${value.currencySymbol} ${value.totalPrice}'
                                                  : '${value.totalPrice} ${value.currencySymbol}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: ThemeProvider.appColor,
                                                  fontFamily: 'bold'),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              'Total'.toUpperCase().tr,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: ThemeProvider.appColor,
                                                  fontFamily: 'bold'),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              value.currencySide == 'left'
                                                  ? '${value.currencySymbol} ${value.averagePrice}'
                                                  : '${value.averagePrice} ${value.currencySymbol}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      ThemeProvider.greyColor,
                                                  fontFamily: 'bold'),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              'Average'.toUpperCase().tr,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      ThemeProvider.greyColor,
                                                  fontFamily: 'bold'),
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                height: 20,
                              ),
                              value.list.isNotEmpty
                                  ? Container(
                                      color: ThemeProvider.whiteColor,
                                      width: double.infinity,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columnSpacing: 14,
                                          horizontalMargin: 10,
                                          columns: <DataColumn>[
                                            DataColumn(
                                              label: Text(
                                                'Day'.tr,
                                                style: const TextStyle(
                                                    fontFamily: 'bold',
                                                    fontSize: 10),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Bookings'.tr,
                                                style: const TextStyle(
                                                    fontFamily: 'bold',
                                                    fontSize: 10),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Earnings'.tr,
                                                style: const TextStyle(
                                                    fontFamily: 'bold',
                                                    fontSize: 10),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'COD',
                                                style: const TextStyle(
                                                    fontFamily: 'bold',
                                                    fontSize: 10),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Online',
                                                style: const TextStyle(
                                                    fontFamily: 'bold',
                                                    fontSize: 10),
                                              ),
                                            ),
                                          ],
                                          rows: <DataRow>[
                                            for (var item in value.list)
                                              DataRow(
                                                cells: <DataCell>[
                                                  DataCell(Text(
                                                      style: const TextStyle(
                                                          fontFamily: 'bold',
                                                          fontSize: 11),
                                                      item.dayName.toString())),
                                                  DataCell(Text(
                                                      style: const TextStyle(
                                                          fontFamily: 'bold',
                                                          fontSize: 11),
                                                      item.count.toString())),
                                                  DataCell(Text(
                                                      style: const TextStyle(
                                                          fontFamily: 'bold',
                                                          fontSize: 11),
                                                      value.currencySide ==
                                                              'left'
                                                          ? '${value.currencySymbol} ${item.total}'
                                                          : '${item.total} ${value.currencySymbol}')),
                                                  DataCell(Text(
                                                      style: const TextStyle(
                                                          fontFamily: 'bold',
                                                          fontSize: 11),
                                                      '${value.currencySymbol} ${item.codTotal}'
                                                          .toString())),
                                                  DataCell(Text(
                                                      style: const TextStyle(
                                                          fontFamily: 'bold',
                                                          fontSize: 11),
                                                      '${value.currencySymbol} ${item.onlineTotal}'
                                                          .toString())),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox()
                            ],
                          )
                        : value.segmentedControlGroupValue == 1
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            value.backYear();
                                          },
                                          icon: const Icon(Icons.chevron_left)),
                                      Text(value.currenyYear.toString()),
                                      IconButton(
                                          onPressed: () {
                                            value.nextYear();
                                          },
                                          icon: const Icon(Icons.chevron_right))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  value.monthList.isNotEmpty
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  value.currencySide == 'left'
                                                      ? '${value.currencySymbol} ${value.totalPriceMonth}'
                                                      : '${value.totalPriceMonth} ${value.currencySymbol}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: ThemeProvider
                                                          .appColor,
                                                      fontFamily: 'bold'),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Total'.toUpperCase().tr,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: ThemeProvider
                                                          .appColor,
                                                      fontFamily: 'bold'),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  value.currencySide == 'left'
                                                      ? '${value.currencySymbol} ${value.averagePriceMonth}'
                                                      : '${value.averagePriceMonth} ${value.currencySymbol}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: ThemeProvider
                                                          .greyColor,
                                                      fontFamily: 'bold'),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Average'.toUpperCase().tr,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: ThemeProvider
                                                          .greyColor,
                                                      fontFamily: 'bold'),
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  value.monthList.isNotEmpty
                                      ? Container(
                                          color: ThemeProvider.whiteColor,
                                          width: double.infinity,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                              columnSpacing: 14,
                                              horizontalMargin: 10,
                                              columns: <DataColumn>[
                                                DataColumn(
                                                  label: Text(
                                                    'Months'.tr,
                                                    style: const TextStyle(
                                                        fontFamily: 'bold',
                                                        fontSize: 10),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Bookings'.tr,
                                                    style: const TextStyle(
                                                        fontFamily: 'bold',
                                                        fontSize: 10),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Earnings'.tr,
                                                    style: const TextStyle(
                                                        fontFamily: 'bold',
                                                        fontSize: 10),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'COD',
                                                    style: const TextStyle(
                                                        fontFamily: 'bold',
                                                        fontSize: 10),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Online',
                                                    style: const TextStyle(
                                                        fontFamily: 'bold',
                                                        fontSize: 10),
                                                  ),
                                                ),
                                              ],
                                              rows: <DataRow>[
                                                for (var item
                                                    in value.monthList)
                                                  DataRow(
                                                    cells: <DataCell>[
                                                      DataCell(Text(
                                                          style:
                                                              const TextStyle(
                                                                  fontFamily:
                                                                      'bold',
                                                                  fontSize: 11),
                                                          value.monthsListNames[
                                                              (item.dayName
                                                                      as int) -
                                                                  1])),
                                                      DataCell(Text(
                                                          style:
                                                              const TextStyle(
                                                                  fontFamily:
                                                                      'bold',
                                                                  fontSize: 11),
                                                          item.count
                                                              .toString())),
                                                      DataCell(Text(
                                                          style:
                                                              const TextStyle(
                                                                  fontFamily:
                                                                      'bold',
                                                                  fontSize: 11),
                                                          value.currencySide ==
                                                                  'left'
                                                              ? '${value.currencySymbol} ${item.total}'
                                                              : '${item.total} ${value.currencySymbol}')),
                                                      DataCell(Text(
                                                          style:
                                                              const TextStyle(
                                                                  fontFamily:
                                                                      'bold',
                                                                  fontSize: 11),
                                                          '${value.currencySymbol} ${item.codTotal}'
                                                              .toString())),
                                                      DataCell(Text(
                                                          style:
                                                              const TextStyle(
                                                                  fontFamily:
                                                                      'bold',
                                                                  fontSize: 11),
                                                          '${value.currencySymbol} ${item.onlineTotal}'
                                                              .toString())),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : const SizedBox()
                                ],
                              )
                            : Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  value.yearlyList.isNotEmpty
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  value.currencySide == 'left'
                                                      ? '${value.currencySymbol} ${value.totalPriceYearly}'
                                                      : '${value.totalPriceYearly} ${value.currencySymbol}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: ThemeProvider
                                                          .appColor,
                                                      fontFamily: 'bold'),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Total'.toUpperCase().tr,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: ThemeProvider
                                                          .appColor,
                                                      fontFamily: 'bold'),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  value.currencySide == 'left'
                                                      ? '${value.currencySymbol} ${value.averagePriceYearly}'
                                                      : '${value.averagePriceYearly} ${value.currencySymbol}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: ThemeProvider
                                                          .greyColor,
                                                      fontFamily: 'bold'),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Average'.toUpperCase().tr,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: ThemeProvider
                                                          .greyColor,
                                                      fontFamily: 'bold'),
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  value.yearlyList.isNotEmpty
                                      ? Container(
                                          color: ThemeProvider.whiteColor,
                                          width: double.infinity,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                              columnSpacing: 14,
                                              horizontalMargin: 10,
                                              columns: <DataColumn>[
                                                DataColumn(
                                                  label: Text(
                                                    'Years'.tr,
                                                    style: const TextStyle(
                                                        fontFamily: 'bold',
                                                        fontSize: 10),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Bookings'.tr,
                                                    style: const TextStyle(
                                                        fontFamily: 'bold',
                                                        fontSize: 10),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Earnings'.tr,
                                                    style: const TextStyle(
                                                        fontFamily: 'bold',
                                                        fontSize: 10),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'COD',
                                                    style: const TextStyle(
                                                        fontFamily: 'bold',
                                                        fontSize: 10),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Online',
                                                    style: const TextStyle(
                                                        fontFamily: 'bold',
                                                        fontSize: 10),
                                                  ),
                                                ),
                                              ],
                                              rows: <DataRow>[
                                                for (var item
                                                    in value.yearlyList)
                                                  DataRow(
                                                    cells: <DataCell>[
                                                      DataCell(Text(
                                                          style:
                                                              const TextStyle(
                                                                  fontFamily:
                                                                      'bold',
                                                                  fontSize: 11),
                                                          item.dayName
                                                              .toString())),
                                                      DataCell(Text(
                                                          style:
                                                              const TextStyle(
                                                                  fontFamily:
                                                                      'bold',
                                                                  fontSize: 11),
                                                          item.count
                                                              .toString())),
                                                      DataCell(Text(
                                                          style:
                                                              const TextStyle(
                                                                  fontFamily:
                                                                      'bold',
                                                                  fontSize: 11),
                                                          value.currencySide ==
                                                                  'left'
                                                              ? '${value.currencySymbol} ${item.total}'
                                                              : '${item.total} ${value.currencySymbol}')),
                                                      DataCell(Text(
                                                          style:
                                                              const TextStyle(
                                                                  fontFamily:
                                                                      'bold',
                                                                  fontSize: 11),
                                                          '${value.currencySymbol} ${item.codTotal}'
                                                              .toString())),
                                                      DataCell(Text(
                                                          style:
                                                              const TextStyle(
                                                                  fontFamily:
                                                                      'bold',
                                                                  fontSize: 11),
                                                          '${value.currencySymbol} ${item.onlineTotal}'
                                                              .toString())),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : const SizedBox()
                                ],
                              )
                  ],
                ),
              ),
// PRODUCT HIDDEN               SingleChildScrollView(
// PRODUCT HIDDEN                 controller: _scrollControllerProducts,
// PRODUCT HIDDEN                 padding: const EdgeInsets.all(10),
// PRODUCT HIDDEN                 child: Column(
// PRODUCT HIDDEN                   children: [
// PRODUCT HIDDEN                     Container(
// PRODUCT HIDDEN                       alignment: Alignment.topLeft,
// PRODUCT HIDDEN                       child: Text(
// PRODUCT HIDDEN                         'Earnings'.tr,
// PRODUCT HIDDEN                         style: const TextStyle(
// PRODUCT HIDDEN                             fontSize: 18,
// PRODUCT HIDDEN                             fontFamily: 'medium',
// PRODUCT HIDDEN                             color: ThemeProvider.blackColor),
// PRODUCT HIDDEN                       ),
// PRODUCT HIDDEN                     ),
// PRODUCT HIDDEN                     const SizedBox(height: 20),
// PRODUCT HIDDEN                     SizedBox(
// PRODUCT HIDDEN                       width: double.infinity,
// PRODUCT HIDDEN                       child: CupertinoSlidingSegmentedControl(
// PRODUCT HIDDEN                           groupValue: value.segmentedControlGroupValueProducts,
// PRODUCT HIDDEN                           children: myTabsProducts,
// PRODUCT HIDDEN                           thumbColor: ThemeProvider.appColor,
// PRODUCT HIDDEN                           onValueChanged: (i) {
// PRODUCT HIDDEN                             value.updateSegmentsProducts(i as int);
// PRODUCT HIDDEN                           }),
// PRODUCT HIDDEN                     ),
// PRODUCT HIDDEN                     const SizedBox(height: 20),
// PRODUCT HIDDEN                     value.segmentedControlGroupValueProducts == 0
// PRODUCT HIDDEN                         ? Column(
// PRODUCT HIDDEN                             mainAxisAlignment: MainAxisAlignment.start,
// PRODUCT HIDDEN                             children: [
// PRODUCT HIDDEN                               Row(
// PRODUCT HIDDEN                                 mainAxisAlignment:
// PRODUCT HIDDEN                                     MainAxisAlignment.spaceBetween,
// PRODUCT HIDDEN                                 crossAxisAlignment: CrossAxisAlignment.center,
// PRODUCT HIDDEN                                 children: [
// PRODUCT HIDDEN                                   IconButton(
// PRODUCT HIDDEN                                       onPressed: () {
// PRODUCT HIDDEN                                         value.backMonthProducts();
// PRODUCT HIDDEN                                       },
// PRODUCT HIDDEN                                       icon: const Icon(Icons.chevron_left)),
// PRODUCT HIDDEN                                   Text(value.getNameProducts()),
// PRODUCT HIDDEN                                   IconButton(
// PRODUCT HIDDEN                                       onPressed: () {
// PRODUCT HIDDEN                                         value.nextMonthProducts();
// PRODUCT HIDDEN                                       },
// PRODUCT HIDDEN                                       icon: const Icon(Icons.chevron_right))
// PRODUCT HIDDEN                                 ],
// PRODUCT HIDDEN                               ),
// PRODUCT HIDDEN                               const SizedBox(
// PRODUCT HIDDEN                                 height: 20,
// PRODUCT HIDDEN                               ),
// PRODUCT HIDDEN                               value.dailyApiCalledProducts == true
// PRODUCT HIDDEN                                   ? _buildChartProducts()
// PRODUCT HIDDEN                                   : const Center(
// PRODUCT HIDDEN                                       child: CircularProgressIndicator(
// PRODUCT HIDDEN                                         color: ThemeProvider.appColor,
// PRODUCT HIDDEN                                       ),
// PRODUCT HIDDEN                                     ),
// PRODUCT HIDDEN                               const SizedBox(
// PRODUCT HIDDEN                                 height: 20,
// PRODUCT HIDDEN                               ),
// PRODUCT HIDDEN                               value.listProducts.isNotEmpty
// PRODUCT HIDDEN                                   ? Row(
// PRODUCT HIDDEN                                       mainAxisAlignment:
// PRODUCT HIDDEN                                           MainAxisAlignment.start,
// PRODUCT HIDDEN                                       crossAxisAlignment:
// PRODUCT HIDDEN                                           CrossAxisAlignment.start,
// PRODUCT HIDDEN                                       children: [
// PRODUCT HIDDEN                                         Column(
// PRODUCT HIDDEN                                           mainAxisAlignment:
// PRODUCT HIDDEN                                               MainAxisAlignment.start,
// PRODUCT HIDDEN                                           crossAxisAlignment:
// PRODUCT HIDDEN                                               CrossAxisAlignment.start,
// PRODUCT HIDDEN                                           children: [
// PRODUCT HIDDEN                                             Text(
// PRODUCT HIDDEN                                               value.currencySide == 'left'
// PRODUCT HIDDEN                                                   ? '${value.currencySymbol} ${value.totalPriceProducts}'
// PRODUCT HIDDEN                                                   : '${value.totalPriceProducts} ${value.currencySymbol}',
// PRODUCT HIDDEN                                               style: const TextStyle(
// PRODUCT HIDDEN                                                   fontSize: 14,
// PRODUCT HIDDEN                                                   color: ThemeProvider.appColor,
// PRODUCT HIDDEN                                                   fontFamily: 'bold'),
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                             const SizedBox(
// PRODUCT HIDDEN                                               height: 5,
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                             Text(
// PRODUCT HIDDEN                                               'Total'.toUpperCase().tr,
// PRODUCT HIDDEN                                               style: const TextStyle(
// PRODUCT HIDDEN                                                   fontSize: 12,
// PRODUCT HIDDEN                                                   color: ThemeProvider.appColor,
// PRODUCT HIDDEN                                                   fontFamily: 'bold'),
// PRODUCT HIDDEN                                             )
// PRODUCT HIDDEN                                           ],
// PRODUCT HIDDEN                                         ),
// PRODUCT HIDDEN                                         const SizedBox(
// PRODUCT HIDDEN                                           width: 20,
// PRODUCT HIDDEN                                         ),
// PRODUCT HIDDEN                                         Column(
// PRODUCT HIDDEN                                           mainAxisAlignment:
// PRODUCT HIDDEN                                               MainAxisAlignment.start,
// PRODUCT HIDDEN                                           crossAxisAlignment:
// PRODUCT HIDDEN                                               CrossAxisAlignment.start,
// PRODUCT HIDDEN                                           children: [
// PRODUCT HIDDEN                                             Text(
// PRODUCT HIDDEN                                               value.currencySide == 'left'
// PRODUCT HIDDEN                                                   ? '${value.currencySymbol} ${value.averagePriceProducts}'
// PRODUCT HIDDEN                                                   : '${value.averagePriceProducts} ${value.currencySymbol}',
// PRODUCT HIDDEN                                               style: const TextStyle(
// PRODUCT HIDDEN                                                   fontSize: 14,
// PRODUCT HIDDEN                                                   color:
// PRODUCT HIDDEN                                                       ThemeProvider.greyColor,
// PRODUCT HIDDEN                                                   fontFamily: 'bold'),
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                             const SizedBox(
// PRODUCT HIDDEN                                               height: 5,
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                             Text(
// PRODUCT HIDDEN                                               'Average'.toUpperCase().tr,
// PRODUCT HIDDEN                                               style: const TextStyle(
// PRODUCT HIDDEN                                                   fontSize: 12,
// PRODUCT HIDDEN                                                   color:
// PRODUCT HIDDEN                                                       ThemeProvider.greyColor,
// PRODUCT HIDDEN                                                   fontFamily: 'bold'),
// PRODUCT HIDDEN                                             )
// PRODUCT HIDDEN                                           ],
// PRODUCT HIDDEN                                         ),
// PRODUCT HIDDEN                                       ],
// PRODUCT HIDDEN                                     )
// PRODUCT HIDDEN                                   : const SizedBox(),
// PRODUCT HIDDEN                               const SizedBox(
// PRODUCT HIDDEN                                 height: 20,
// PRODUCT HIDDEN                               ),
// PRODUCT HIDDEN                               value.listProducts.isNotEmpty
// PRODUCT HIDDEN                                   ? Container(
// PRODUCT HIDDEN                                       color: ThemeProvider.whiteColor,
// PRODUCT HIDDEN                                       width: double.infinity,
// PRODUCT HIDDEN                                       child: DataTable(
// PRODUCT HIDDEN                                         columnSpacing: 14,
// PRODUCT HIDDEN                                         horizontalMargin: 10,
// PRODUCT HIDDEN                                         columns: <DataColumn>[
// PRODUCT HIDDEN                                           DataColumn(
// PRODUCT HIDDEN                                             label: Text(
// PRODUCT HIDDEN                                               'Day'.tr,
// PRODUCT HIDDEN                                               style: const TextStyle(
// PRODUCT HIDDEN                                                   fontFamily: 'bold',
// PRODUCT HIDDEN                                                   fontSize: 10),
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                           ),
// PRODUCT HIDDEN                                           DataColumn(
// PRODUCT HIDDEN                                             label: Text(
// PRODUCT HIDDEN                                               'Orders'.tr,
// PRODUCT HIDDEN                                               style: const TextStyle(
// PRODUCT HIDDEN                                                   fontFamily: 'bold',
// PRODUCT HIDDEN                                                   fontSize: 10),
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                           ),
// PRODUCT HIDDEN                                           DataColumn(
// PRODUCT HIDDEN                                             label: Text(
// PRODUCT HIDDEN                                               'Earnings'.tr,
// PRODUCT HIDDEN                                               style: const TextStyle(
// PRODUCT HIDDEN                                                   fontFamily: 'bold',
// PRODUCT HIDDEN                                                   fontSize: 10),
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                           ),
// PRODUCT HIDDEN                                           DataColumn(
// PRODUCT HIDDEN                                             label: Text(
// PRODUCT HIDDEN                                               'COD',
// PRODUCT HIDDEN                                               style: const TextStyle(
// PRODUCT HIDDEN                                                   fontFamily: 'bold',
// PRODUCT HIDDEN                                                   fontSize: 10),
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                           ),
                                          // 1st column
// PRODUCT HIDDEN                                           DataColumn(
// PRODUCT HIDDEN                                             label: Text(
// PRODUCT HIDDEN                                               'Online',
// PRODUCT HIDDEN                                               style: const TextStyle(
// PRODUCT HIDDEN                                                   fontFamily: 'bold',
// PRODUCT HIDDEN                                                   fontSize: 10),
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                           ),
// PRODUCT HIDDEN                                         ],
// PRODUCT HIDDEN                                         rows: <DataRow>[
// PRODUCT HIDDEN                                           for (var item in value.listProducts)
// PRODUCT HIDDEN                                             DataRow(
// PRODUCT HIDDEN                                               cells: <DataCell>[
// PRODUCT HIDDEN                                                 DataCell(Text(
// PRODUCT HIDDEN                                                     item.dayName.toString())),
// PRODUCT HIDDEN                                                 DataCell(Text(
// PRODUCT HIDDEN                                                     style: const TextStyle(
// PRODUCT HIDDEN                                                         fontFamily: 'bold',
// PRODUCT HIDDEN                                                         fontSize: 11),
// PRODUCT HIDDEN                                                     item.count.toString())),
// PRODUCT HIDDEN                                                 DataCell(Text(
// PRODUCT HIDDEN                                                     style: const TextStyle(
// PRODUCT HIDDEN                                                         fontFamily: 'bold',
// PRODUCT HIDDEN                                                         fontSize: 11),
// PRODUCT HIDDEN                                                     value.currencySide == 'left'
// PRODUCT HIDDEN                                                         ? '${value.currencySymbol} ${item.total}'
// PRODUCT HIDDEN                                                         : '${item.total} ${value.currencySymbol}')),
// PRODUCT HIDDEN                                                 DataCell(Text(
// PRODUCT HIDDEN                                                     style: const TextStyle(
// PRODUCT HIDDEN                                                         fontFamily: 'bold',
// PRODUCT HIDDEN                                                         fontSize: 11),
// PRODUCT HIDDEN                                                     '${value.currencySymbol} ${item.codTotal}'
// PRODUCT HIDDEN                                                         .toString())),
// PRODUCT HIDDEN                                                 DataCell(Text(
// PRODUCT HIDDEN                                                     style: const TextStyle(
// PRODUCT HIDDEN                                                         fontFamily: 'bold',
// PRODUCT HIDDEN                                                         fontSize: 11),
// PRODUCT HIDDEN                                                     '${value.currencySymbol} ${item.onlineTotal}'
// PRODUCT HIDDEN                                                         .toString())),
// PRODUCT HIDDEN                                               ],
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                         ],
// PRODUCT HIDDEN                                       ),
// PRODUCT HIDDEN                                     )
// PRODUCT HIDDEN                                   : const SizedBox()
// PRODUCT HIDDEN                             ],
// PRODUCT HIDDEN                           )
// PRODUCT HIDDEN                         : value.segmentedControlGroupValueProducts == 1
// PRODUCT HIDDEN                             ? Column(
// PRODUCT HIDDEN                                 mainAxisAlignment: MainAxisAlignment.start,
// PRODUCT HIDDEN                                 children: [
// PRODUCT HIDDEN                                   Row(
// PRODUCT HIDDEN                                     mainAxisAlignment:
// PRODUCT HIDDEN                                         MainAxisAlignment.spaceBetween,
// PRODUCT HIDDEN                                     crossAxisAlignment:
// PRODUCT HIDDEN                                         CrossAxisAlignment.center,
// PRODUCT HIDDEN                                     children: [
// PRODUCT HIDDEN                                       IconButton(
// PRODUCT HIDDEN                                           onPressed: () {
// PRODUCT HIDDEN                                             value.backYearProducts();
// PRODUCT HIDDEN                                           },
// PRODUCT HIDDEN                                           icon: const Icon(Icons.chevron_left)),
// PRODUCT HIDDEN                                       Text(
// PRODUCT HIDDEN                                           value.currenyYearProducts.toString()),
// PRODUCT HIDDEN                                       IconButton(
// PRODUCT HIDDEN                                           onPressed: () {
// PRODUCT HIDDEN                                             value.nextYearProducts();
// PRODUCT HIDDEN                                           },
// PRODUCT HIDDEN                                           icon: const Icon(Icons.chevron_right))
// PRODUCT HIDDEN                                     ],
// PRODUCT HIDDEN                                   ),
// PRODUCT HIDDEN                                   const SizedBox(
// PRODUCT HIDDEN                                     height: 20,
// PRODUCT HIDDEN                                   ),
// PRODUCT HIDDEN                                   value.monthlyApiCalledProducts == true
// PRODUCT HIDDEN                                       ? _buildChartForMonthsProducts()
// PRODUCT HIDDEN                                       : const Center(
// PRODUCT HIDDEN                                           child: CircularProgressIndicator(
// PRODUCT HIDDEN                                             color: ThemeProvider.appColor,
// PRODUCT HIDDEN                                           ),
// PRODUCT HIDDEN                                         ),
// PRODUCT HIDDEN                                   value.monthListProducts.isNotEmpty
// PRODUCT HIDDEN                                       ? Row(
// PRODUCT HIDDEN                                           mainAxisAlignment:
// PRODUCT HIDDEN                                               MainAxisAlignment.start,
// PRODUCT HIDDEN                                           crossAxisAlignment:
// PRODUCT HIDDEN                                               CrossAxisAlignment.start,
// PRODUCT HIDDEN                                           children: [
// PRODUCT HIDDEN                                             Column(
// PRODUCT HIDDEN                                               mainAxisAlignment:
// PRODUCT HIDDEN                                                   MainAxisAlignment.start,
// PRODUCT HIDDEN                                               crossAxisAlignment:
// PRODUCT HIDDEN                                                   CrossAxisAlignment.start,
// PRODUCT HIDDEN                                               children: [
// PRODUCT HIDDEN                                                 Text(
// PRODUCT HIDDEN                                                   value.currencySide == 'left'
// PRODUCT HIDDEN                                                       ? '${value.currencySymbol} ${value.totalPriceMonthProducts}'
// PRODUCT HIDDEN                                                       : '${value.totalPriceMonthProducts} ${value.currencySymbol}',
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontSize: 14,
// PRODUCT HIDDEN                                                       color: ThemeProvider
// PRODUCT HIDDEN                                                           .appColor,
// PRODUCT HIDDEN                                                       fontFamily: 'bold'),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                                 const SizedBox(
// PRODUCT HIDDEN                                                   height: 5,
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                                 Text(
// PRODUCT HIDDEN                                                   'Total'.toUpperCase().tr,
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontSize: 12,
// PRODUCT HIDDEN                                                       color: ThemeProvider
// PRODUCT HIDDEN                                                           .appColor,
// PRODUCT HIDDEN                                                       fontFamily: 'bold'),
// PRODUCT HIDDEN                                                 )
// PRODUCT HIDDEN                                               ],
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                             const SizedBox(
// PRODUCT HIDDEN                                               width: 20,
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                             Column(
// PRODUCT HIDDEN                                               mainAxisAlignment:
// PRODUCT HIDDEN                                                   MainAxisAlignment.start,
// PRODUCT HIDDEN                                               crossAxisAlignment:
// PRODUCT HIDDEN                                                   CrossAxisAlignment.start,
// PRODUCT HIDDEN                                               children: [
// PRODUCT HIDDEN                                                 Text(
// PRODUCT HIDDEN                                                   value.currencySide == 'left'
// PRODUCT HIDDEN                                                       ? '${value.currencySymbol} ${value.averagePriceMonthProducts}'
// PRODUCT HIDDEN                                                       : '${value.averagePriceMonthProducts} ${value.currencySymbol}',
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontSize: 14,
// PRODUCT HIDDEN                                                       color: ThemeProvider
// PRODUCT HIDDEN                                                           .greyColor,
// PRODUCT HIDDEN                                                       fontFamily: 'bold'),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                                 const SizedBox(
// PRODUCT HIDDEN                                                   height: 5,
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                                 Text(
// PRODUCT HIDDEN                                                   'Average'.toUpperCase().tr,
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontSize: 12,
// PRODUCT HIDDEN                                                       color: ThemeProvider
// PRODUCT HIDDEN                                                           .greyColor,
// PRODUCT HIDDEN                                                       fontFamily: 'bold'),
// PRODUCT HIDDEN                                                 )
// PRODUCT HIDDEN                                               ],
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                           ],
// PRODUCT HIDDEN                                         )
// PRODUCT HIDDEN                                       : const SizedBox(),
// PRODUCT HIDDEN                                   const SizedBox(
// PRODUCT HIDDEN                                     height: 20,
// PRODUCT HIDDEN                                   ),
// PRODUCT HIDDEN                                   value.monthListProducts.isNotEmpty
// PRODUCT HIDDEN                                       ? Container(
// PRODUCT HIDDEN                                           color: ThemeProvider.whiteColor,
// PRODUCT HIDDEN                                           width: double.infinity,
// PRODUCT HIDDEN                                           child: DataTable(
// PRODUCT HIDDEN                                             columnSpacing: 14,
// PRODUCT HIDDEN                                             horizontalMargin: 10,
// PRODUCT HIDDEN                                             columns: <DataColumn>[
// PRODUCT HIDDEN                                               DataColumn(
// PRODUCT HIDDEN                                                 label: Text(
// PRODUCT HIDDEN                                                   'Months'.tr,
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontFamily: 'bold',
// PRODUCT HIDDEN                                                       fontSize: 10),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                               ),
// PRODUCT HIDDEN                                               DataColumn(
// PRODUCT HIDDEN                                                 label: Text(
// PRODUCT HIDDEN                                                   'Orders'.tr,
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontFamily: 'bold',
// PRODUCT HIDDEN                                                       fontSize: 10),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                               ),
// PRODUCT HIDDEN                                               DataColumn(
// PRODUCT HIDDEN                                                 label: Text(
// PRODUCT HIDDEN                                                   'Earnings'.tr,
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontFamily: 'bold',
// PRODUCT HIDDEN                                                       fontSize: 10),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                               ),
// PRODUCT HIDDEN                                               DataColumn(
// PRODUCT HIDDEN                                                 label: Text(
// PRODUCT HIDDEN                                                   'COD',
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontFamily: 'bold',
// PRODUCT HIDDEN                                                       fontSize: 10),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                               ),
// PRODUCT HIDDEN                                               DataColumn(
// PRODUCT HIDDEN                                                 label: Text(
// PRODUCT HIDDEN                                                   'Online',
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontFamily: 'bold',
// PRODUCT HIDDEN                                                       fontSize: 10),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                               )
// PRODUCT HIDDEN                                             ],
// PRODUCT HIDDEN                                             rows: <DataRow>[
// PRODUCT HIDDEN                                               for (var item
// PRODUCT HIDDEN                                                   in value.monthListProducts)
// PRODUCT HIDDEN                                                 DataRow(
// PRODUCT HIDDEN                                                   cells: <DataCell>[
// PRODUCT HIDDEN                                                     DataCell(Text(value
// PRODUCT HIDDEN                                                             .monthsListNames[
// PRODUCT HIDDEN                                                         (item.dayName as int) -
// PRODUCT HIDDEN                                                             1])),
// PRODUCT HIDDEN                                                     DataCell(Text(
// PRODUCT HIDDEN                                                         style: const TextStyle(
// PRODUCT HIDDEN                                                             fontFamily: 'bold',
// PRODUCT HIDDEN                                                             fontSize: 11),
// PRODUCT HIDDEN                                                         item.count.toString())),
// PRODUCT HIDDEN                                                     DataCell(Text(
// PRODUCT HIDDEN                                                         style: const TextStyle(
// PRODUCT HIDDEN                                                             fontFamily: 'bold',
// PRODUCT HIDDEN                                                             fontSize: 11),
// PRODUCT HIDDEN                                                         value.currencySide ==
// PRODUCT HIDDEN                                                                 'left'
// PRODUCT HIDDEN                                                             ? '${value.currencySymbol} ${item.total}'
// PRODUCT HIDDEN                                                             : '${item.total} ${value.currencySymbol}')),
// PRODUCT HIDDEN                                                     DataCell(Text(
// PRODUCT HIDDEN                                                         style: const TextStyle(
// PRODUCT HIDDEN                                                             fontFamily: 'bold',
// PRODUCT HIDDEN                                                             fontSize: 11),
// PRODUCT HIDDEN                                                         '${value.currencySymbol} ${item.codTotal}'
// PRODUCT HIDDEN                                                             .toString())),
// PRODUCT HIDDEN                                                     DataCell(Text(
// PRODUCT HIDDEN                                                         style: const TextStyle(
// PRODUCT HIDDEN                                                             fontFamily: 'bold',
// PRODUCT HIDDEN                                                             fontSize: 11),
// PRODUCT HIDDEN                                                         '${value.currencySymbol} ${item.onlineTotal}'
// PRODUCT HIDDEN                                                             .toString())),
// PRODUCT HIDDEN                                                   ],
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                             ],
// PRODUCT HIDDEN                                           ),
// PRODUCT HIDDEN                                         )
// PRODUCT HIDDEN                                       : const SizedBox()
// PRODUCT HIDDEN                                 ],
// PRODUCT HIDDEN                               )
// PRODUCT HIDDEN                             : Column(
// PRODUCT HIDDEN                                 children: [
// PRODUCT HIDDEN                                   const SizedBox(
// PRODUCT HIDDEN                                     height: 20,
// PRODUCT HIDDEN                                   ),
// PRODUCT HIDDEN                                   value.yearlyApiCalledProducts == true
// PRODUCT HIDDEN                                       ? _buildChartForYearlyProducts()
// PRODUCT HIDDEN                                       : const Center(
// PRODUCT HIDDEN                                           child: CircularProgressIndicator(
// PRODUCT HIDDEN                                             color: ThemeProvider.appColor,
// PRODUCT HIDDEN                                           ),
// PRODUCT HIDDEN                                         ),
// PRODUCT HIDDEN                                   value.yearlyListProducts.isNotEmpty
// PRODUCT HIDDEN                                       ? Row(
// PRODUCT HIDDEN                                           mainAxisAlignment:
// PRODUCT HIDDEN                                               MainAxisAlignment.start,
// PRODUCT HIDDEN                                           crossAxisAlignment:
// PRODUCT HIDDEN                                               CrossAxisAlignment.start,
// PRODUCT HIDDEN                                           children: [
// PRODUCT HIDDEN                                             Column(
// PRODUCT HIDDEN                                               mainAxisAlignment:
// PRODUCT HIDDEN                                                   MainAxisAlignment.start,
// PRODUCT HIDDEN                                               crossAxisAlignment:
// PRODUCT HIDDEN                                                   CrossAxisAlignment.start,
// PRODUCT HIDDEN                                               children: [
// PRODUCT HIDDEN                                                 Text(
// PRODUCT HIDDEN                                                   value.currencySide == 'left'
// PRODUCT HIDDEN                                                       ? '${value.currencySymbol} ${value.totalPriceYearlyProducts}'
// PRODUCT HIDDEN                                                       : '${value.totalPriceYearlyProducts} ${value.currencySymbol}',
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontSize: 14,
// PRODUCT HIDDEN                                                       color: ThemeProvider
// PRODUCT HIDDEN                                                           .appColor,
// PRODUCT HIDDEN                                                       fontFamily: 'bold'),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                                 const SizedBox(
// PRODUCT HIDDEN                                                   height: 5,
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                                 Text(
// PRODUCT HIDDEN                                                   'Total'.toUpperCase().tr,
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontSize: 12,
// PRODUCT HIDDEN                                                       color: ThemeProvider
// PRODUCT HIDDEN                                                           .appColor,
// PRODUCT HIDDEN                                                       fontFamily: 'bold'),
// PRODUCT HIDDEN                                                 )
// PRODUCT HIDDEN                                               ],
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                             const SizedBox(
// PRODUCT HIDDEN                                               width: 20,
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                             Column(
// PRODUCT HIDDEN                                               mainAxisAlignment:
// PRODUCT HIDDEN                                                   MainAxisAlignment.start,
// PRODUCT HIDDEN                                               crossAxisAlignment:
// PRODUCT HIDDEN                                                   CrossAxisAlignment.start,
// PRODUCT HIDDEN                                               children: [
// PRODUCT HIDDEN                                                 Text(
// PRODUCT HIDDEN                                                   value.currencySide == 'left'
// PRODUCT HIDDEN                                                       ? '${value.currencySymbol} ${value.averagePriceYearlyProducts}'
// PRODUCT HIDDEN                                                       : '${value.averagePriceYearlyProducts} ${value.currencySymbol}',
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontSize: 14,
// PRODUCT HIDDEN                                                       color: ThemeProvider
// PRODUCT HIDDEN                                                           .greyColor,
// PRODUCT HIDDEN                                                       fontFamily: 'bold'),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                                 const SizedBox(
// PRODUCT HIDDEN                                                   height: 5,
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                                 Text(
// PRODUCT HIDDEN                                                   'Average'.toUpperCase().tr,
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontSize: 12,
// PRODUCT HIDDEN                                                       color: ThemeProvider
// PRODUCT HIDDEN                                                           .greyColor,
// PRODUCT HIDDEN                                                       fontFamily: 'bold'),
// PRODUCT HIDDEN                                                 )
// PRODUCT HIDDEN                                               ],
// PRODUCT HIDDEN                                             ),
// PRODUCT HIDDEN                                           ],
// PRODUCT HIDDEN                                         )
// PRODUCT HIDDEN                                       : const SizedBox(),
// PRODUCT HIDDEN                                   const SizedBox(
// PRODUCT HIDDEN                                     height: 20,
// PRODUCT HIDDEN                                   ),
// PRODUCT HIDDEN                                   value.yearlyListProducts.isNotEmpty
// PRODUCT HIDDEN                                       ? Container(
// PRODUCT HIDDEN                                           color: ThemeProvider.whiteColor,
// PRODUCT HIDDEN                                           width: double.infinity,
// PRODUCT HIDDEN                                           child: DataTable(
// PRODUCT HIDDEN                                             columnSpacing: 14,
// PRODUCT HIDDEN                                             horizontalMargin: 10,
// PRODUCT HIDDEN                                             columns: <DataColumn>[
// PRODUCT HIDDEN                                               DataColumn(
// PRODUCT HIDDEN                                                 label: Text(
// PRODUCT HIDDEN                                                   'Years'.tr,
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontFamily: 'bold',
// PRODUCT HIDDEN                                                       fontSize: 10),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                               ),
// PRODUCT HIDDEN                                               DataColumn(
// PRODUCT HIDDEN                                                 label: Text(
// PRODUCT HIDDEN                                                   'Orders'.tr,
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontFamily: 'bold',
// PRODUCT HIDDEN                                                       fontSize: 10),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                               ),
// PRODUCT HIDDEN                                               DataColumn(
// PRODUCT HIDDEN                                                 label: Text(
// PRODUCT HIDDEN                                                   'Earnings'.tr,
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontFamily: 'bold',
// PRODUCT HIDDEN                                                       fontSize: 10),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                               ),
// PRODUCT HIDDEN                                               DataColumn(
// PRODUCT HIDDEN                                                 label: Text(
// PRODUCT HIDDEN                                                   'COD',
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontFamily: 'bold',
// PRODUCT HIDDEN                                                       fontSize: 10),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                               ),
// PRODUCT HIDDEN                                               DataColumn(
// PRODUCT HIDDEN                                                 label: Text(
// PRODUCT HIDDEN                                                   'Online',
// PRODUCT HIDDEN                                                   style: const TextStyle(
// PRODUCT HIDDEN                                                       fontFamily: 'bold',
// PRODUCT HIDDEN                                                       fontSize: 10),
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                               )
// PRODUCT HIDDEN                                             ],
// PRODUCT HIDDEN                                             rows: <DataRow>[
// PRODUCT HIDDEN                                               for (var item
// PRODUCT HIDDEN                                                   in value.yearlyListProducts)
// PRODUCT HIDDEN                                                 DataRow(
// PRODUCT HIDDEN                                                   cells: <DataCell>[
// PRODUCT HIDDEN                                                     DataCell(Text(
// PRODUCT HIDDEN                                                         style: const TextStyle(
// PRODUCT HIDDEN                                                             fontFamily: 'bold',
// PRODUCT HIDDEN                                                             fontSize: 11),
// PRODUCT HIDDEN                                                         item.dayName
// PRODUCT HIDDEN                                                             .toString())),
// PRODUCT HIDDEN                                                     DataCell(Text(
// PRODUCT HIDDEN                                                         style: const TextStyle(
// PRODUCT HIDDEN                                                             fontFamily: 'bold',
// PRODUCT HIDDEN                                                             fontSize: 11),
// PRODUCT HIDDEN                                                         item.count.toString())),
// PRODUCT HIDDEN                                                     DataCell(Text(
// PRODUCT HIDDEN                                                         style: const TextStyle(
// PRODUCT HIDDEN                                                             fontFamily: 'bold',
// PRODUCT HIDDEN                                                             fontSize: 11),
// PRODUCT HIDDEN                                                         value.currencySide ==
// PRODUCT HIDDEN                                                                 'left'
// PRODUCT HIDDEN                                                             ? '${value.currencySymbol} ${item.total}'
// PRODUCT HIDDEN                                                             : '${item.total} ${value.currencySymbol}')),
// PRODUCT HIDDEN                                                     DataCell(Text(
// PRODUCT HIDDEN                                                         style: const TextStyle(
// PRODUCT HIDDEN                                                             fontFamily: 'bold',
// PRODUCT HIDDEN                                                             fontSize: 11),
// PRODUCT HIDDEN                                                         '${value.currencySymbol} ${item.codTotal}'
// PRODUCT HIDDEN                                                             .toString())),
// PRODUCT HIDDEN                                                     DataCell(Text(
// PRODUCT HIDDEN                                                         style: const TextStyle(
// PRODUCT HIDDEN                                                             fontFamily: 'bold',
// PRODUCT HIDDEN                                                             fontSize: 11),
// PRODUCT HIDDEN                                                         '${value.currencySymbol} ${item.onlineTotal}'
// PRODUCT HIDDEN                                                             .toString())),
// PRODUCT HIDDEN                                                   ],
// PRODUCT HIDDEN                                                 ),
// PRODUCT HIDDEN                                             ],
// PRODUCT HIDDEN                                           ),
// PRODUCT HIDDEN                                         )
// PRODUCT HIDDEN                                       : const SizedBox()
// PRODUCT HIDDEN                                 ],
// PRODUCT HIDDEN                               )
// PRODUCT HIDDEN                   ],
// PRODUCT HIDDEN                 ),
// PRODUCT HIDDEN               )
      );
    });
  }

  Widget _stableChart({required bool ready, required Widget chart}) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        RepaintBoundary(child: chart),
        if (!ready)
          const Center(
            child: CircularProgressIndicator(
              color: ThemeProvider.appColor,
            ),
          ),
      ],
    );
  }

  SfCartesianChart _buildChart() {
    return SfCartesianChart(
      key: const ValueKey('analytics-daily-chart'),
      plotAreaBorderWidth: 0,
      enableAxisAnimation: false,
      title: ChartTitle(
          text:
              '${'Total number of bookings'.tr} ${Get.find<AnalyticsController>().getName()}',
          textStyle: const TextStyle(fontSize: 10)),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          labelFormat:
              '{value}${Get.find<AnalyticsController>().currencySymbol}',
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getWeekData(),
      tooltipBehavior: _tooltipBehavior,
    );
  }

  SfCartesianChart _buildChartProducts() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      enableAxisAnimation: false,
      title: ChartTitle(
          text:
              '${'Total number of orders'.tr} ${Get.find<AnalyticsController>().getName()}',
          textStyle: const TextStyle(fontSize: 10)),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          labelFormat:
              '{value}${Get.find<AnalyticsController>().currencySymbol}',
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getWeekDataProducts(),
      tooltipBehavior: _tooltipBehavior,
    );
  }

  SfCartesianChart _buildChartForMonths() {
    return SfCartesianChart(
      key: const ValueKey('analytics-monthly-chart'),
      plotAreaBorderWidth: 0,
      enableAxisAnimation: false,
      title: ChartTitle(
          text:
              '${'Total number of bookings'.tr} ${Get.find<AnalyticsController>().currenyYear}',
          textStyle: const TextStyle(fontSize: 10)),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          labelFormat:
              '{value}${Get.find<AnalyticsController>().currencySymbol}',
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getMonthsData(),
      tooltipBehavior: _tooltipBehavior,
    );
  }

  SfCartesianChart _buildChartForMonthsProducts() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      enableAxisAnimation: false,
      title: ChartTitle(
          text:
              '${'Total number of orders'.tr} ${Get.find<AnalyticsController>().currenyYear}',
          textStyle: const TextStyle(fontSize: 10)),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          labelFormat:
              '{value}${Get.find<AnalyticsController>().currencySymbol}',
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getMonthsDataProducts(),
      tooltipBehavior: _tooltipBehavior,
    );
  }

  SfCartesianChart _buildChartForYearly() {
    return SfCartesianChart(
      key: const ValueKey('analytics-yearly-chart'),
      plotAreaBorderWidth: 0,
      enableAxisAnimation: false,
      title: ChartTitle(
          text: 'Total number of bookings'.tr,
          textStyle: const TextStyle(fontSize: 10)),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          labelFormat:
              '{value}${Get.find<AnalyticsController>().currencySymbol}',
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getYearlyData(),
      tooltipBehavior: _tooltipBehavior,
    );
  }

  SfCartesianChart _buildChartForYearlyProducts() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      enableAxisAnimation: false,
      title: ChartTitle(
          text: 'Total number of orders'.tr,
          textStyle: const TextStyle(fontSize: 10)),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          labelFormat:
              '{value}${Get.find<AnalyticsController>().currencySymbol}',
          majorTickLines: const MajorTickLines(size: 0)),
      series: _getYearlyDataProducts(),
      tooltipBehavior: _tooltipBehavior,
    );
  }

  List<ColumnSeries<ChartSampleData, String>> _getWeekData() {
    return <ColumnSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
        animationDuration: 0,
        dataSource: <ChartSampleData>[
          for (var item in Get.find<AnalyticsController>().list)
            ChartSampleData(
                x: item.dayName,
                y: item.total,
                pointColor: ThemeProvider.appColor),
        ],
        xValueMapper: (ChartSampleData sales, _) => sales.x as String,
        yValueMapper: (ChartSampleData sales, _) => sales.y,
        pointColorMapper: (ChartSampleData sales, _) => sales.pointColor,
        dataLabelSettings: const DataLabelSettings(
            isVisible: true, textStyle: TextStyle(fontSize: 10)),
      )
    ];
  }

  List<ColumnSeries<ChartSampleData, String>> _getWeekDataProducts() {
    return <ColumnSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
        animationDuration: 0,
        dataSource: <ChartSampleData>[
          for (var item in Get.find<AnalyticsController>().listProducts)
            ChartSampleData(
                x: item.dayName,
                y: item.total,
                pointColor: ThemeProvider.appColor),
        ],
        xValueMapper: (ChartSampleData sales, _) => sales.x as String,
        yValueMapper: (ChartSampleData sales, _) => sales.y,
        pointColorMapper: (ChartSampleData sales, _) => sales.pointColor,
        dataLabelSettings: const DataLabelSettings(
            isVisible: true, textStyle: TextStyle(fontSize: 10)),
      )
    ];
  }

  List<ColumnSeries<ChartSampleData, String>> _getMonthsData() {
    return <ColumnSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
        animationDuration: 0,
        dataSource: <ChartSampleData>[
          for (var item in Get.find<AnalyticsController>().monthList)
            ChartSampleData(
                x: Get.find<AnalyticsController>().monthsListNames[
                    (item.dayName as int) - 1], // Subtract 1 here
                y: item.total,
                pointColor: ThemeProvider.appColor),
        ],
        xValueMapper: (ChartSampleData sales, _) => sales.x as String,
        yValueMapper: (ChartSampleData sales, _) => sales.y,
        pointColorMapper: (ChartSampleData sales, _) => sales.pointColor,
        dataLabelSettings: const DataLabelSettings(
            isVisible: true, textStyle: TextStyle(fontSize: 10)),
      )
    ];
  }

  List<ColumnSeries<ChartSampleData, String>> _getMonthsDataProducts() {
    return <ColumnSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
        animationDuration: 0,
        dataSource: <ChartSampleData>[
          for (var item in Get.find<AnalyticsController>().monthListProducts)
            ChartSampleData(
                x: Get.find<AnalyticsController>().monthsListNames[
                    (item.dayName as int) - 1], // Subtract 1 here
                y: item.total,
                pointColor: ThemeProvider.appColor),
        ],
        xValueMapper: (ChartSampleData sales, _) => sales.x as String,
        yValueMapper: (ChartSampleData sales, _) => sales.y,
        pointColorMapper: (ChartSampleData sales, _) => sales.pointColor,
        dataLabelSettings: const DataLabelSettings(
            isVisible: true, textStyle: TextStyle(fontSize: 10)),
      )
    ];
  }

  List<ColumnSeries<ChartSampleData, String>> _getYearlyData() {
    return <ColumnSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
        animationDuration: 0,
        dataSource: <ChartSampleData>[
          for (var item in Get.find<AnalyticsController>().yearlyList)
            ChartSampleData(
                x: item.dayName.toString(),
                y: item.total,
                pointColor: ThemeProvider.appColor),
        ],
        xValueMapper: (ChartSampleData sales, _) => sales.x as String,
        yValueMapper: (ChartSampleData sales, _) => sales.y,
        pointColorMapper: (ChartSampleData sales, _) => sales.pointColor,
        dataLabelSettings: const DataLabelSettings(
            isVisible: true, textStyle: TextStyle(fontSize: 10)),
      )
    ];
  }

  List<ColumnSeries<ChartSampleData, String>> _getYearlyDataProducts() {
    return <ColumnSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
        animationDuration: 0,
        dataSource: <ChartSampleData>[
          for (var item in Get.find<AnalyticsController>().yearlyListProducts)
            ChartSampleData(
                x: item.dayName.toString(),
                y: item.total,
                pointColor: ThemeProvider.appColor),
        ],
        xValueMapper: (ChartSampleData sales, _) => sales.x as String,
        yValueMapper: (ChartSampleData sales, _) => sales.y,
        pointColorMapper: (ChartSampleData sales, _) => sales.pointColor,
        dataLabelSettings: const DataLabelSettings(
            isVisible: true, textStyle: TextStyle(fontSize: 10)),
      )
    ];
  }
}

class ChartSampleData {
  /// Holds the datapoint values like x, y, etc.,
  ChartSampleData(
      {this.x,
      this.y,
      this.xValue,
      this.yValue,
      this.secondSeriesYValue,
      this.thirdSeriesYValue,
      this.pointColor,
      this.size,
      this.text,
      this.open,
      this.close,
      this.low,
      this.high,
      this.volume});

  /// Holds x value of the datapoint
  final dynamic x;

  /// Holds y value of the datapoint
  final num? y;

  /// Holds x value of the datapoint
  final dynamic xValue;

  /// Holds y value of the datapoint
  final num? yValue;

  /// Holds y value of the datapoint(for 2nd series)
  final num? secondSeriesYValue;

  /// Holds y value of the datapoint(for 3nd series)
  final num? thirdSeriesYValue;

  /// Holds point color of the datapoint
  final Color? pointColor;

  /// Holds size of the datapoint
  final num? size;

  /// Holds datalabel/text value mapper of the datapoint
  final String? text;

  /// Holds open value of the datapoint
  final num? open;

  /// Holds close value of the datapoint
  final num? close;

  /// Holds low value of the datapoint
  final num? low;

  /// Holds high value of the datapoint
  final num? high;

  /// Holds open value of the datapoint
  final num? volume;
}
