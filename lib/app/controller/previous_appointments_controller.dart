import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/previous_appointments_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/previous_appointments_parse.dart';

class PreviousAppointmentController extends GetxController {
  final PreviousAppointmentsParser parser;
  String salonUid = '';
  String cover = '';
  String selectedCategories = '';
  String selectedServices = '';
  List<String> savedCategories = [];
  List<String> savedServices = [];
  int salonId = 0;
  int uid = 0;
  int freelancerId = 0;
  bool apiCalled = false;

  List<PreviousAppointmentModel> _previousAppointmentInfo =
      <PreviousAppointmentModel>[];
  List<PreviousAppointmentModel> get previousAppointmentInfo =>
      _previousAppointmentInfo;
  String action = 'search';

  PreviousAppointmentController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments.isNotEmpty) {
      if (Get.arguments[0] == 'direct') {
        action = 'direct';
        uid = Get.arguments[1] as int;
        salonId = Get.arguments[2] as int;
        freelancerId = Get.arguments[3] as int;
        getAppointmentHistory(uid, salonId, freelancerId);
      } else {
        apiCalled = false; // Set to false initially if needed
      }
    } else {
      apiCalled = false; // Set to false initially if needed
    }
  }

  Future<void> getAppointmentHistory(
      int uid, int salonId, int freelancerId) async {
    apiCalled = true;
    update(); // Notify UI to show the loading indicator
    var response = await parser.getPreviousAppointmentDetails(
        {"uid": uid, "salon_id": salonId, "freelancer_id": freelancerId});
    apiCalled = false;
    if (response.statusCode == 200) {
      debugPrint(response.bodyString);
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'];
      _previousAppointmentInfo = [];
      body.forEach((element) {
        PreviousAppointmentModel salon =
            PreviousAppointmentModel.fromJson(element);
        _previousAppointmentInfo.add(salon);
      });
      _previousAppointmentInfo = _previousAppointmentInfo.reversed.toList();
    } else {
      ApiChecker.checkApi(response);
    }
    update(); // Notify UI to update after data is loaded
  }

  // void onBack() {
  //   var context = Get.context as BuildContext;
  //   Navigator.of(context).pop(true);
  // }
}
