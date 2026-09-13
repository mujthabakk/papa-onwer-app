/*Papabear*/
import 'dart:math';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/appointment_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/calendar_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/calendar_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/order_details_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

import '../backend/parse/holiday_parse.dart';

class HolidayController extends GetxController implements GetxService {
  final HolidayParser parser;
  bool apiCalled = false;
  bool calendarListCalled = true;
  List<CalendarModelHoliday> _list = <CalendarModelHoliday>[];
  List<CalendarModelHoliday> get list => _list;
  List<Appointment> events = <Appointment>[];

  HolidayController({
    required this.parser,
  });

  @override
  void onInit() {
    super.onInit();
    getHolidays();
  }

  Future<void> getHolidays() async {
    Response response = await parser.getHolidays();
    apiCalled = true;
    _list = [];
    events = [];
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      List<dynamic> body = myMap["data"];
      for (var element in body) {
        try {
          DateTime date = DateTime.parse(element.toString());
          DateTime startTime =
              DateTime(date.year, date.month, date.day, 0, 0, 0);
          DateTime endTime =
              DateTime(date.year, date.month, date.day, 23, 59, 59);

          _list.add(CalendarModelHoliday(date: date));
          events.add(Appointment(
            startTime: startTime,
            endTime: endTime,
            subject: 'Holiday',
            color: const Color(0xFFD20100),
          ));
        } catch (e) {
          debugPrint('Error parsing holiday date: $e');
        }
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> markHolidays(String date, int status) async {
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
      barrierDismissible: false,
    );

    Response response = await parser.markHoliday(date, status);
    Get.back();
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      //onBack();
      successToast('Holiday Marked Successfully');
      getHolidays();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }
}

class CalendarModelHoliday {
  DateTime date;
  CalendarModelHoliday({required this.date});
}
