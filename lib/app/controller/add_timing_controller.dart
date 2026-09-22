import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_timing_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_individual_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_business_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/slot_time.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class AddTimingController extends GetxController implements GetxService {
  final AddTimingParser parser;

  String dayName = 'Sunday';

  bool userType = true;

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

  String action = '';

  AddTimingController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    userType = parser.getType();
    action = Get.arguments[0];
    if (action == 'edit') {
      dayName = Get.arguments[1];
      openTime = SlotTime.to12Hour(Get.arguments[2]?.toString());
      closeTime = SlotTime.to12Hour(Get.arguments[3]?.toString());
      update();
    }
  }

  Future<void> openTimePicker() async {
    var context = Get.context as BuildContext;
    TimeOfDay initialTime = TimeOfDay.now();
    final openMins = SlotTime.toMinutes(openTime);
    if (openMins != null) {
      initialTime = TimeOfDay(hour: openMins ~/ 60, minute: openMins % 60);
    }
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (pickedTime == null) return;
    openTime = SlotTime.fromTimeOfDay(
        hour24: pickedTime.hour, minute: pickedTime.minute);
    update();
  }

  Future<void> closeTimePicker() async {
    var context = Get.context as BuildContext;
    TimeOfDay initialTime = TimeOfDay.now();
    final closeMins = SlotTime.toMinutes(closeTime);
    if (closeMins != null) {
      initialTime = TimeOfDay(hour: closeMins ~/ 60, minute: closeMins % 60);
    }
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (pickedTime == null) return;
    closeTime = SlotTime.fromTimeOfDay(
        hour24: pickedTime.hour, minute: pickedTime.minute);
    update();
  }

  void onSaveTime() {
    if (userType == true) {
      debugPrint('for salon');
      if (openTime.isEmpty || closeTime.isEmpty) {
        showToast('Please select time');
        return;
      }
      var list = Get.find<ProfileCategoriesController>().timesList;
      var index = dayList.indexOf(dayName);
      debugPrint(index.toString());
      var exist = list.where((element) => element.day == index);
      if (exist.isNotEmpty) {
        showToast('Already added');
      } else {
        Get.find<ProfileCategoriesController>().onSaveTime(
            index, SlotTime.to12Hour(openTime), SlotTime.to12Hour(closeTime));
        onBack();
      }
    } else {
      debugPrint('for individual');
      if (openTime.isEmpty || closeTime.isEmpty) {
        showToast('Please select time');
        return;
      }
      var list = Get.find<IndividualProfileController>().timesList;
      var index = dayList.indexOf(dayName);
      debugPrint(index.toString());
      var exist = list.where((element) => element.day == index);
      if (exist.isNotEmpty) {
        showToast('Already added');
      } else {
        Get.find<IndividualProfileController>().onSaveTime(
            index, SlotTime.to12Hour(openTime), SlotTime.to12Hour(closeTime));
        onBack();
      }
    }
  }

  void onUpdateDayName(String name) {
    dayName = name;
    update();
  }

  void onDeleteTime() {
    if (userType == true) {
      debugPrint('for salon');
      if (openTime.isEmpty || closeTime.isEmpty) {
        showToast('Please select time');
        return;
      }
      var index = dayList.indexOf(dayName);

      Get.find<ProfileCategoriesController>()
          .deleteOpeningHours(index, openTime, closeTime);
      onBack();
    } else {
      debugPrint('for individual');
      if (openTime.isEmpty || closeTime.isEmpty) {
        showToast('Please select time');
        return;
      }
      var index = dayList.indexOf(dayName);

      Get.find<IndividualProfileController>()
          .deleteOpeningHours(index, openTime, closeTime);
      onBack();
    }
  }

  void onUpdateTime() {
    if (userType == true) {
      debugPrint('for salon');
      if (openTime.isEmpty || closeTime.isEmpty) {
        showToast('Please select time');
        return;
      }
      var index = dayList.indexOf(dayName);

      Get.find<ProfileCategoriesController>().updateTime(
          index, SlotTime.to12Hour(openTime), SlotTime.to12Hour(closeTime));
      onBack();
    } else {
      debugPrint('for individual');
      if (openTime.isEmpty || closeTime.isEmpty) {
        showToast('Please select time');
        return;
      }
      var index = dayList.indexOf(dayName);

      Get.find<IndividualProfileController>().updateTime(
          index, SlotTime.to12Hour(openTime), SlotTime.to12Hour(closeTime));
      onBack();
    }
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }
}
