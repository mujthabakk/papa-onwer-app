import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class CouponsParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  CouponsParser(
      {required this.sharedPreferencesManager, required this.apiService});

  String get token => sharedPreferencesManager.getString('token') ?? '';

  int get uid => int.tryParse(getUID()) ?? 0;

  dynamic get partnerId => uid;

  Future<Response> createCoupons(dynamic body, {XFile? image}) async {
    if (image != null) {
      return apiService.postPrivateMultipart(
        AppConstants.couponsCreate,
        Map<String, dynamic>.from(body),
        token,
        file: image,
      );
    }
    return apiService.postPrivate(AppConstants.couponsCreate, body, token);
  }

  Future<Response> deleteCoupons(var body) async {
    return apiService.postPrivate(AppConstants.couponsDestroy, body, token);
  }

  Future<Response> getCouponByID(var body) async {
    return apiService.postPrivate(AppConstants.couponsgetById, body, token);
  }

  Future<Response> getCouponByUserID(var body) async {
    return apiService.postPrivate(AppConstants.couponsgetByUserId, body, token);
  }

  Future<Response> getStores() async {
    return apiService.postPrivate(
      AppConstants.couponsGetStores,
      {"uid": uid},
      token,
    );
  }

  Future<Response> getAllCoupons() async {
    return apiService.getPrivate(AppConstants.couponsGetAll, token);
  }

  Future<Response> getActiveCoupons() async {
    return apiService.getPrivate(AppConstants.couponsGetActive, token);
  }

  Future<Response> getListForOffers() async {
    return apiService.getPrivate(AppConstants.couponsGetListForOffers, token);
  }

  Future<Response> getPartnerServices(var body) async {
    return apiService.postPrivate(
        AppConstants.couponsGetPartnerServices, body, token);
  }

  Future<Response> updateCoupons(var body, {XFile? image}) async {
    if (image != null) {
      return apiService.postPrivateMultipart(
        AppConstants.couponsUpdate,
        Map<String, dynamic>.from(body),
        token,
        file: image,
      );
    }
    return apiService.postPrivate(AppConstants.couponsUpdate, body, token);
  }

  Future<Response> updateStatus(var body) async {
    return apiService.postPrivate(AppConstants.couponsUpdateStatus, body, token);
  }

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '0';
  }
}
