/*Papabear*/
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class StylistCategoriesParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  StylistCategoriesParser(
      {required this.sharedPreferencesManager, required this.apiService});

  // Future<Response> selectCategories() async {
  //   var response = await apiService.getPrivate(AppConstants.categories,
  //       sharedPreferencesManager.getString('token') ?? '');
  //   return response;
  // }

  bool getType() {
    return sharedPreferencesManager.getString('type') == 'salon' ? true : false;
  }

  Future<Response> individualCategories(var body) async {
    var response = await apiService.postPrivate(
        AppConstants.getIndividualCategories,
        body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> selectCategories(var body) async {
    var response = await apiService.postPrivate(
        AppConstants.getSelectedCategories,
        body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  Future<Response> selectServices(var body) async {
    var response = await apiService.postPrivate(
        AppConstants.getServicesByIDList,
        body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }
}
