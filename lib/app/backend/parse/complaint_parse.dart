import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class ComplaintParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  ComplaintParser(
      {required this.sharedPreferencesManager, required this.apiService});

  Future<Response> uploadImage(XFile data) async {
    return await apiService
        .uploadFiles(AppConstants.uploadImage, [MultipartBody('image', data)]);
  }

  Future<Response> getComplaintsById(var body) async {
    var response = await apiService.postPrivate(AppConstants.getComplaints,
        body, sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> updateComplaintsById(var body) async {
    var response = await apiService.postPrivate(AppConstants.updateComplaints,
        body, sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  bool getType() {
    return sharedPreferencesManager.getString('type') == 'salon' ? true : false;
  }

  String getUId() {
    return sharedPreferencesManager.getString('uid') ?? '';
  }
}
