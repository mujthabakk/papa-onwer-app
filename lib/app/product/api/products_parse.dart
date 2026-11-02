import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/product/util/product_user.dart';

class ProductsParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  ProductsParser(
      {required this.sharedPreferencesManager, required this.apiService});

  String get token => sharedPreferencesManager.getString('token') ?? '';

  bool isProductUser() => ProductUser.isProduct(sharedPreferencesManager);

  Map<String, dynamic> ownerBody() {
    final uid = int.tryParse(getFreelancerId()) ?? getFreelancerId();
    return {
      'id': uid,
      'product_id': uid,
      'product_user_id': uid,
      'uid': uid,
      'freelacer_id': uid,
      'freelancer_id': uid,
    };
  }

  Future<Response> getProductHome() async {
    return apiService.postPrivate(
      AppConstants.productsGetList,
      ownerBody(),
      token,
    );
  }

  Future<Response> getProductWFreelancer(var body) async {
    return apiService.postPrivate(AppConstants.productsGetList, body, token);
  }

  Future<Response> addStock(dynamic body) {
    return apiService.postPrivate(AppConstants.productsAddStock, body, token);
  }

  Future<Response> getProductById(dynamic id) {
    return apiService.postPrivate(
      AppConstants.getProductById,
      {'id': id, 'product_id': id},
      token,
    );
  }

  Future<Response> updateProductStatus(var body) async {
    return apiService.postPrivate(
        AppConstants.productsUpdateStatus, body, token);
  }

  Future<Response> updateProductHome(var body) async {
    return apiService.postPrivate(
        AppConstants.productsUpdateHome, body, token);
  }

  Future<Response> getProductHistory(dynamic id) async {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    String ymd(DateTime date) =>
        '${date.year}-${two(date.month)}-${two(date.day)}';
    final body = {
      'product_id': id,
      'catalog_product_id': id,
      'item_id': id,
      'start_date': ymd(DateTime(now.year - 1, now.month, now.day)),
      'end_date': ymd(DateTime(now.year + 1, now.month, now.day)),
    };
    return apiService.postPrivate(
      AppConstants.productHistoryGetByProduct,
      body,
      token,
    );
  }

  Future<Response> destroyProduct(var body) async {
    return apiService.postPrivate(AppConstants.destroyProduct, body, token);
  }

  String getFreelancerId() {
    return sharedPreferencesManager.getString('uid') ?? '';
  }

  Future<Response> onUpdateProducts(var body) async {
    return apiService.postPrivate(AppConstants.updateProduct, body, token);
  }

  String getCurrencyCode() {
    return sharedPreferencesManager.getString('currencyCode') ??
        AppConstants.defaultCurrencyCode;
  }

  String getCurrencySide() {
    return sharedPreferencesManager.getString('currencySide') ??
        AppConstants.defaultCurrencySide;
  }

  String getCurrencySymbol() {
    return CurrencyHelper.displaySymbol(sharedPreferencesManager);
  }
}
