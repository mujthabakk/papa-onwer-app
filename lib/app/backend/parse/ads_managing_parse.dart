/*Papabear*/
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class AdsManagingParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  AdsManagingParser(
      {required this.sharedPreferencesManager, required this.apiService});

  Future<Response> onSubmit(dynamic body) async {
    var response = await apiService.postPrivate(AppConstants.createAds, body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> getServiceByID(var body) async {
    var response = await apiService.postPrivate(AppConstants.getServiceByID,
        body, sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> postDeleteAd(var body) async {
    var response = await apiService.postPrivate(AppConstants.deleteAds, body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> getListAds(var body) async {
    var response = await apiService.postPrivate(AppConstants.listAds, body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> postUpdateAds(var body) async {
    var response = await apiService.postPrivate(AppConstants.updateAds, body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> uploadImage(XFile data) async {
    return await apiService
        .uploadFiles(AppConstants.uploadImage, [MultipartBody('image', data)]);
  }

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '0';
  }
}
