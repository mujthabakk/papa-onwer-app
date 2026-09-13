/*Papabear*/
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class CancelAllParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  CancelAllParser(
      {required this.sharedPreferencesManager, required this.apiService});

  Future<Response> onCreateProducts(dynamic body) async {
    var response = await apiService.postPrivate(AppConstants.createPackages,
        body, sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> markHoliday(String date, int status) async {
    var response;

    print('status $status');

    response = await apiService.postPrivate(
        AppConstants.markHoliday,
        {"uid": getUID(), "date": date, "status": status},
        sharedPreferencesManager.getString('token') ?? '');

    return response;
  }

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '';
  }

  Future<Response> uploadImage(XFile data) async {
    return await apiService
        .uploadFiles(AppConstants.uploadImage, [MultipartBody('image', data)]);
  }

  Future<Response> getByID(var body) async {
    var response = await apiService.postPrivate(AppConstants.getPackagesById,
        body, sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> getCalendarView() async {
    return await apiService.postPrivate(
        AppConstants.calendarView,
        {'id': getUId(), "type": getType()},
        sharedPreferencesManager.getString('token') ?? '');
  }

  Future<Response> getByDate(var body) async {
    return await apiService.postPrivate(AppConstants.getByDate, body,
        sharedPreferencesManager.getString('token') ?? '');
  }

  Future<Response> cancelAllAppointments(var body) async {
    var response = await apiService.postPrivate(
        AppConstants.cancelAllAppointments,
        body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  bool getType() {
    return sharedPreferencesManager.getString('type') == 'salon' ? true : false;
  }

  String getUId() {
    return sharedPreferencesManager.getString('uid') ?? '';
  }

  Future<Response> updatePackages(var body) async {
    var response = await apiService.postPrivate(AppConstants.packagesUpdate,
        body, sharedPreferencesManager.getString('token') ?? '');
    return response;
  }
}
