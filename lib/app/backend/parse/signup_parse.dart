/*Papabear*/
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class SignUpParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  SignUpParser(
      {required this.sharedPreferencesManager, required this.apiService});

  Future<Response> uploadImage(XFile data) async {
    return await apiService
        .uploadFiles(AppConstants.uploadImage, [MultipartBody('image', data)]);
  }

  Future<Response> verifyEmail(dynamic body) async {
    var response = await apiService.postPublic(AppConstants.verifyEmail, body);
    return response;
  }

  Future<Response> verifyPhone(dynamic body) async {
    var response =
        await apiService.postPublic(AppConstants.verifyPhoneRegister, body);
    return response;
  }

  Future<Response> verifyOTP(dynamic param) async {
    return await apiService.postPublic(AppConstants.verifyOTPEmail, param);
  }

  String getSMSName() {
    return sharedPreferencesManager.getString('smsName') ??
        AppConstants.defaultSMSGateway;
  }

  Future<Response> getActiveCountries({String? country, String? lang}) async {
    var uri = AppConstants.getActiveCountries;
    final qs = <String>[];
    if (country != null && country.isNotEmpty) {
      qs.add('country=$country');
    }
    if (lang != null && lang.isNotEmpty) {
      qs.add('lang=$lang');
    }
    if (qs.isNotEmpty) {
      uri = '$uri?${qs.join('&')}';
    }
    return await apiService.getPublic(uri);
  }

  Future<Response> getActiveCities(String country) async {
    return await apiService.getPublic(
        '${AppConstants.getHomeCities}?country=$country');
  }

  Future<Response> getHomeCities() async {
    return getActiveCities('IN');
  }

  Future<Response> checkPhoneExist(dynamic body) async {
    var response =
        await apiService.postPublic(AppConstants.checkPhoneExist, body);
    return response;
  }

  Future<Response> saveMyRequest(dynamic body) async {
    var response =
        await apiService.postPublic(AppConstants.saveMyRequest, body);
    return response;
  }
}
