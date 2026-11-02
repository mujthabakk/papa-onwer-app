import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/product_detail_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/products_model.dart';
import 'package:ultimate_salon_owner_flutter/app/product/api/products_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/create_products_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class ProductsController extends GetxController implements GetxService {
  final ProductsParser parser;

  bool apiCalled = false;

  List<ProductsModel> _productsInfo = <ProductsModel>[];
  List<ProductsModel> get productsInfo => _productsInfo;

  String currencySide = AppConstants.defaultCurrencySide;
  String currencySymbol = AppConstants.defaultCurrencySymbol;

  ProductsController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    getProductWFreelancer();
    currencySide = parser.getCurrencySide();
    currencySymbol = parser.getCurrencySymbol();
  }

  Future<void> getProductWFreelancer() async {
    apiCalled = true;
    Response response = await parser.getProductHome();
    if (response.statusCode != 200) {
      response = await parser.getProductWFreelancer(parser.ownerBody());
    }
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      dynamic product = myMap['data'];
      if (product is Map) {
        product = product['products'] ?? product['data'];
      }
      _productsInfo = [];
      if (product is List) {
        for (final data in product) {
          if (data is! Map) continue;
          _productsInfo
              .add(ProductsModel.fromJson(Map<String, dynamic>.from(data)));
        }
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> destroyProduct(int id) async {
    var param = {"id": id, "product_id": id};
    var response = await parser.destroyProduct(param);
    if (response.statusCode == 200) {
      getProductWFreelancer();
      showToast('item remove successfully');
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> updateStatus(int id, int status) async {
    var body = {"status": status == 1 ? 0 : 1, "id": id, "product_id": id};
    var response = await parser.updateProductStatus(body);
    if (response.statusCode == 200) {
      debugPrint(response.bodyString);
      successToast('Updated');
      getProductWFreelancer();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void onCreateProducts() {
    Get.delete<CreateProductsController>(force: true);
    Get.toNamed(AppRouter.getCreateProductsRoute(), arguments: ['create']);
  }

  void onUpdateProducts(int id) {
    Get.delete<CreateProductsController>(force: true);
    Get.toNamed(AppRouter.getCreateProductsRoute(), arguments: ['update', id]);
  }

  void onOpenDetail(int id) {
    Get.delete<ProductDetailController>(force: true);
    Get.toNamed(AppRouter.getProductDetailRoute(), arguments: id);
  }

  Future<void> addStock(int id, {int? qty, int? setQty, int? variantId}) async {
    final body = <String, dynamic>{
      'id': id,
      'product_id': id,
      if (qty != null) 'qty': qty,
      if (setQty != null) 'set_qty': setQty,
      if (variantId != null) 'variant_id': variantId,
    };
    final response = await parser.addStock(body);
    if (response.statusCode == 200) {
      successToast('Stock updated'.tr);
      getProductWFreelancer();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void onAddStock(int id, {int current = 0}) {
    final qty = TextEditingController();
    final setQty = TextEditingController(text: current.toString());
    Get.dialog(
      AlertDialog(
        title: Text('Update Stock'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qty,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Add qty (+/-)'.tr),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: setQty,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Set qty'.tr),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
          TextButton(
            onPressed: () {
              final add = int.tryParse(qty.text.trim());
              final absolute = int.tryParse(setQty.text.trim());
              Get.back();
              if (add != null && add != 0) {
                addStock(id, qty: add);
              } else if (absolute != null) {
                addStock(id, setQty: absolute);
              }
            },
            child: Text('Save'.tr,
                style: const TextStyle(fontFamily: 'regular', color: ThemeProvider.appColor)),
          ),
        ],
      ),
    );
  }
}
