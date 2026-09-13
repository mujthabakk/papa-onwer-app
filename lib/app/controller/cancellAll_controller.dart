import 'dart:math';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/appointment_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/calendar_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/calendar_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/cancel_all_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/inbox_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/notification_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/order_details_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/premium_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class CancelAllAppointmentController extends GetxController
    implements GetxService {
  final CancelAllParser parser;
  bool apiCalled = true;
  bool calendarListCalled = true;
  List<CalendarModel> _list = <CalendarModel>[];
  List<CalendarModel> get list => _list;
  late MeetingDataSource events;
  CancelAllAppointmentController({required this.parser});

  @override
  void onInit() {
    super.onInit();
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

  void onOrderDetails() {
    Get.toNamed(AppRouter.getOrderDetailsRoute());
  }

  Future<void> cancelAppointments(DateTime date, String reason,
      {Function? onSuccess}) async {
    int type = 0;
    if (parser.getType()) {
      type = 1;
    }
    calendarListCalled = false;

    // Format the date
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    var param = {
      "uid": parser.getUId(),
      "date": formattedDate,
      "reason": reason,
      "type": type,
    };

    print("Request Parameters: $param");

    // Send the request
    Response response = await parser.cancelAllAppointments(param);

    // Reset calendar status after response
    calendarListCalled = true;

    // Handle response
    if (response.statusCode == 200) {
      //mark day as holiday
      await parser.markHoliday(formattedDate, 1);

      Map<String, dynamic> responseMap =
          Map<String, dynamic>.from(response.body);

      if (response.statusCode == 200) {
        // Success handling
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        // Error handling
        Get.snackbar(
          'Error',
          response.body != null
              ? response.body.toString()
              : 'Failed to cancel appointments',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      if (responseMap['success'] == true) {
        // If response indicates success
        int data = responseMap['data']; // Extract 'data' field
        print("Response Success. Data: $data");

        // Handle 'data' as needed
        if (data == 0) {
          print("appointments canceled.");
          Get.snackbar('Cancelled', 'Appointments Cancelled Successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);
        } else {
          // print("$data appointments canceled successfully.");
        }
      } else {
        // If success is false, handle accordingly
        print("Response indicates failure: ${responseMap['status']}");
      }
    } else {
      // Handle non-200 HTTP response codes
      ApiChecker.checkApi(response);
      print("Failed with status code: ${response.statusCode}");
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
