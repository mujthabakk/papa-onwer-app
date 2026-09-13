import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:get/get.dart';

class ServicesNamesParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  ServicesNamesParser(
      {required this.sharedPreferencesManager, required this.apiService});

  Future<Response> selectCategories(var body) async {
    var response = await apiService.postPrivate(
        AppConstants.getServicesByIDList,
        body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> individualCategories(var body) async {
    var response = await apiService.postPrivate(
        AppConstants.getIndividualCategories,
        body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  // int getCatId() {
  //   return sharedPreferencesManager.getInt('catID') ?? 0;
  // }

  bool getType() {
    return sharedPreferencesManager.getString('type') == 'salon' ? true : false;
  }

  // Future<Response> updateCate(String cateIds) async {
  //   var response = await apiService.postPrivate(
  //       AppConstants.salonUpdate,
  //       {"id": sharedPreferencesManager.getString('id'), "categories": cateIds},
  //       sharedPreferencesManager.getString('token') ?? '');
  //   return response;
  // }
}
