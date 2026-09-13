/*Papabear*/
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class FacilitiesParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  FacilitiesParser(
      {required this.sharedPreferencesManager, required this.apiService});

  Future<Response> getFacilities() async {
    var response = await apiService.postPrivate(
        AppConstants.getAllFacilities,
        {"uid": sharedPreferencesManager.getString('uid')},
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  bool getType() {
    return sharedPreferencesManager.getString('type') == 'salon' ? true : false;
  }

  Future<UpdateCateResult> updateCate(String cateIds) async {
    var response;

    if (getType()) {
      response = await apiService.postPrivate(
          AppConstants.salonUpdate,
          {
            "id": sharedPreferencesManager.getString('id'),
            "facilities": cateIds
          },
          sharedPreferencesManager.getString('token') ?? '');
    } else {
      response = await apiService.postPrivate(
          AppConstants.updateIndividual,
          {
            "id": sharedPreferencesManager.getString('id'),
            "facilities": cateIds
          },
          sharedPreferencesManager.getString('token') ?? '');
    }

    return UpdateCateResult(response, getType());
  }
}

class UpdateCateResult {
  final Response response;
  final bool type;

  UpdateCateResult(this.response, this.type);
}
