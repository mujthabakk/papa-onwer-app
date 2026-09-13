import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/individual_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/profile_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/slots_list_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/slots_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/timing_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_slot_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/slot_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class AddSlotController extends GetxController implements GetxService {
  final AddSlotParser parser;

  String dayName = 'Sunday'.tr;
  List<TimingModel> _timesList = <TimingModel>[];
  IndividualInfoModel _individualInfo = IndividualInfoModel();
  IndividualInfoModel get individualInfo => _individualInfo;
  ProfileModel _profileInfo = ProfileModel();
  ProfileModel get profileInfo => _profileInfo;
  List<String> dayList = [
    'Sunday'.tr,
    'Monday'.tr,
    'Tuesday'.tr,
    'Wednesday'.tr,
    'Thursday'.tr,
    'Friday'.tr,
    'Saturday'.tr
  ];
  String openTime = '';
  String closeTime = '';
  String available = '';
  TextEditingController availableController = TextEditingController();

  List<SlotsModel> _slotList = <SlotsModel>[];
  List<SlotsModel> get slotList => _slotList;

  SlotListModel _slotData = SlotListModel();
  SlotListModel get slotData => _slotData;

  String action = '';

  int slotId = 0;
  bool apiCalled = false;
  bool disabled = false;

  AddSlotController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    action = Get.arguments[0];
    if (action == 'update') {
      slotId = Get.arguments[1];
      disabled = true;
      getSlotData();
    } else {
      apiCalled = true;
    }
    bool type = parser.getType();

    if (type == true) {
      getCateByIdShop();
    } else {
      getCateByIdFreelancer();
    }
    _slotList = [];
  }

  // Helper method to convert time string to minutes for easier comparison
  int _timeToMinutes(String timeString, {bool is24HourFormat = false}) {
    try {
      if (is24HourFormat) {
        // Handle 24-hour format from API (e.g., "0:14", "10:00", "20:34")
        List<String> parts = timeString.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        return hour * 60 + minute;
      } else {
        // Handle 12-hour format from UI (e.g., "10:30 AM", "08:15 PM")
        DateTime dateTime = Jiffy.parse(timeString, pattern: "hh:mm a").dateTime;
        return dateTime.hour * 60 + dateTime.minute;
      }
    } catch (e) {
      debugPrint('Error parsing time: $timeString - $e');
      return 0;
    }
  }

  // Helper method to convert 12-hour format to 24-hour format
  String _convertTo24Hour(String time12Hour) {
    try {
      DateTime dateTime = Jiffy.parse(time12Hour, pattern: "hh:mm a").dateTime;
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      debugPrint('Error converting to 24-hour format: $time12Hour - $e');
      return "00:00";
    }
  }

  // Helper method to convert 24-hour format to 12-hour format
  String _convertTo12Hour(String time24Hour) {
    try {
      List<String> parts = time24Hour.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      DateTime dateTime = DateTime(2020, 1, 1, hour, minute);
      return Jiffy.parseFromDateTime(dateTime).format(pattern: "hh:mm a");
    } catch (e) {
      debugPrint('Error converting to 12-hour format: $time24Hour - $e');
      return "12:00 AM";
    }
  }

  // Helper method to check if two time slots overlap
  bool _doSlotsOverlap(String start1, String end1, String start2, String end2,
      {bool slot1Is24Hour = false, bool slot2Is24Hour = false}) {
    try {
      int start1Minutes = _timeToMinutes(start1, is24HourFormat: slot1Is24Hour);
      int end1Minutes = _timeToMinutes(end1, is24HourFormat: slot1Is24Hour);
      int start2Minutes = _timeToMinutes(start2, is24HourFormat: slot2Is24Hour);
      int end2Minutes = _timeToMinutes(end2, is24HourFormat: slot2Is24Hour);

      // Handle overnight slots (e.g., 22:00 to 02:00)
      if (end1Minutes <= start1Minutes) {
        end1Minutes += 24 * 60; // Add 24 hours
      }
      if (end2Minutes <= start2Minutes) {
        end2Minutes += 24 * 60; // Add 24 hours
      }

      // Check for overlap: slot1 starts before slot2 ends AND slot2 starts before slot1 ends
      return start1Minutes < end2Minutes && start2Minutes < end1Minutes;
    } catch (e) {
      debugPrint('Error checking overlap: $e');
      return true; // Assume overlap if parsing fails to prevent conflicts
    }
  }

  // Helper method to validate slot timing
  bool _isValidSlotTiming(String startTime, String endTime) {
    try {
      int startMinutes = _timeToMinutes(startTime, is24HourFormat: false);
      int endMinutes = _timeToMinutes(endTime, is24HourFormat: false);

      // Allow overnight slots, but ensure there's at least 15 minutes difference
      if (endMinutes <= startMinutes) {
        endMinutes += 24 * 60; // Handle overnight slot
      }

      return (endMinutes - startMinutes) >= 1; // At least 15 minutes duration
    } catch (e) {
      debugPrint('Error validating slot timing: $e');
      return false;
    }
  }

  // Helper method to check if slot is within working hours
  bool _isSlotWithinWorkingHours(
      String slotStart, String slotEnd, String workStart, String workEnd) {
    try {
      int slotStartMinutes = _timeToMinutes(slotStart, is24HourFormat: false);
      int slotEndMinutes = _timeToMinutes(slotEnd, is24HourFormat: false);
      int workStartMinutes = _timeToMinutes(workStart, is24HourFormat: true);
      int workEndMinutes = _timeToMinutes(workEnd, is24HourFormat: true);

      // Handle overnight working hours
      if (workEndMinutes <= workStartMinutes) {
        workEndMinutes += 24 * 60;
      }

      // Handle overnight slot
      if (slotEndMinutes <= slotStartMinutes) {
        slotEndMinutes += 24 * 60;
      }

      // Check if slot is completely within working hours
      return slotStartMinutes >= workStartMinutes &&
          slotEndMinutes <= workEndMinutes;
    } catch (e) {
      debugPrint('Error checking working hours: $e');
      return false;
    }
  }

  Future<void> getSlotData() async {
    Response response = await parser.getSlotbyId(slotId);
    apiCalled = true;
    update();
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var data = myMap['data'];
      _slotList = [];
      SlotListModel slotInfo = SlotListModel.fromJson(data);
      _slotData = slotInfo;
      dayName = dayList[_slotData.weekId as int];
      _slotList = _slotData.slots as List<SlotsModel>;
      update();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> openTimePicker() async {
    try {
      var context = Get.context as BuildContext;
      TimeOfDay initialTime = TimeOfDay.now();
      TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: initialTime,
          initialEntryMode: TimePickerEntryMode.input,
          helpText: 'Select Opening Time',
          cancelText: 'Cancel',
          confirmText: 'Select');

      if (pickedTime != null) {
        DateTime dateTime = DateTime(2020, 10, 19, pickedTime.hour, pickedTime.minute);
        openTime = Jiffy.parseFromDateTime(dateTime).format(pattern: "hh:mm a");
        update();
      }
    } catch (e) {
      debugPrint('Error in openTimePicker: $e');
      _showDialog(
          title: 'Error',
          message: 'Failed to select opening time. Please try again.');
    }
  }

  Future<void> setCount(String values) async {
    try {
      if (values.isNotEmpty) {
        int count = int.parse(values);
        if (count > 0 && count <= 100) {
          available = values;
          update();
        } else {
          _showDialog(
              title: 'Invalid Count',
              message: 'Slot count must be between 1 and 100.');
        }
      }
    } catch (e) {
      _showDialog(
          title: 'Invalid Input', message: 'Please enter a valid number.');
    }
  }

  Future<void> closeTimePicker() async {
    try {
      var context = Get.context as BuildContext;
      TimeOfDay initialTime = TimeOfDay.now();
      TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: initialTime,
          initialEntryMode: TimePickerEntryMode.input,
          helpText: 'Select Closing Time',
          cancelText: 'Cancel',
          confirmText: 'Select');

      if (pickedTime != null) {
        DateTime dateTime = DateTime(2020, 10, 19, pickedTime.hour, pickedTime.minute);
        closeTime = Jiffy.parseFromDateTime(dateTime).format(pattern: "hh:mm a");
        update();
      }
    } catch (e) {
      debugPrint('Error in closeTimePicker: $e');
      _showDialog(
          title: 'Error',
          message: 'Failed to select closing time. Please try again.');
    }
  }

  void _showDialog({required String title, required String message}) {
    Get.defaultDialog(
      title: title,
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      middleText: message,
      middleTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
      ),
      backgroundColor: Colors.white,
      radius: 8,
      contentPadding: EdgeInsets.all(20),
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Button color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text(
            'OK',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void addSlots() {
    // Basic validation
    if (openTime.isEmpty || closeTime.isEmpty) {
      _showDialog(
          title: 'Error', message: 'Please select both open and close times.');
      return;
    }

    if (available.isEmpty) {
      _showDialog(title: 'Error', message: 'Please select slot count.');
      return;
    }

    // Validate slot timing
    if (!_isValidSlotTiming(openTime, closeTime)) {
      _showDialog(
          title: 'Invalid Slot',
          message:
              'Slot must be at least 15 minutes long and closing time should be after opening time.');
      return;
    }

    // Check if the day exists in the timing list
    int currentDayIndex = dayList.indexOf(dayName);
    TimingModel? selectedDayTiming = _timesList
        .firstWhereOrNull((element) => element.day == currentDayIndex);

    if (selectedDayTiming == null) {
      _showDialog(
          title: 'Unavailable',
          message:
              'Selected day is not available for adding slots. Please check your working hours configuration.');
      return;
    }

    // Validate available count
    int availableCount;
    try {
      availableCount = int.parse(available);
      if (availableCount <= 0) {
        _showDialog(
            title: 'Invalid Count',
            message: 'Available slot count must be greater than 0.');
        return;
      }
      if (availableCount > 100) {
        _showDialog(
            title: 'Invalid Count',
            message: 'Available slot count cannot exceed 100.');
        return;
      }
    } catch (e) {
      _showDialog(
          title: 'Invalid Count',
          message: 'Please enter a valid number for available slots.');
      return;
    }

    try {
      // Check if the selected times are within the day's working hours
      // selectedDayTiming has openTime and closeTime in 24-hour format
      // openTime and closeTime are in 12-hour format
      if (!_isSlotWithinWorkingHours(openTime, closeTime,
          selectedDayTiming.openTime!, selectedDayTiming.closeTime!)) {
        String workStart12Hour = _convertTo12Hour(selectedDayTiming.openTime!);
        String workEnd12Hour = _convertTo12Hour(selectedDayTiming.closeTime!);

        _showDialog(
            title: 'Invalid Slot',
            message:
                'Slot time must be within the working hours: $workStart12Hour - $workEnd12Hour');
        return;
      }

      // Check for overlapping slots with existing slots
      for (int i = 0; i < _slotList.length; i++) {
        SlotsModel existingSlot = _slotList[i];
        if (existingSlot.startTime != null && existingSlot.endTime != null) {
          // Both new slot and existing slots are in 12-hour format
          if (_doSlotsOverlap(openTime, closeTime, existingSlot.startTime!,
              existingSlot.endTime!,
              slot1Is24Hour: false, slot2Is24Hour: false)) {
            _showDialog(
                title: 'Overlapping Slots',
                message:
                    'The new slot ($openTime - $closeTime) overlaps with an existing slot (${existingSlot.startTime} - ${existingSlot.endTime}). Please choose a different time.');
            return;
          }
        }
      }

      // Check for exact duplicate slots
      var exactDuplicate = _slotList.where((element) =>
          element.startTime == openTime && element.endTime == closeTime);
      if (exactDuplicate.isNotEmpty) {
        _showDialog(
            title: 'Duplicate Slot',
            message: 'This exact time slot already exists.');
        return;
      }

      // Add the new slot
      var param = {
        "start_time": openTime,
        "end_time": closeTime,
        "available": available
      };

      SlotsModel newSlot = SlotsModel.fromJson(param);
      _slotList.add(newSlot);

      // Sort slots by start time for better organization
      // _slotList.sort((a, b) {
      //   int aMinutes = _timeToMinutes(a.startTime!, is24HourFormat: false);
      //   int bMinutes = _timeToMinutes(b.startTime!, is24HourFormat: false);
      //   return aMinutes.compareTo(bMinutes);
      // });

      // Clear the input fields
      openTime = '';
      closeTime = '';
      available = '';
      availableController.clear();

      update();

      _showDialog(
          title: 'Success',
          message: 'The time slot has been added successfully.');
    } catch (e) {
      debugPrint('Error adding slot: $e');
      _showDialog(
          title: 'Error',
          message:
              'An unexpected error occurred while adding the slot. Please try again.');
    }
  }

  void onUpdateDayName(String name) {
    dayName = name;
    update();
  }

  Future<void> saveSlots() async {
    if (_slotList.isEmpty) {
      _showDialog(
          title: 'No Slots',
          message: 'Please add at least one time slot before saving.');
      return;
    }

    // Validate all slots before saving
    for (int i = 0; i < _slotList.length; i++) {
      SlotsModel slot = _slotList[i];
      if (slot.startTime == null ||
          slot.endTime == null ||
          slot.available == null) {
        _showDialog(
            title: 'Invalid Slot Data',
            message:
                'Slot ${i + 1} has missing information. Please remove and re-add this slot.');
        return;
      }
    }

    Get.dialog(
      SimpleDialog(
        children: [
          Row(
            children: [
              const SizedBox(width: 30),
              const CircularProgressIndicator(color: ThemeProvider.appColor),
              const SizedBox(width: 30),
              SizedBox(
                  child: Text(
                "Saving slots...".tr,
                style: const TextStyle(fontFamily: 'bold'),
              )),
            ],
          )
        ],
      ),
      barrierDismissible: false,
    );

    try {
      var param = {
        "uid": parser.getUID(),
        "week_id": dayList.indexOf(dayName),
        "slots": jsonEncode(slotList)
      };

      Response response = await parser.onCreateTimeSlot(param);
      Get.back();

      if (response.statusCode == 200) {
        Get.find<SlotController>().getList();
        _showDialog(
            title: 'Success', message: 'Slots have been saved successfully.');
        // Delay navigation to allow user to see success message
        Future.delayed(const Duration(seconds: 1), () {
          onBack();
        });
      } else if (response.statusCode == 500) {
        debugPrint(response.bodyString);
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        _showDialog(
            title: 'Server Error',
            message:
                myMap['message'] ?? 'An error occurred while saving slots.');
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      Get.back();
      debugPrint('Error saving slots: $e');
      _showDialog(
          title: 'Error',
          message:
              'Failed to save slots. Please check your internet connection and try again.');
    }
    update();
  }

  Future<void> updateSlots() async {
    if (_slotList.isEmpty) {
      _showDialog(
          title: 'No Slots',
          message: 'Please add at least one time slot before updating.');
      return;
    }

    Get.dialog(
      SimpleDialog(
        children: [
          Row(
            children: [
              const SizedBox(width: 30),
              const CircularProgressIndicator(color: ThemeProvider.appColor),
              const SizedBox(width: 30),
              SizedBox(
                  child: Text(
                "Updating slots...".tr,
                style: const TextStyle(fontFamily: 'bold'),
              )),
            ],
          )
        ],
      ),
      barrierDismissible: false,
    );

    try {
      var param = {
        "id": slotId,
        "week_id": dayList.indexOf(dayName),
        "slots": jsonEncode(slotList)
      };

      Response response = await parser.onUpdateSlots(param);
      Get.back();

      if (response.statusCode == 200) {
        Get.find<SlotController>().getList();
        _showDialog(
            title: 'Success', message: 'Slots have been updated successfully.');
        Future.delayed(const Duration(seconds: 1), () {
          onBack();
        });
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      Get.back();
      debugPrint('Error updating slots: $e');
      _showDialog(
          title: 'Error', message: 'Failed to update slots. Please try again.');
    }
    update();
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  void onDestroy(int index) {
    debugPrint(index.toString());
    _slotList.removeAt(index);
    update();
  }

  Future<void> getCateByIdShop() async {
    var response = await parser.getCateById();
    apiCalled = true;
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      debugPrint(myMap.toString());
      _timesList = [];
      var data = myMap['data'];
      ProfileModel profileData = ProfileModel.fromJson(data);
      _profileInfo = profileData;

      if (profileInfo.timing != 'NA') {
        var times = jsonDecode(profileInfo.timing.toString());
        times.forEach((element) {
          TimingModel datas = TimingModel.fromJson(element);
          _timesList.add(datas);
        });
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getCateByIdFreelancer() async {
    var response = await parser.getIndividualById();
    apiCalled = true;
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      debugPrint(myMap.toString());
      _timesList = [];
      var data = myMap['data'];
      IndividualInfoModel invidualData = IndividualInfoModel.fromJson(data);
      _individualInfo = invidualData;

      if (individualInfo.timing != 'NA') {
        var times = jsonDecode(individualInfo.timing.toString());
        times.forEach((element) {
          TimingModel datas = TimingModel.fromJson(element);
          _timesList.add(datas);
        });
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }
}
