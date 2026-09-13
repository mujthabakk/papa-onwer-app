import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class NotificationParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  NotificationParser(
      {required this.apiService, required this.sharedPreferencesManager});

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '';
  }

  Future<Response> getAllNotification(var uid) async {
    return await apiService.postPrivate(AppConstants.commonNotificationAll,
        {'uid': uid}, sharedPreferencesManager.getString('token') ?? '');
  }

  Future<Response> readNotification(var uid) async {
    return await apiService.postPrivate(AppConstants.readNotificationAll,
        {'id': uid}, sharedPreferencesManager.getString('token') ?? '');
  }
}
