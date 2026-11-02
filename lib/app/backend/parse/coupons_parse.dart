import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/product/util/product_user.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class CouponsParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  CouponsParser(
      {required this.sharedPreferencesManager, required this.apiService});

  String get token => sharedPreferencesManager.getString('token') ?? '';

  int get uid => int.tryParse(getUID()) ?? 0;

  dynamic get partnerId => uid;

  bool get isProductUser => ProductUser.isProduct(sharedPreferencesManager);

  String get _create =>
      isProductUser ? AppConstants.productCouponsCreate : AppConstants.couponsCreate;
  String get _update =>
      isProductUser ? AppConstants.productCouponsUpdate : AppConstants.couponsUpdate;
  String get _destroy => isProductUser
      ? AppConstants.productCouponsDestroy
      : AppConstants.couponsDestroy;
  String get _getById => isProductUser
      ? AppConstants.productCouponsgetById
      : AppConstants.couponsgetById;
  String get _getByUserId => isProductUser
      ? AppConstants.productCouponsgetByUserId
      : AppConstants.couponsgetByUserId;
  String get _getStores => isProductUser
      ? AppConstants.productCouponsGetStores
      : AppConstants.couponsGetStores;
  String get _getAll =>
      isProductUser ? AppConstants.productCouponsGetAll : AppConstants.couponsGetAll;
  String get _getActive => isProductUser
      ? AppConstants.productCouponsGetActive
      : AppConstants.couponsGetActive;
  String get _updateStatus => isProductUser
      ? AppConstants.productCouponsUpdateStatus
      : AppConstants.couponsUpdateStatus;
  String get _partnerItems => isProductUser
      ? AppConstants.productCouponsGetPartnerProducts
      : AppConstants.couponsGetPartnerServices;

  Future<Response> createCoupons(dynamic body, {XFile? image}) async {
    if (image != null) {
      return apiService.postPrivateMultipart(
        _create,
        Map<String, dynamic>.from(body),
        token,
        file: image,
      );
    }
    return apiService.postPrivate(_create, body, token);
  }

  Future<Response> deleteCoupons(var body) async {
    return apiService.postPrivate(_destroy, body, token);
  }

  Future<Response> getCouponByID(var body) async {
    return apiService.postPrivate(_getById, body, token);
  }

  Future<Response> getCouponByUserID(var body) async {
    return apiService.postPrivate(_getByUserId, body, token);
  }

  Future<Response> getStores() async {
    return apiService.postPrivate(
      _getStores,
      {"uid": uid},
      token,
    );
  }

  Future<Response> getAllCoupons() async {
    return apiService.getPrivate(_getAll, token);
  }

  Future<Response> getActiveCoupons() async {
    return apiService.getPrivate(_getActive, token);
  }

  Future<Response> getListForOffers() async {
    if (isProductUser) {
      return apiService.getPrivate(_getAll, token);
    }
    return apiService.getPrivate(AppConstants.couponsGetListForOffers, token);
  }

  Future<Response> getPartnerServices(var body) async {
    return apiService.postPrivate(_partnerItems, body, token);
  }

  Future<Response> updateCoupons(var body, {XFile? image}) async {
    if (image != null) {
      return apiService.postPrivateMultipart(
        _update,
        Map<String, dynamic>.from(body),
        token,
        file: image,
      );
    }
    return apiService.postPrivate(_update, body, token);
  }

  Future<Response> updateStatus(var body) async {
    return apiService.postPrivate(_updateStatus, body, token);
  }

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '0';
  }
}
