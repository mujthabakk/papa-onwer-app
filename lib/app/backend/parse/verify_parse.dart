import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/product/api/product_auth_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class VerifyParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  VerifyParser(
      {required this.sharedPreferencesManager, required this.apiService});

  ProductAuthParser get _productAuth => Get.find<ProductAuthParser>();

  Future<Response> resetWithOTPMail(dynamic param) async {
    final product = await _productAuth.forgotPassword(param);
    if (product.statusCode == 200) return product;
    return await apiService.postPublic(AppConstants.resetWithEmail, param);
  }

  Future<Response> verifyOTP(dynamic param) async {
    final product = await _productAuth.verifyOtpReset(param);
    if (product.statusCode == 200) return product;
    return await apiService.postPublic(AppConstants.verifyOTPForReset, param);
  }

  Future<Response> updatePassword(var param, String token) async {
    final product = await _productAuth.resetPassword(param);
    if (product.statusCode == 200) return product;
    return await apiService.postPrivate(
        AppConstants.updatePasswordWithToken, param, token);
  }
}
