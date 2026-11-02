import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/product/util/product_auth_constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class ProductAuthParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  ProductAuthParser({
    required this.sharedPreferencesManager,
    required this.apiService,
  });

  String get token => sharedPreferencesManager.getString('token') ?? '';

  Future<Response> _postFirst(List<String> paths, dynamic body) async {
    Response? last;
    for (final path in paths) {
      last = await apiService.postPublic(path, body);
      if (last.statusCode == 200) return last;
    }
    return last ?? const Response(statusCode: 404);
  }

  Future<Response> _getOrPost(List<String> paths, [dynamic body]) async {
    Response? last;
    for (final path in paths) {
      last = await apiService.getPublic(path);
      if (last.statusCode == 200) return last;
    }
    for (final path in paths) {
      last = await apiService.postPublic(path, body ?? <String, dynamic>{});
      if (last.statusCode == 200) return last;
    }
    return last ?? const Response(statusCode: 404);
  }

  Future<Response> getSignupForm() {
    return _getOrPost([
      ProductAuthConstants.getSignupForm,
      ProductAuthConstants.getSignupFormAlias,
    ]);
  }

  Future<Response> signup(dynamic body) {
    return _postFirst(ProductAuthConstants.signupAliases, body);
  }

  Future<Response> verifyEmail(dynamic body) {
    return _postFirst([
      ProductAuthConstants.verifyEmail,
      ProductAuthConstants.verifyEmailAlias,
    ], body);
  }

  Future<Response> confirmEmailOtp(dynamic body) {
    return apiService.postPublic(ProductAuthConstants.confirmOtp, body);
  }

  Future<Response> checkPhoneExist(dynamic body) {
    return _postFirst([
      ProductAuthConstants.checkPhoneExist,
      ProductAuthConstants.checkPhoneExistAlias,
    ], body);
  }

  Future<Response> verifyPhone(dynamic body) {
    return _postFirst([
      ProductAuthConstants.verifyPhone,
      ProductAuthConstants.verifyPhoneAlias,
    ], body);
  }

  Future<Response> uploadImage(XFile data) async {
    Response last = await apiService.uploadFiles(
        ProductAuthConstants.uploadImage, [MultipartBody('image', data)]);
    if (last.statusCode == 200) return last;
    last = await apiService.uploadFiles(
        ProductAuthConstants.uploadImageAlias, [MultipartBody('image', data)]);
    if (last.statusCode == 200) return last;
    return apiService
        .uploadFiles(AppConstants.uploadImage, [MultipartBody('image', data)]);
  }

  Future<Response> login(dynamic body) {
    return _postFirst([
      ProductAuthConstants.login,
      ProductAuthConstants.loginAlias,
    ], body);
  }

  Future<Response> loginWithPhonePassword(dynamic body) {
    return _postFirst([
      ProductAuthConstants.loginWithPhonePassword,
      ProductAuthConstants.loginWithPhonePasswordAlias,
    ], body);
  }

  Future<Response> loginWithMobileOtp(dynamic body) {
    return _postFirst([
      ProductAuthConstants.loginWithMobileOtp,
      ProductAuthConstants.loginWithMobileOtpAlias,
    ], body);
  }

  Future<Response> verifyPhoneForFirebase(dynamic body) {
    return _postFirst([
      ProductAuthConstants.verifyPhoneForFirebase,
      ProductAuthConstants.verifyPhoneForFirebaseAlias,
    ], body);
  }

  Future<Response> forgotPassword(dynamic body) {
    return _postFirst(ProductAuthConstants.forgotPasswordAliases, body);
  }

  Future<Response> verifyOtpReset(dynamic body) {
    return _postFirst([
      ProductAuthConstants.verifyOtpReset,
      ProductAuthConstants.verifyOtpResetAlias,
    ], body);
  }

  Future<Response> resetPassword(dynamic body) {
    return _postFirst(ProductAuthConstants.resetPasswordAliases, body);
  }

  Future<Response> changePassword(dynamic body) async {
    Response last = await apiService.postPrivate(
        ProductAuthConstants.changePassword, body, token);
    if (last.statusCode == 200) return last;
    last = await apiService.postPrivate(
        ProductAuthConstants.changePasswordAlias, body, token);
    return last;
  }

  Future<Response> getActiveCountries({String? country, String? lang}) async {
    var uri = AppConstants.getActiveCountries;
    final qs = <String>[];
    if (country != null && country.isNotEmpty) qs.add('country=$country');
    if (lang != null && lang.isNotEmpty) qs.add('lang=$lang');
    if (qs.isNotEmpty) uri = '$uri?${qs.join('&')}';
    final getRes = await apiService.getPublic(uri);
    if (getRes.statusCode == 200) return getRes;
    return apiService.postPublic(AppConstants.getActiveCountries, {
      if (country != null && country.isNotEmpty) 'country': country,
      if (lang != null && lang.isNotEmpty) 'lang': lang,
    });
  }

  Future<Response> getActiveStates(String country) async {
    final qs =
        '${AppConstants.getActiveStates}?country=$country';
    final getRes = await apiService.getPublic(qs);
    if (getRes.statusCode == 200) return getRes;
    return apiService.postPublic(AppConstants.getActiveStates, {
      'country': country,
    });
  }

  Future<Response> getActiveCities(String country, {int? stateId}) async {
    final qs = StringBuffer('${AppConstants.getHomeCities}?country=$country');
    if (stateId != null) qs.write('&state_id=$stateId');
    final getRes = await apiService.getPublic(qs.toString());
    if (getRes.statusCode == 200) return getRes;
    return apiService.postPublic(AppConstants.getHomeCities, {
      'country': country,
      if (stateId != null) 'state_id': stateId,
    });
  }
}
