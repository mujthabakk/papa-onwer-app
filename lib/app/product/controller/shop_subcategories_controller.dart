/*Papabear*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/sub_categories_model.dart';
import 'package:ultimate_salon_owner_flutter/app/product/api/shop_subcategories_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/create_products_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class ShopSubCategoriesController extends GetxController
    implements GetxService {
  final ShopSubCategoriesParser parser;

  List<SubCategoriesModel> _subCateList = <SubCategoriesModel>[];
  List<SubCategoriesModel> get subCateList => _subCateList;

  String id = '';
  String selectedSubCate = '';
  String selectedSubCateName = '';

  bool apiCalled = false;

  ShopSubCategoriesController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    id = Get.arguments[0].toString();
    debugPrint(id);
    getProductsByCateId();
  }

  Future<void> getProductsByCateId() async {
    var param = {'id': id};
    var response = await parser.getProductsById(param);
    apiCalled = true;
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      debugPrint(myMap.toString());
      var body = myMap['data'] ?? myMap['subCates'] ?? myMap['sub_categories'];
      _subCateList = [];
      if (body is List) {
        for (final data in body) {
          if (data is! Map) continue;
          _subCateList.add(
              SubCategoriesModel.fromJson(Map<String, dynamic>.from(data)));
        }
      }
      debugPrint(_subCateList.length.toString());
      update();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void saveSubCate(String id) {
    selectedSubCate = id;
    var name =
        _subCateList.firstWhere((element) => element.id.toString() == id).name;
    selectedSubCateName = name as String;
    debugPrint('selected subcategories');
    update();
  }

  void saveAndClose() {
    debugPrint(selectedSubCate.toString());
    debugPrint(selectedSubCateName.toString());
    Get.find<CreateProductsController>()
        .onSaveSubCate(selectedSubCate, selectedSubCateName);
    onBack();
  }

  Future<void> createSubCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      showToast('Please enter a sub-category name');
      return;
    }
    final cateId = int.tryParse(id) ?? id;
    final response = await parser.createSubCategory({
      'name': trimmed,
      'cate_id': cateId,
    });
    if (response.statusCode == 200) {
      await getProductsByCateId();
      showToast('Sub-category created');
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void openCreateDialog() {
    final name = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('Create Sub-category'.tr),
        content: TextField(
          controller: name,
          decoration: InputDecoration(hintText: 'Name'.tr),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
          TextButton(
            onPressed: () async {
              Get.back();
              await createSubCategory(name.text);
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
