import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/products_categories_model.dart';
import 'package:ultimate_salon_owner_flutter/app/product/api/shop_categories_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/create_products_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class ShopCategoriesController extends GetxController implements GetxService {
  final ShopCategoriesParser parser;

  String title = 'Products Categories'.tr;

  List<ProductsCategoriesModel> _productsList = <ProductsCategoriesModel>[];
  List<ProductsCategoriesModel> get productList => _productsList;

  String selectedProducts = '';
  String selectedProductsName = '';

  bool apiCalled = false;

  ShopCategoriesController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    selectedProducts = Get.arguments[0].toString();
    getAllProductsCate();
  }

  Future<void> getAllProductsCate() async {
    var response = await parser.getAllProductsCate();
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'] ?? myMap['categories'];
      _productsList = [];
      if (body is List) {
        for (final data in body) {
          if (data is! Map) continue;
          _productsList.add(ProductsCategoriesModel.fromJson(
              Map<String, dynamic>.from(data)));
        }
      }
      debugPrint(productList.length.toString());
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void saveProductsCate(String id) {
    selectedProducts = id;
    var name =
        _productsList.firstWhere((element) => element.id.toString() == id).name;
    selectedProductsName = name as String;
    debugPrint(selectedProducts = id);
    update();
  }

  void saveAndClose() {
    debugPrint(selectedProducts.toString());
    debugPrint(selectedProductsName.toString());
    Get.find<CreateProductsController>()
        .onSaveproductCate(selectedProducts, selectedProductsName);
    onBack();
  }

  Future<void> createCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      showToast('Please enter a category name');
      return;
    }
    final response = await parser.createCategory({'name': trimmed, 'status': 1});
    if (response.statusCode == 200) {
      await getAllProductsCate();
      showToast('Category created');
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void openCreateDialog() {
    final name = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('Create Category'.tr),
        content: TextField(
          controller: name,
          decoration: InputDecoration(hintText: 'Name'.tr),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
          TextButton(
            onPressed: () async {
              Get.back();
              await createCategory(name.text);
            },
            child: Text('Save'.tr,
                style: const TextStyle(fontFamily: 'regular', color: ThemeProvider.appColor)),
          ),
        ],
      ),
    );
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }
}
