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
  MeetingDataSource events = MeetingDataSource(<Meeting>[]);

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
    if (!parser.sharedPreferencesManager.hasOwnerSession()) {
      apiCalled = true;
      events = MeetingDataSource(<Meeting>[]);
      return;
    }
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
    try {
      Response response = await parser.getCalendarView();
      _list = [];
      final List<Meeting> meetings = <Meeting>[];
      if (response.statusCode == 200) {
        final myMap = response.body is Map
            ? Map<String, dynamic>.from(response.body)
            : <String, dynamic>{};
        final body = myMap['data'];
        final rows = body is List ? body : const [];
        final List<Color> colorCollection = <Color>[
          const Color(0xFF0F8644),
          const Color(0xFF8B1FA9),
          const Color(0xFFD20100),
          const Color(0xFFFC571D),
          const Color(0xFF36B37B),
          const Color(0xFF01A1EF),
          const Color(0xFF3D4FB5),
          const Color(0xFFE47C73),
          const Color(0xFF636363),
          const Color(0xFF0A8043),
        ];
        final Random random = Random();
        for (final element in rows) {
          if (element is! Map) continue;
          try {
            final data =
                CalendarModel.fromJson(Map<String, dynamic>.from(element));
            _list.add(data);
            final day = data.day;
            if (day == null || day.isEmpty) continue;
            final DateTime startDate = DateTime.parse(day);
            final int limit = data.count ?? 0;
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
          } catch (e) {
            debugPrint('skip calendar row: $e');
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
      events = MeetingDataSource(meetings);
    } catch (e) {
      debugPrint('getCalendarView: $e');
      events = MeetingDataSource(<Meeting>[]);
    } finally {
      apiCalled = true;
      update();
    }
  }

  void onOrderDetails() {
    Get.toNamed(AppRouter.getOrderDetailsRoute());
  }

  Future<void> getByDate(var date) async {
    calendarListCalled = false;
    _appointmentList = [];
    update();
    try {
      var param = {
        "id": parser.getUID(),
        "date": date,
        "type": parser.getType()
      };
      Response response = await parser.getByDate(param);
      if (response.statusCode == 200) {
        final myMap = response.body is Map
            ? Map<String, dynamic>.from(response.body)
            : <String, dynamic>{};
        final body = myMap['data'];
        final rows = body is List ? body : const [];
        _appointmentList = [];
        for (final data in rows) {
          if (data is! Map) continue;
          try {
            _appointmentList.add(
                AppointmentModel.fromJson(Map<String, dynamic>.from(data)));
          } catch (e) {
            debugPrint('skip calendar appointment: $e');
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint('getByDate: $e');
    } finally {
      calendarListCalled = true;
      update();
    }
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
