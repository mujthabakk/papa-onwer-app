import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/appointment_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/calendar_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/cancellAll_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class CancellationRecord {
  final DateTime date;
  final String reason;
  final DateTime cancelledAt;

  CancellationRecord({
    required this.date,
    required this.reason,
    required this.cancelledAt,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'reason': reason,
      'cancelledAt': cancelledAt.toIso8601String(),
    };
  }

  // Create from JSON for retrieval
  factory CancellationRecord.fromJson(Map<String, dynamic> json) {
    return CancellationRecord(
      date: DateTime.parse(json['date']),
      reason: json['reason'],
      cancelledAt: DateTime.parse(json['cancelledAt']),
    );
  }
}

class CancelAllAppointmentScreen extends StatefulWidget {
  const CancelAllAppointmentScreen({Key? key}) : super(key: key);

  @override
  State<CancelAllAppointmentScreen> createState() =>
      _CancelAllAppointmentScreenState();
}

class _CancelAllAppointmentScreenState
    extends State<CancelAllAppointmentScreen> {
  final CalendarController _calendarController = CalendarController();
  final TextEditingController _reasonController = TextEditingController();

  // List to hold cancellation records
  List<CancellationRecord> cancellationHistory = [];
  bool isHistoryExpanded = true;

  @override
  void initState() {
    _calendarController.selectedDate = DateTime.now();
    super.initState();
    // Load saved cancellation history when screen initializes
    _loadCancellationHistory();
  }

  // Load cancellation history from SharedPreferences
  Future<void> _loadCancellationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('cancellation_history');

    if (historyJson != null) {
      final List<dynamic> decodedList = jsonDecode(historyJson);
      setState(() {
        cancellationHistory = decodedList
            .map((item) => CancellationRecord.fromJson(item))
            .toList();
      });
    }
  }

  // Save cancellation history to SharedPreferences
  Future<void> _saveCancellationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encodedList =
        cancellationHistory.map((record) => record.toJson()).toList();
    await prefs.setString('cancellation_history', jsonEncode(encodedList));
  }

  // Add a new cancellation record
  void _addCancellationRecord(DateTime date, String reason) {
    final newRecord = CancellationRecord(
      date: date,
      reason: reason,
      cancelledAt: DateTime.now(),
    );

    setState(() {
      cancellationHistory.add(newRecord);
      isHistoryExpanded = true; // Expand history when new record is added
    });

    // Save the updated history
    _saveCancellationHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CancelAllAppointmentController>(
      builder: (value) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          appBar: AppBar(
            backgroundColor: ThemeProvider.appColor,
            elevation: 0,
            toolbarHeight: 50,
            iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
            automaticallyImplyLeading: true,
            title: Text('Cancel All Appointments'.tr,
              style: ThemeProvider.titleStyle,
            ),
          ),
          body: value.apiCalled == true
              ? CustomScrollView(
                  slivers: [
                    // Calendar section
                    SliverToBoxAdapter(
                      child: Container(
                        color: ThemeProvider.appColor,
                        child: Column(
                          children: [
                            _getAgendaViewCalendar(),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                    // History section
                    SliverToBoxAdapter(
                      child: _buildHistorySection(),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildHistorySection() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle button
          InkWell(
            onTap: () {
              setState(() {
                isHistoryExpanded = !isHistoryExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: ThemeProvider.appColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text('Cancellation History'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Icon(
                      isHistoryExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // History list
          if (isHistoryExpanded)
            cancellationHistory.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: Text('No cancellation history'.tr,
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cancellationHistory.length,
                    itemBuilder: (context, index) {
                      final record = cancellationHistory[index];
                      return Card(
                        color: ThemeProvider.golden.withOpacity(0.1),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: ThemeProvider.golden.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Date: ${record.date.toShortString()}',
                                    style: const TextStyle(
                                      color: ThemeProvider.golden,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ThemeProvider.appColor
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      record.cancelledAt.toShortString(),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Reason: ${record.reason}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ],
      ),
    );
  }

  Widget _getAgendaViewCalendar() {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: ThemeProvider.golden, // header background color
          onPrimary: Color.fromARGB(255, 0, 0, 0), // header text color
          onSurface: Color.fromARGB(255, 255, 255, 255), // body text color
        ),
        dialogBackgroundColor:
            const Color.fromARGB(255, 0, 0, 0), // background color
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CalendarDatePicker(
              initialDate: _calendarController.selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onDateChanged: (selectedDate) {
                _calendarController.selectedDate = selectedDate;
                _showCancelDialog(selectedDate);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text('Tap on a date to cancel all appointments'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  void _showCancelDialog(DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Cancel Appointments on ${selectedDate.toLocal().toShortString()}',
            style: const TextStyle(color: ThemeProvider.golden),
          ),
          content: TextField(
            controller: _reasonController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter cancel reason'.tr,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: ThemeProvider.golden.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: ThemeProvider.golden),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: Text('Cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                _submitCancelReason(selectedDate);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeProvider.golden,
                foregroundColor: Colors.black,
              ),
              child: Text('Submit'.tr),
            ),
          ],
        );
      },
    );
  }

  void _submitCancelReason(DateTime selectedDate) {
    final String reason = _reasonController.text;
    if (reason.isNotEmpty) {
      // Get the controller
      final controller = Get.find<CancelAllAppointmentController>();

      // Call the cancellation method and add success callback
      controller.cancelAppointments(selectedDate, reason, onSuccess: () {
        // On successful cancellation, add to history
        _addCancellationRecord(selectedDate, reason);

        // Show success message
        Get.snackbar(
          'Success',
          'Appointments cancelled successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
        );
      });

      Get.find<AppointmentController>().getList();

      _reasonController.clear();
      Navigator.of(context).pop();
    } else {
      // Handle the case where the reason is empty
      Get.snackbar(
        'Error',
        'Please enter a cancellation reason',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
      );
    }
  }
}

extension DateExtension on DateTime {
  String toShortString() {
    return '${this.year}-${this.month.toString().padLeft(2, '0')}-${this.day.toString().padLeft(2, '0')}';
  }
}
