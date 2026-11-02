import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class CreateProductsParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  CreateProductsParser(
      {required this.sharedPreferencesManager, required this.apiService});

  String get token => sharedPreferencesManager.getString('token') ?? '';

  Future<Response> onCreateProducts(dynamic body) async {
    return apiService.postPrivate(AppConstants.createProducts, body, token);
  }

  Future<Response> createMultiple(dynamic body) async {
    return apiService.postPrivate(
        AppConstants.createProductsMany, body, token);
  }

  Future<Response> uploadImage(XFile data) async {
    Response last = await apiService
        .uploadFiles(AppConstants.uploadImage, [MultipartBody('image', data)]);
    if (last.statusCode == 200) return last;
    return apiService.uploadFiles(
        AppConstants.productsUploadImages, [MultipartBody('images[]', data)]);
  }

  String getFreelancerId() {
    return sharedPreferencesManager.getString('uid') ?? '';
  }

  Future<Response> getProductById(String id) async {
    return apiService.postPrivate(
      AppConstants.getProductById,
      {"id": id, "product_id": id},
      token,
    );
  }

  Future<Response> updateProducts(var body) async {
    return apiService.postPrivate(AppConstants.updateProduct, body, token);
  }

  Future<Response> getForm() async {
    final post = await apiService.postPrivate(
        AppConstants.productsGetForm, {}, token);
    if (post.statusCode == 200) return post;
    return apiService.getPrivate(AppConstants.productsGetForm, token);
  }

  Future<Response> getPaymentMethods() async {
    final post = await apiService.postPrivate(
        AppConstants.productsGetPaymentMethods, {}, token);
    if (post.statusCode == 200) return post;
    return apiService.getPrivate(AppConstants.productsGetPaymentMethods, token);
  }

  Future<Response> getMeasurements() async {
    // PDF: units/getAll then product_measurements/getAll for Unit dropdown.
    Response last =
        await apiService.postPrivate(AppConstants.unitsGetAll, {}, token);
    if (last.statusCode == 200) return last;
    last = await apiService.getPrivate(AppConstants.unitsGetAll, token);
    if (last.statusCode == 200) return last;
    last = await apiService.postPrivate(
        AppConstants.productMeasurementsGetAll, {}, token);
    if (last.statusCode == 200) return last;
    last = await apiService.getPrivate(
        AppConstants.productMeasurementsGetAll, token);
    if (last.statusCode == 200) return last;
    last =
        await apiService.postPrivate(AppConstants.productsGetUnits, {}, token);
    if (last.statusCode == 200) return last;
    return apiService.getPrivate(AppConstants.productsGetUnits, token);
  }
}
