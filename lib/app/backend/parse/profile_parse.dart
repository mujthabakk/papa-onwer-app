import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class ProfileParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  ProfileParser(
      {required this.sharedPreferencesManager, required this.apiService});

  bool getType() {
    return sharedPreferencesManager.getString('type') == 'salon' ? true : false;
  }

  Future<Response> logout() async {
    return await apiService.logout(
        AppConstants.logout, sharedPreferencesManager.getString('token') ?? '');
  }

  bool getPremium() {
    return sharedPreferencesManager.getBool('premium');
  }

  Future<Response> getMyReviews() async {
    var response = await apiService.postPublic(AppConstants.getMyReviews,
        {"id": sharedPreferencesManager.getString('uid')});
    return response;
  }

  Future<Response> onDelete() async {
    var response = await apiService.postPublic(AppConstants.getDelete,
        {"uid": sharedPreferencesManager.getString('uid')});
    return response;
  }

  void clearAccount() {
    sharedPreferencesManager.clearKey('first_name');
    sharedPreferencesManager.clearKey('last_name');
    sharedPreferencesManager.clearKey('token');
    sharedPreferencesManager.clearKey('uid');
    sharedPreferencesManager.clearKey('email');
    sharedPreferencesManager.clearKey('cover');
    sharedPreferencesManager.clearKey('name');
    sharedPreferencesManager.clearKey('cancellation_history');
    sharedPreferencesManager.clearKey('background');
    sharedPreferencesManager.clearKey('rating');
    sharedPreferencesManager.clearKey('totalRating');
    sharedPreferencesManager.clearKey('phone');
    sharedPreferencesManager.clearKey('type');
  }

  String getName() {
    return sharedPreferencesManager.getString('name') ?? '';
  }

  String getCover() {
    return sharedPreferencesManager.getString('cover') ?? '';
  }

  String getBackground() {
    return sharedPreferencesManager.getString('background') ?? '';
  }

  double getRating() {
    return sharedPreferencesManager.getDouble('rating') ?? 0;
  }

  String getTotalRating() {
    return sharedPreferencesManager.getString('totalRating') ?? '';
  }

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '';
  }
}
