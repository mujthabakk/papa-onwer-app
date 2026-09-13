/*Papabear*/
import 'dart:math';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/appointment_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/calendar_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/calendar_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/inbox_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/notification_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/order_details_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/premium_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class CalendarsController extends GetxController implements GetxService {
  final CalendarsParser parser;
  bool apiCalled = false;
  bool calendarListCalled = true;
  List<CalendarModel> _list = <CalendarModel>[];
  List<CalendarModel> get list => _list;
  late MeetingDataSource events;

  String currencySide = AppConstants.defaultCurrencySide;
  String currencySymbol = AppConstants.defaultCurrencySymbol;

  List<AppointmentModel> _appointmentList = <AppointmentModel>[];
  List<AppointmentModel> get appointmentList => _appointmentList;
  CalendarsController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    currencySide = parser.getCurrencySide();
    currencySymbol = parser.getCurrencySymbol();
    if (!parser.sharedPreferencesManager.hasOwnerSession()) return;
    getCalendarView();
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

  Future<void> getCalendarView() async {
    Response response = await parser.getCalendarView();
    apiCalled = true;
    _list = [];
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      dynamic body = myMap["data"];
      body.forEach((element) {
        CalendarModel data = CalendarModel.fromJson(element);
        _list.add(data);
      });
      final List<Color> colorCollection = <Color>[];
      colorCollection.add(const Color(0xFF0F8644));
      colorCollection.add(const Color(0xFF8B1FA9));
      colorCollection.add(const Color(0xFFD20100));
      colorCollection.add(const Color(0xFFFC571D));
      colorCollection.add(const Color(0xFF36B37B));
      colorCollection.add(const Color(0xFF01A1EF));
      colorCollection.add(const Color(0xFF3D4FB5));
      colorCollection.add(const Color(0xFFE47C73));
      colorCollection.add(const Color(0xFF636363));
      colorCollection.add(const Color(0xFF0A8043));
      final List<Meeting> meetings = <Meeting>[];
      final Random random = Random();
      for (var element in _list) {
        debugPrint(element.day);
        final DateTime startDate = DateTime.parse(element.day.toString());
        int limit = int.parse(element.count.toString());
        for (int i = 0; i < limit; i++) {
          meetings.add(Meeting(
              '',
              '',
              '',
              null,
              startDate,
              startDate.add(Duration(hours: random.nextInt(3))),
              colorCollection[random.nextInt(9)],
              false,
              '',
              '',
              ''));
        }
      }
      events = MeetingDataSource(meetings);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onOrderDetails() {
    Get.toNamed(AppRouter.getOrderDetailsRoute());
  }

  Future<void> getByDate(var date) async {
    calendarListCalled = false;
    _appointmentList = [];
    print(date);
    update();
    var param = {"id": parser.getUID(), "date": date, "type": parser.getType()};
    // print(date);
    // print(parser.getType());
    Response response = await parser.getByDate(param);
    calendarListCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      dynamic body = myMap["data"];
      _appointmentList = [];
      body.forEach((data) {
        AppointmentModel appointment = AppointmentModel.fromJson(data);
        _appointmentList.add(appointment);
      });
      debugPrint(appointmentList.length.toString());
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onAppointment(int id) {
    // Get.toNamed(AppRouter.getOrderDetailsRoute());
    Get.delete<OrderDetailsController>(force: true);
    Get.toNamed(AppRouter.getOrderDetailsRoute(), arguments: [id]);
  }
}

class Meeting {
  Meeting(
      this.eventName,
      this.organizer,
      this.contactID,
      this.capacity,
      this.from,
      this.to,
      this.background,
      this.isAllDay,
      this.startTimeZone,
      this.endTimeZone,
      this.recurrenceRule);

  String eventName;
  String? organizer;
  String? contactID;
  int? capacity;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String? startTimeZone;
  String? endTimeZone;
  String? recurrenceRule;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(this.source);

  List<Meeting> source;

  @override
  List<Meeting> get appointments => source;

  @override
  DateTime getStartTime(int index) {
    return source[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return source[index].to;
  }

  @override
  bool isAllDay(int index) {
    return source[index].isAllDay;
  }

  @override
  String getSubject(int index) {
    return source[index].eventName;
  }

  @override
  String? getStartTimeZone(int index) {
    return source[index].startTimeZone;
  }

  @override
  String? getEndTimeZone(int index) {
    return source[index].endTimeZone;
  }

  @override
  Color getColor(int index) {
    return source[index].background;
  }

  @override
  String? getRecurrenceRule(int index) {
    return source[index].recurrenceRule;
  }
}
