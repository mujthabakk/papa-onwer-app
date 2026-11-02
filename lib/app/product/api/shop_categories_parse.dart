/*Papabear*/
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:get/get.dart';

class ShopCategoriesParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  ShopCategoriesParser(
      {required this.sharedPreferencesManager, required this.apiService});

  String get token => sharedPreferencesManager.getString('token') ?? '';

  Future<Response> getAllProductsCate() async {
    const paths = [
      AppConstants.productCategoriesGetAll,
      AppConstants.getAllProductsCate,
    ];
    Response? last;
    for (final path in paths) {
      last = await apiService.postPrivate(path, {}, token);
      if (last.statusCode == 200) return last;
    }
    for (final path in paths) {
      last = await apiService.getPrivate(path, token);
      if (last.statusCode == 200) return last;
    }
    return last ?? const Response(statusCode: 404);
  }

  Future<Response> createCategory(Map<String, dynamic> body) async {
    return apiService.postPrivate(
        AppConstants.productCategoriesCreate, body, token);
  }
}
