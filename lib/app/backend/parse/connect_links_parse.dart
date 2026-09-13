import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class ConnectLinksParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  ConnectLinksParser({
    required this.sharedPreferencesManager,
    required this.apiService,
  });

  bool isSalon() {
    return sharedPreferencesManager.getString('type') == 'salon';
  }

  String getUid() {
    return sharedPreferencesManager.getString('uid') ?? '';
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? '';
  }

  Future<Response> getProfile() async {
    final body = {'id': getUid()};
    if (isSalon()) {
      return apiService.postPrivate(
          AppConstants.getSalonById, body, getToken());
    }
    return apiService.postPrivate(
        AppConstants.getIndividualProfileById, body, getToken());
  }

  Future<Response> updateLinks(Map<String, dynamic> body) async {
    if (isSalon()) {
      return apiService.postPrivate(
          AppConstants.salonUpdate, body, getToken());
    }
    return apiService.postPrivate(
        AppConstants.updateIndividual, body, getToken());
  }
}
