import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_timing_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_individual_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_business_controller.dart';
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
      openTime = Get.arguments[2];
      closeTime = Get.arguments[3];
      update();
    }
  }

  Future<void> openTimePicker() async {
    var context = Get.context as BuildContext;
    TimeOfDay initialTime = TimeOfDay.now();
    TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        initialEntryMode: TimePickerEntryMode.input);
    DateTime dateTime = DateTime(2020, 10, 19, pickedTime!.hour, pickedTime.minute);
    openTime = Jiffy.parseFromDateTime(dateTime).format(pattern: "H:mm");
    update();
  }

  Future<void> closeTimePicker() async {
    var context = Get.context as BuildContext;
    TimeOfDay initialTime = TimeOfDay.now();
    TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        initialEntryMode: TimePickerEntryMode.input);
    DateTime dateTime = DateTime(2020, 10, 19, pickedTime!.hour, pickedTime.minute);
    closeTime = Jiffy.parseFromDateTime(dateTime).format(pattern: "H:mm");
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
        Get.find<ProfileCategoriesController>()
            .onSaveTime(index, openTime, closeTime);
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
        Get.find<IndividualProfileController>()
            .onSaveTime(index, openTime, closeTime);
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

      Get.find<ProfileCategoriesController>()
          .updateTime(index, openTime, closeTime);
      onBack();
    } else {
      debugPrint('for individual');
      if (openTime.isEmpty || closeTime.isEmpty) {
        showToast('Please select time');
        return;
      }
      var index = dayList.indexOf(dayName);

      Get.find<IndividualProfileController>()
          .updateTime(index, openTime, closeTime);
      onBack();
    }
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }
}
