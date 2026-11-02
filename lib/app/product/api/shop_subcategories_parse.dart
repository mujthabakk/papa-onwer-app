/*Papabear*/
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class ShopSubCategoriesParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  ShopSubCategoriesParser(
      {required this.sharedPreferencesManager, required this.apiService});

  String get token => sharedPreferencesManager.getString('token') ?? '';

  Future<Response> getProductsById(var body) async {
    var payload = body is Map
        ? Map<String, dynamic>.from(body)
        : {'id': body};
    if (payload['cate_id'] == null && payload['id'] != null) {
      payload['cate_id'] = payload['id'];
    }
    var response = await apiService.postPrivate(
        AppConstants.getSubCateById, payload, token);
    if (response.statusCode == 200) return response;
    return apiService.getPrivate(
        '${AppConstants.getSubCateById}?id=${payload['id']}', token);
  }

  Future<Response> createSubCategory(Map<String, dynamic> body) async {
    return apiService.postPrivate(
        AppConstants.productSubCategoriesCreate, body, token);
  }

  void saveId(var id) {
    sharedPreferencesManager.putString('id', id);
  }
}
