import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';


class AddServicesParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  AddServicesParser(
      {required this.sharedPreferencesManager, required this.apiService});

  Future<Response> onSubmit(dynamic body) async {
    var response = await apiService.postPrivate(AppConstants.serviceCreate,
        body, sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> getServiceByID(var body) async {
    var response = await apiService.postPrivate(AppConstants.getServiceByID,
        body, sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> onUpdateService(var body) async {
    var response = await apiService.postPrivate(AppConstants.updateService,
        body, sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> uploadImage(XFile data) async {
    return await apiService
        .uploadFiles(AppConstants.uploadImage, [MultipartBody('image', data)]);
  }

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '0';
  }

  String getCurrencySide() {
    return sharedPreferencesManager.getString('currencySide') ??
        AppConstants.defaultCurrencySide;
  }

  String getCurrencySymbol() {
    return CurrencyHelper.displaySymbol(sharedPreferencesManager);
  }

  double getTax() {
    try {
      return sharedPreferencesManager.getDouble('tax') ?? 0;
    } catch (_) {
      final raw = sharedPreferencesManager.getString('tax');
      return double.tryParse(raw ?? '') ?? 0;
    }
  }
}
