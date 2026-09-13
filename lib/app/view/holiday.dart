import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/calendar_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/env.dart';

import '../controller/holiday_controller.dart';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({Key? key}) : super(key: key);

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  late final CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _calendarController.selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _showMarkHolidayDialog(
      DateTime date, int status, HolidayController controller) {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    String statusMsg = 'Mark as Holiday';
    String mark = 'mark';
    String markButton = 'Mark as Holiday';

    if (status == 0) {
      statusMsg = 'Unmark Holiday';
      mark = 'unmark';
      markButton = 'Unmark as Holiday';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(statusMsg),
          content: Text('Would you like to $mark $formattedDate as a holiday?'.tr),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(markButton),
              onPressed: () {
                Navigator.of(context).pop();
                controller.markHolidays(formattedDate, status);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HolidayController>(
      builder: (value) {
        return Scaffold(
          backgroundColor: ThemeProvider.whiteColor,
          appBar: AppBar(
            backgroundColor: ThemeProvider.appColor,
            elevation: 0,
            toolbarHeight: 50,
            iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
            automaticallyImplyLeading: true,
            title: Text(
              'Mark Holidays'.tr,
              style: const TextStyle(
                  fontFamily: 'bold',
                  fontSize: 14,
                  color: ThemeProvider.whiteColor),
            ),
          ),
          body: value.apiCalled == false
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      height: 350,
                      color: ThemeProvider.whiteColor,
                      child: _getAgendaViewCalendar(value.events,
                          _onViewChanged, _calendarController, value),
                    ),
                    Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Container(
                        width: double.infinity,
                        child: Text('๏   Holidays are marked with red color\n\n๏   Click on a date to mark as holiday'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _onViewChanged(ViewChangedDetails visibleDatesChangedDetails) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final DateTime currentViewDate = visibleDatesChangedDetails
          .visibleDates[visibleDatesChangedDetails.visibleDates.length ~/ 2];

      if (currentViewDate.month == DateTime.now().month &&
          currentViewDate.year == DateTime.now().year) {
        _calendarController.selectedDate = DateTime.now();
      } else {
        _calendarController.selectedDate =
            DateTime(currentViewDate.year, currentViewDate.month);
      }
    });
  }

  Widget _getAgendaViewCalendar(
      List<Appointment> events,
      ViewChangedCallback? onViewChanged,
      CalendarController? controller,
      HolidayController hcontroller) {
    return SfCalendar(
      key: const ValueKey('holiday_calendar'),
      view: CalendarView.month,
      controller: controller,
      showDatePickerButton: true,
      showNavigationArrow: true,
      todayHighlightColor: ThemeProvider.appColor,
      onViewChanged: onViewChanged,
      backgroundColor: ThemeProvider.whiteColor,
      dataSource: EventDataSource(events),
      monthViewSettings: const MonthViewSettings(
        showAgenda: false,
        numberOfWeeksInView: 6,
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        appointmentDisplayCount: 1,
        showTrailingAndLeadingDates: false,
      ),
      timeSlotViewSettings: const TimeSlotViewSettings(
          minimumAppointmentDuration: Duration(minutes: 60)),
      onTap: (CalendarTapDetails details) {
        if (details.targetElement == CalendarElement.calendarCell) {
          int status = _hasEventOnDate(details.date!, events) ? 0 : 1;
          print('status $status');
          _showMarkHolidayDialog(details.date!, status, hcontroller);
        }
      },
    );
  }

  bool _hasEventOnDate(DateTime date, List<Appointment> events) {
    return events.any((appointment) =>
        appointment.startTime.year == date.year &&
        appointment.startTime.month == date.month &&
        appointment.startTime.day == date.day);
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}
