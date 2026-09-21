import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/coupons_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/coupons_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class CouponsController extends GetxController implements GetxService {
  final CouponsParser parser;

  var isLoading = true.obs;
  var coupons = <CouponModel>[].obs;
  var partnerServices = <OfferServiceModel>[].obs;
  var loadingServices = false.obs;

  CouponsController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    fetchAllCoupons();
    fetchPartnerServices();
  }

  List<CouponModel> _parseOfferList(dynamic data) {
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((json) => CouponModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  void _sortOffers(List<CouponModel> list) {
    list.sort((a, b) {
      try {
        final dateA = DateTime.tryParse(a.expire) ?? DateTime(1970);
        final dateB = DateTime.tryParse(b.expire) ?? DateTime(1970);
        return dateB.compareTo(dateA);
      } catch (_) {
        return 0;
      }
    });
  }

  Future<void> fetchAllCoupons() async {
    isLoading.value = true;
    try {
      final response = await parser.getStores();

      if (response.statusCode == 200) {
        final couponList = _parseOfferList(response.body['data']);
        _sortOffers(couponList);
        coupons.value = couponList;
      } else {
        Get.snackbar('Error', 'Failed to fetch offers',
            backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> fetchPartnerServices() async {
    loadingServices.value = true;
    try {
      final response = await parser.getPartnerServices({"uid": parser.uid});
      if (response.statusCode == 200 && response.body is Map) {
        final body = Map<String, dynamic>.from(response.body);
        final code = body['currencyCode']?.toString() ??
            body['currency']?.toString();
        final symbol = body['currencySymbol']?.toString();
        if (code != null &&
            code.isNotEmpty &&
            Get.isRegistered<SharedPreferencesManager>()) {
          CurrencyHelper.save(
            Get.find<SharedPreferencesManager>(),
            CurrencyHelper.fromCurrencyCode(code, symbol: symbol),
          );
        }
        if (body['data'] is List) {
          partnerServices.value = (body['data'] as List)
              .whereType<Map>()
              .map((item) =>
                  OfferServiceModel.fromJson(Map<String, dynamic>.from(item)))
              .where((service) => service.status == 1)
              .toList();
        }
      }
    } catch (_) {
      partnerServices.clear();
    } finally {
      loadingServices.value = false;
      update();
    }
  }

  Future<CouponModel?> fetchOfferById(int id) async {
    final response = await parser.getCouponByID({
      "id": id,
      "uid": parser.uid,
    });
    if (response.statusCode == 200 && response.body['data'] is Map) {
      return CouponModel.fromJson(
          Map<String, dynamic>.from(response.body['data']));
    }
    return null;
  }

  Map<String, dynamic> _offerBody(CouponModel coupon, {bool includeId = false}) {
    return {
      if (includeId) "id": coupon.id,
      "uid": parser.uid,
      "name": coupon.name,
      "short_descriptions": coupon.shortDescription,
      "code": coupon.code,
      "type": coupon.type,
      "discount": coupon.discount,
      "upto": coupon.upto,
      "start_date": coupon.startDate,
      "expire": coupon.expire,
      "max_usage": coupon.maxUsage,
      "min_cart_value": coupon.minCartValue,
      "service_ids": coupon.serviceIdsPayload,
    };
  }

  Future<void> createCoupons(CouponModel coupon) async {
    Get.dialog(
      SimpleDialog(
        children: [
          Row(
            children: [
              const SizedBox(width: 30),
              const CircularProgressIndicator(color: ThemeProvider.appColor),
              const SizedBox(width: 30),
              SizedBox(
                child: Text(
                  "Please wait".tr,
                  style: const TextStyle(fontFamily: 'bold'),
                ),
              ),
            ],
          )
        ],
      ),
      barrierDismissible: false,
    );

    final response = await parser.createCoupons(_offerBody(coupon));
    Get.back();
    if (response.statusCode == 200 && response.body['success'] == true) {
      successToast('Your offer was submitted successfully');
      fetchAllCoupons();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> updateCoupon(CouponModel coupon) async {
    isLoading.value = true;
    final response =
        await parser.updateCoupons(_offerBody(coupon, includeId: true));
    if (response.statusCode == 200 && response.body['success'] == true) {
      successToast('Your offer was updated successfully');
    } else {
      ApiChecker.checkApi(response);
    }
    await fetchAllCoupons();
  }

  Future<void> toggleStatus(CouponModel coupon) async {
    final nextStatus = coupon.status == 1 ? 0 : 1;
    final response = await parser.updateStatus({
      "id": coupon.id,
      "status": nextStatus,
    });
    if (response.statusCode == 200 && response.body['success'] == true) {
      final index = coupons.indexWhere((item) => item.id == coupon.id);
      if (index != -1) {
        coupons[index] = coupon.copyWith(status: nextStatus);
        coupons.refresh();
      }
      successToast(nextStatus == 1 ? 'Offer activated' : 'Offer deactivated');
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> deleteCoupons(int? id) async {
    if (id == null) return;
    isLoading.value = true;
    final response = await parser.deleteCoupons({"id": id});
    if (response.statusCode == 200 && response.body['success'] == true) {
      successToast('Your offer was deleted successfully');
      coupons.removeWhere((element) => element.id == id);
    } else {
      ApiChecker.checkApi(response);
    }
    isLoading.value = false;
    update();
  }

  void onBack() {
    Navigator.of(Get.context as BuildContext).pop(true);
  }
}
