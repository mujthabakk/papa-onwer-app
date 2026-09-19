import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/analytics_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/months_analytics_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/yearly_analytics_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/analytics_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/inbox_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/notification_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/premium_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class AnalyticsController extends GetxController implements GetxService {
  final AnalyticsParser parser;

  int segmentedControlGroupValue = 0;
  int segmentedControlGroupValueProducts = 0;
  String currencySymbol = AppConstants.defaultCurrencySymbol;
  String currencySide = AppConstants.defaultCurrencySide;

  int pickerYear = DateTime.now().year;

  int pickerYearProducts = DateTime.now().year; // products

  List<String> _months = <String>[];
  List<String> get months => _months;

  List<String> _monthsProducts = <String>[]; // products
  List<String> get monthsProducts => _monthsProducts; // products

  bool dailyApiCalled = false;
  bool monthlyApiCalled = false;
  bool yearlyApiCalled = false;

  bool dailyApiCalledProducts = false; // products
  bool monthlyApiCalledProducts = false; // products
  bool yearlyApiCalledProducts = false; // products

  int monthName = Jiffy.now().month;
  int monthNameProducts = Jiffy.now().month; // products
  List<AnalyticsModel> _list = <AnalyticsModel>[];
  List<AnalyticsModel> get list => _list;

  List<AnalyticsModel> _listProducts = <AnalyticsModel>[]; // products
  List<AnalyticsModel> get listProducts => _listProducts; // products

  List<MonthAnalyticsModel> _monthList = <MonthAnalyticsModel>[];
  List<MonthAnalyticsModel> get monthList => _monthList;

  List<MonthAnalyticsModel> _monthListProducts =
      <MonthAnalyticsModel>[]; // products
  List<MonthAnalyticsModel> get monthListProducts =>
      _monthListProducts; // products

  List<YearlyAnalyticsModel> _yearlyList = <YearlyAnalyticsModel>[];
  List<YearlyAnalyticsModel> get yearlyList => _yearlyList;

  List<YearlyAnalyticsModel> _yearlyListProducts =
      <YearlyAnalyticsModel>[]; // products
  List<YearlyAnalyticsModel> get yearlyListProducts =>
      _yearlyListProducts; // products

  List<double> _chartTotal = <double>[];
  List<double> get chartTotal => _chartTotal;

  List<double> _chartTotalProducts = <double>[]; // products
  List<double> get chartTotalProducts => _chartTotalProducts; // products

  List<double> _chartMonthTotal = <double>[];
  List<double> get chartMonthTotal => _chartMonthTotal;

  List<double> _chartMonthTotalProducts = <double>[]; // products
  List<double> get chartMonthTotalProducts =>
      _chartMonthTotalProducts; // products

  List<double> _chartYearlyTotal = <double>[];
  List<double> get chartYearlyTotal => _chartYearlyTotal;

  List<double> _chartYearlyTotalProducts = <double>[]; // products
  List<double> get chartYearlyTotalProducts =>
      _chartYearlyTotalProducts; // products

  String totalPrice = '';
  String averagePrice = '';

  String totalPriceProducts = ''; // products
  String averagePriceProducts = ''; // products

  String totalPriceMonth = '';
  String averagePriceMonth = '';

  String totalPriceMonthProducts = ''; // products
  String averagePriceMonthProducts = ''; // products

  String totalPriceYearly = '';
  String averagePriceYearly = '';

  String totalPriceYearlyProducts = ''; // products
  String averagePriceYearlyProducts = ''; // products

  int currenyYear = Jiffy.now().year;

  @override
  void update([List<Object>? ids, bool condition = true]) {
    if (isClosed) return;
    super.update(ids, condition);
  }

  int currenyYearProducts = Jiffy.now().year; // products

  List<String> monthsListNames = [
    'January'.tr,
    'February'.tr,
    'March'.tr,
    'April'.tr,
    'May'.tr,
    'June'.tr,
    'July'.tr,
    'August'.tr,
    'September'.tr,
    'October'.tr,
    'November'.tr,
    'December'.tr
  ];
  AnalyticsController({required this.parser});

  List<String> generateRowOfMonths(from, to) {
    List<String> months = [];
    for (int i = from; i <= to; i++) {
      DateTime dateTime = DateTime(pickerYear, i, 1);
      months.add('${Jiffy.parseFromDateTime(dateTime).MMM} $pickerYear');
    }
    return months;
  }

  @override
  void onInit() {
    super.onInit();
    currencySymbol = parser.getCurrenySymbol();
    currencySide = parser.getCurrenySide();
    _months = generateRowOfMonths(1, 12);
    _monthsProducts = generateRowOfMonths(1, 12);
    debugPrint(currenyYear.toString());
    dailyApiCalled = false;
    monthlyApiCalled = false;
    yearlyApiCalled = false;

    dailyApiCalledProducts = false;
    monthlyApiCalledProducts = false;
    yearlyApiCalledProducts = false;
    if (!parser.sharedPreferencesManager.hasOwnerSession()) return;
    getStats();
    getStatsProducts(); // products
    getMonthsStats();
    getMonthsStatsProducts(); // products
    getAllStats();
    getAllStatsProducts(); // products
  }

  Future<void> getStats() async {
    debugPrint('month name' + monthName.toString());
    _list = [];
    _chartTotal = [];
    Response response = await parser.getStats(monthName, pickerYear);
    dailyApiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      dynamic body = myMap["data"];
      body.forEach((element) {
        AnalyticsModel data = AnalyticsModel.fromJson(element);
        _list.add(data);
      });

      if (myMap['success'] == true) {
        debugPrint('ok');

        myMap['chart']['total'].forEach((element) {
          _chartTotal.add(double.parse(element.toString()));
        });
        List<double> countTotal = <double>[];

        myMap['chart']['data'].forEach((element) {
          countTotal.add(double.parse(element.toString()));
        });

        double sum = chartTotal.fold(0, (p, c) => p + c);
        double average = sum / countTotal.fold(0, (p, c) => p + c);

        totalPrice = sum.toStringAsFixed(2).toString();
        averagePrice = average.toStringAsFixed(2).toString();

        debugPrint(totalPrice.toString());
        debugPrint(averagePrice.toString());
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getStatsProducts() async {
    debugPrint(monthNameProducts.toString());
    _listProducts = [];
    _chartTotalProducts = [];
    Response response =
        await parser.getStatsProducts(monthNameProducts, pickerYearProducts);
    dailyApiCalledProducts = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      dynamic body = myMap["data"];
      body.forEach((element) {
        AnalyticsModel data = AnalyticsModel.fromJson(element);
        _listProducts.add(data);
      });
      if (myMap['success'] == true) {
        debugPrint('ok');

        myMap['chart']['total'].forEach((element) {
          _chartTotalProducts.add(double.parse(element.toString()));
        });

        List<double> countTotal = <double>[];
        myMap['chart']['data'].forEach((element) {
          countTotal.add(double.parse(element.toString()));
        });

        double sum = chartTotalProducts.fold(0, (p, c) => p + c);
        double average = sum / countTotal.fold(0, (p, c) => p + c);

        totalPriceProducts = sum.toStringAsFixed(2).toString();
        averagePriceProducts = average.toStringAsFixed(2).toString();

        debugPrint(totalPriceProducts.toString());
        debugPrint(averagePriceProducts.toString());
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getMonthsStats() async {
    _monthList = [];
    _chartMonthTotal = [];
    update();
    Response response = await parser.getMonthsStatus(currenyYear);
    monthlyApiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      dynamic body = myMap["data"];
      body.forEach((element) {
        MonthAnalyticsModel data = MonthAnalyticsModel.fromJson(element);
        _monthList.add(data);
      });
      debugPrint('months data');
      debugPrint(monthList.length.toString());
      if (myMap['success'] == true) {
        debugPrint('ok');
        myMap['chart']['total'].forEach((element) {
          _chartMonthTotal.add(double.parse(element.toString()));
        });

        List<double> countTotal = <double>[];
        myMap['chart']['data'].forEach((element) {
          countTotal.add(double.parse(element.toString()));
        });
        double sum = chartMonthTotal.fold(0, (p, c) => p + c);
        double average = sum / countTotal.fold(0, (p, c) => p + c);

        totalPriceMonth = sum.toStringAsFixed(2).toString();
        averagePriceMonth = average.toStringAsFixed(2).toString();

        debugPrint(totalPriceMonth.toString());
        debugPrint(averagePriceMonth.toString());
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getMonthsStatsProducts() async {
    _monthListProducts = [];
    _chartMonthTotalProducts = [];
    update();
    Response response =
        await parser.getMonthsStatusProducts(currenyYearProducts);
    monthlyApiCalledProducts = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      dynamic body = myMap["data"];
      body.forEach((element) {
        MonthAnalyticsModel data = MonthAnalyticsModel.fromJson(element);
        _monthListProducts.add(data);
      });
      debugPrint('months data');
      debugPrint(monthListProducts.length.toString());
      if (myMap['success'] == true) {
        debugPrint('ok');
        myMap['chart']['total'].forEach((element) {
          _chartMonthTotalProducts.add(double.parse(element.toString()));
        });

        List<double> countTotal = <double>[];
        myMap['chart']['data'].forEach((element) {
          countTotal.add(double.parse(element.toString()));
        });

        double sum = chartMonthTotalProducts.fold(0, (p, c) => p + c);
        double average = sum / countTotal.fold(0, (p, c) => p + c);

        totalPriceMonthProducts = sum.toStringAsFixed(2).toString();
        averagePriceMonthProducts = average.toStringAsFixed(2).toString();

        debugPrint(totalPriceMonthProducts.toString());
        debugPrint(averagePriceMonthProducts.toString());
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getAllStats() async {
    _yearlyList = [];
    _chartYearlyTotal = [];
    Response response = await parser.getAllStats();
    yearlyApiCalled = true;
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      dynamic body = myMap["data"];
      body.forEach((element) {
        YearlyAnalyticsModel data = YearlyAnalyticsModel.fromJson(element);
        _yearlyList.add(data);
      });
      debugPrint('months data');
      debugPrint(yearlyList.length.toString());
      if (myMap['success'] == true) {
        debugPrint('ok');
        myMap['chart']['total'].forEach((element) {
          _chartYearlyTotal.add(double.parse(element.toString()));
        });

        List<double> countTotal = <double>[];
        myMap['chart']['data'].forEach((element) {
          countTotal.add(double.parse(element.toString()));
        });

        double sum = _chartYearlyTotal.fold(0, (p, c) => p + c);
        double average = sum / countTotal.fold(0, (p, c) => p + c);

        totalPriceYearly = sum.toStringAsFixed(2).toString();
        averagePriceYearly = average.toStringAsFixed(2).toString();

        debugPrint(totalPriceYearly.toString());
        debugPrint(averagePriceYearly.toString());
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getAllStatsProducts() async {
    _yearlyListProducts = [];
    _chartYearlyTotalProducts = [];
    Response response = await parser.getAllStatsProducts();
    yearlyApiCalledProducts = true;
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      dynamic body = myMap["data"];
      body.forEach((element) {
        YearlyAnalyticsModel data = YearlyAnalyticsModel.fromJson(element);
        _yearlyListProducts.add(data);
      });
      debugPrint('months data');
      debugPrint(yearlyListProducts.length.toString());
      if (myMap['success'] == true) {
        debugPrint('ok');
        myMap['chart']['total'].forEach((element) {
          _chartYearlyTotalProducts.add(double.parse(element.toString()));
        });

        List<double> countTotal = <double>[];
        myMap['chart']['data'].forEach((element) {
          countTotal.add(double.parse(element.toString()));
        });

        double sum = _chartYearlyTotalProducts.fold(0, (p, c) => p + c);
        double average = sum / countTotal.fold(0, (p, c) => p + c);

        totalPriceYearlyProducts = sum.toStringAsFixed(2).toString();
        averagePriceYearlyProducts = average.toStringAsFixed(2).toString();

        debugPrint(totalPriceYearlyProducts.toString());
        debugPrint(averagePriceYearlyProducts.toString());
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void updateSegments(int id) {
    segmentedControlGroupValue = id;
    update();
  }

  void updateSegmentsProducts(int id) {
    segmentedControlGroupValueProducts = id;
    update();
  }

  void backMonth() {
    debugPrint(monthName.toString());
    if (monthName > 1) {
      monthName = monthName - 1;
    } else {
      debugPrint('prev month');
      pickerYear = pickerYear - 1;
      monthName = monthName = 12;
      _months = generateRowOfMonths(1, 12);
    }
    _list = [];
    _chartTotal = [];
    dailyApiCalled = false;
    update();
    getStats();
  }

  void nextMonth() {
    debugPrint(monthName.toString());
    if (monthName == 12) {
      debugPrint('next year');
      pickerYear = pickerYear + 1;
      monthName = monthName = 1;
      _months = generateRowOfMonths(1, 12);
    } else {
      monthName = monthName + 1;
    }
    _list = [];
    _chartTotal = [];
    dailyApiCalled = false;
    update();
    getStats();
  }

  void backMonthProducts() {
    debugPrint(monthNameProducts.toString());
    if (monthName > 1) {
      monthNameProducts = monthNameProducts - 1;
    } else {
      debugPrint('prev month');
      pickerYearProducts = pickerYearProducts - 1;
      monthNameProducts = monthNameProducts = 12;
      _monthsProducts = generateRowOfMonths(1, 12);
    }
    _listProducts = [];
    _chartTotalProducts = [];
    dailyApiCalledProducts = false;
    update();
    getStatsProducts();
  }

  void nextMonthProducts() {
    debugPrint(monthNameProducts.toString());
    if (monthNameProducts == 12) {
      debugPrint('next year');
      pickerYearProducts = pickerYearProducts + 1;
      monthNameProducts = monthNameProducts = 1;
      _monthsProducts = generateRowOfMonths(1, 12);
    } else {
      monthNameProducts = monthNameProducts + 1;
    }
    _listProducts = [];
    _chartTotalProducts = [];
    dailyApiCalledProducts = false;
    update();
    getStatsProducts();
  }

  void backYear() {
    currenyYear = currenyYear - 1;
    monthlyApiCalled = false;
    _monthList = [];
    _chartMonthTotal = [];
    update();
    getMonthsStats();
  }

  void nextYear() {
    currenyYear = currenyYear + 1;
    monthlyApiCalled = false;
    _monthList = [];
    _chartMonthTotal = [];
    update();
    getMonthsStats();
  }

  void backYearProducts() {
    currenyYearProducts = currenyYearProducts - 1;
    monthlyApiCalledProducts = false;
    _monthListProducts = [];
    _chartMonthTotalProducts = [];
    update();
    getMonthsStatsProducts();
  }

  void nextYearProducts() {
    currenyYearProducts = currenyYearProducts + 1;
    monthlyApiCalledProducts = false;
    _monthListProducts = [];
    _chartMonthTotalProducts = [];
    update();
    getMonthsStatsProducts();
  }

  String getName() {
    return months[monthName - 1];
  }

  String getNameProducts() {
    return monthsProducts[monthNameProducts - 1];
  }

  void showDialogScreen(BuildContext context, String title, String message,
      IconData icon, Color iconColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          // title: Column(
          //   children: [
          //     Icon(icon, color: iconColor),
          //     const SizedBox(width: 10),
          //     Text(title),
          //   ],
          // ),
          content: SizedBox(
            height: 200,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 60,
                  ),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16.5,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 18,
                ),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onOpenNotifications() {
    Get.delete<NotificationController>(force: true);
    Get.toNamed(AppRouter.getNotifications());
  }

  void onInbox() {
    Get.delete<InboxController>(force: true);
    Get.toNamed(AppRouter.getInboxRoute());
  }

  void onUpgradeScreen() {
    Get.delete<PremiumController>(force: true);
    Get.toNamed(AppRouter.getPremiumRoute());
  }
}
