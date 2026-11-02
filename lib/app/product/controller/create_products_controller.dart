import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/categories_model.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/products_model.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/sub_categories_model.dart';
import 'package:ultimate_salon_owner_flutter/app/product/api/create_products_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/products_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/shop_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/shop_subcategories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class CreateProductsController extends GetxController implements GetxService {
  final CreateProductsParser parser;

  DateTime expDate = DateTime.now();
  bool inGrams = false;
  bool inKG = false;
  bool inLiter = false;
  bool inPCs = false;
  bool inML = false;
  bool inHome = false;
  bool inSingle = false;
  bool inOffers = false;
  bool inStock = false;
  bool returnable = true;
  int returnDays = 7;
  final returnDaysTextEditor = TextEditingController(text: '7');
  List<Map<String, dynamic>> paymentMethodOptions = [];
  final Set<String> selectedPaymentMethods = {'cod', 'online'};

  String selectedProductId = '';

  ProductsModel _productsInfo = ProductsModel();
  ProductsModel get productInfo => _productsInfo;

  String selectedCateId = '';
  String selectedCateName = '';

  String selectedSubId = '';
  String selectedSubName = '';

  int selectedOfferStatus = 1;
  int selectedStackStatus = 1;

  XFile? _selectedImage;
  String cover = '';

  bool apiCalled = false;

  /// PDF gallery views for main product + variants.
  static const List<String> galleryViews = ['front', 'back', 'side'];
  List<String> gallery = ['', '', ''];

  final productNameTextEditor = TextEditingController();
  final productsPriceTextEditor = TextEditingController();
  final discountTextEditor = TextEditingController();
  final sellPriceTextEditor = TextEditingController();
  final stockQtyTextEditor = TextEditingController();
  final colorTextEditor = TextEditingController();
  final measurementValueTextEditor = TextEditingController();
  final hsnCodeTextEditor = TextEditingController();
  List<ProductMeasurement> measurements = [];
  int? selectedMeasurementId;

  final descriptionTextEditor = TextEditingController();

  double tax = 18.0;

  String get finalPriceWithTax {
    if (sellPriceTextEditor.text.isNotEmpty) {
      final sellPrice = double.tryParse(sellPriceTextEditor.text) ?? 0.0;
      return CurrencyHelper.inclusiveFixed(sellPrice);
    }
    return '0.00';
  }

  final disclaimerTextEditor = TextEditingController();
  final gramTextEditor = TextEditingController();
  final kgTextEditor = TextEditingController();
  final pcsTextEditor = TextEditingController();
  final literTextEditor = TextEditingController();
  final mlTextEditor = TextEditingController();

  String type = 'create';
  final List<ProductVariantForm> variants = [];
  CreateProductsController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    type = Get.arguments[0];
    // PDF: load units/getAll before showing Create Product form.
    _bootstrapForm();
  }

  Future<void> _bootstrapForm() async {
    await loadMeasurements();
    if (type == 'update') {
      selectedProductId = Get.arguments[1].toString();
      await getProductById();
    } else {
      apiCalled = true;
      update();
    }
  }

  /// PDF: Unit + Amount are required on main product and every variant.
  String? _unitAmountValidationError() {
    if (selectedMeasurementId == null) {
      return 'Please select a Unit.';
    }
    if (measurementValueTextEditor.text.trim().isEmpty) {
      return 'Please enter Amount (e.g. 100). Not the sell price.';
    }
    if (num.tryParse(measurementValueTextEditor.text.trim()) == null) {
      return 'Amount must be a number (e.g. 100).';
    }
    for (var i = 0; i < variants.length; i++) {
      final row = variants[i];
      if (row.measurementId == null) {
        return 'Variant ${i + 1}: please select a Unit.';
      }
      if (row.measurementValue.text.trim().isEmpty) {
        return 'Variant ${i + 1}: please enter Amount.';
      }
      if (num.tryParse(row.measurementValue.text.trim()) == null) {
        return 'Variant ${i + 1}: Amount must be a number.';
      }
      if (row.sellPrice.text.trim().isEmpty) {
        return 'Variant ${i + 1}: please enter Sell Price.';
      }
    }
    return null;
  }

  Map<String, dynamic> _mainUnitFields() {
    return unitFields(
      id: selectedMeasurementId,
      value: measurementValueTextEditor.text,
    );
  }

  String get selectedMeasurementLabel {
    return measurementLabel(selectedMeasurementId);
  }

  String measurementLabel(int? id) {
    if (id == null) return 'Select unit'.tr;
    for (final item in measurements) {
      if (item.id == id) return item.label;
    }
    return 'Select unit'.tr;
  }

  Future<void> loadMeasurements() async {
    // PDF v7: units/getAll first so Unit dropdown is ready before form use.
    final response = await parser.getMeasurements();
    if (response.statusCode == 200 && response.body is Map) {
      _parseMeasurements(response.body['units'] ??
          response.body['data'] ??
          response.body['measurements']);
    }
    final form = await parser.getForm();
    if (form.statusCode == 200 && form.body is Map) {
      final data = form.body['data'] is Map ? form.body['data'] : form.body;
      if (measurements.isEmpty) {
        _parseMeasurements(form.body['units'] ??
            form.body['measurement_units'] ??
            form.body['measurements'] ??
            (data is Map
                ? (data['units'] ?? data['measurement_units'])
                : null));
      }
      _parseGalleryViews(form.body['gallery_views'] ??
          (data is Map ? data['gallery_views'] : null));
      _parsePaymentMethods(
        form.body['payment_methods'] ??
            (data is Map ? data['payment_methods'] : null),
      );
    }
    if (paymentMethodOptions.isEmpty) {
      final pay = await parser.getPaymentMethods();
      if (pay.statusCode == 200 && pay.body is Map) {
        _parsePaymentMethods(pay.body['data'] ?? pay.body['payment_methods']);
      }
    }
    update();
  }

  void _parsePaymentMethods(dynamic raw) {
    if (raw is! List || raw.isEmpty) return;
    paymentMethodOptions = raw
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    if (selectedPaymentMethods.isEmpty) {
      for (final row in paymentMethodOptions) {
        final code = (row['code'] ?? row['type'] ?? '').toString().toLowerCase();
        final enabled = row['enabled'] != false && row['enabled'] != 0;
        if (code.isNotEmpty && enabled) selectedPaymentMethods.add(code);
      }
    }
  }

  void togglePaymentMethod(String code, bool enabled) {
    final key = code.toLowerCase();
    if (enabled) {
      selectedPaymentMethods.add(key);
    } else {
      selectedPaymentMethods.remove(key);
    }
    update();
  }

  void setReturnable(bool value) {
    returnable = value;
    if (value && (int.tryParse(returnDaysTextEditor.text.trim()) ?? 0) <= 0) {
      returnDaysTextEditor.text = '7';
      returnDays = 7;
    }
    update();
  }

  Map<String, dynamic> _returnPaymentFields() {
    final days = int.tryParse(returnDaysTextEditor.text.trim()) ?? returnDays;
    returnDays = days;
    final methods = selectedPaymentMethods.toList();
    return {
      'returnable': returnable ? 1 : 0,
      'return_option': returnable ? 1 : 0,
      'is_returnable': returnable ? 1 : 0,
      'return_days': returnable ? days : 0,
      'return_period': returnable ? days : 0,
      'payment_methods': methods,
      'accept_cod': methods.contains('cod') ? 1 : 0,
      'accept_online': methods.contains('online') ? 1 : 0,
    };
  }

  void _parseGalleryViews(dynamic raw) {
    // PDF fixed views: front / back / side. Extra slots via Add image.
    while (gallery.length < galleryViews.length) {
      gallery.add('');
    }
    if (raw is! List || raw.isEmpty) return;
    // Keep at least the PDF slots; ignore unknown form view lists.
  }

  static Map<String, dynamic> unitFields({int? id, required String value}) {
    final trimmed = value.trim();
    final qty = num.tryParse(trimmed);
    final amount = qty ?? (trimmed.isEmpty ? 0 : trimmed);
    return {
      if (id != null) 'measurement_id': id,
      if (id != null) 'unit_id': id,
      if (id != null) 'unit': id,
      'measurement_value': amount,
      'measurement_amount': amount,
      'unit_value': amount,
      'unit_amount': amount,
      'value': amount,
    };
  }

  void _parseMeasurements(dynamic raw) {
    if (raw is Map) {
      raw = raw['units'] ?? raw['data'] ?? raw['measurements'];
    }
    if (raw is! List) return;
    final rows = raw
        .whereType<Map>()
        .map((row) =>
            ProductMeasurement.fromJson(Map<String, dynamic>.from(row)))
        .where((row) => row.id != null)
        .toList();
    if (rows.isNotEmpty) measurements = rows;
  }

  void pickMeasurement({int? variantIndex}) {
    Get.bottomSheet(
      Container(
        color: ThemeProvider.whiteColor,
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text('Select unit'.tr,
                    style: const TextStyle(fontFamily: 'bold')),
              ),
              ...measurements.map(
                (item) => ListTile(
                  title: Text(item.label),
                  onTap: () {
                    if (variantIndex == null) {
                      selectedMeasurementId = item.id;
                    } else if (variantIndex >= 0 &&
                        variantIndex < variants.length) {
                      variants[variantIndex].measurementId = item.id;
                    }
                    update();
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getProductById() async {
    var response = await parser.getProductById(selectedProductId);
    apiCalled = true;
    update();
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      debugPrint(myMap.toString());
      var data = myMap['data'];
      ProductsModel productData = ProductsModel.fromJson(data);
      _productsInfo = productData;
      cover = _productsInfo.cover.toString();
      stockQtyTextEditor.text =
          (_productsInfo.stockQty ?? _productsInfo.inStock ?? 0).toString();
      productNameTextEditor.text = _productsInfo.name.toString();
      descriptionTextEditor.text = _productsInfo.descriptions.toString();
      disclaimerTextEditor.text = _productsInfo.disclaimer.toString();
      productsPriceTextEditor.text = _productsInfo.originalPrice.toString();
      sellPriceTextEditor.text = _productsInfo.sellPrice.toString();
      hsnCodeTextEditor.text = _productsInfo.hsnCode.toString();
      discountTextEditor.text = _productsInfo.discount.toString();
      colorTextEditor.text = _productsInfo.color ?? '';
      selectedMeasurementId = _productsInfo.measurementId;
      measurementValueTextEditor.text = _productsInfo.measurementValue ?? '';
      inHome = productInfo.inHome == 1 ? true : false;
      inSingle = productInfo.isSingle == 1 ? true : false;
      inGrams = productInfo.haveGram == 1 ? true : false;
      inKG = productInfo.haveKg == 1 ? true : false;
      inPCs = productInfo.havePcs == 1 ? true : false;
      inLiter = productInfo.haveLiter == 1 ? true : false;
      inML = productInfo.haveMl == 1 ? true : false;
      selectedCateId = _productsInfo.cateId.toString();
      selectedSubId = _productsInfo.subCateId.toString();
      gramTextEditor.text = _productsInfo.gram.toString();
      kgTextEditor.text = _productsInfo.kg.toString();
      pcsTextEditor.text = productInfo.pcs.toString();
      literTextEditor.text = _productsInfo.liter.toString();
      mlTextEditor.text = _productsInfo.ml.toString();
      inOffers = _productsInfo.inOffer == 1 ? true : false;
      inStock = _productsInfo.inStock == 1 ? true : false;
      returnable = (_productsInfo.returnable ?? 0) == 1;
      returnDays = _productsInfo.returnDays ?? (returnable ? 7 : 0);
      returnDaysTextEditor.text =
          returnable ? (returnDays > 0 ? '$returnDays' : '7') : '0';
      selectedPaymentMethods
        ..clear()
        ..addAll(_productsInfo.paymentMethods);
      if (selectedPaymentMethods.isEmpty) {
        if ((_productsInfo.acceptCod ?? 0) == 1) {
          selectedPaymentMethods.add('cod');
        }
        if ((_productsInfo.acceptOnline ?? 0) == 1) {
          selectedPaymentMethods.add('online');
        }
      }
      for (final form in variants) {
        form.dispose();
      }
      variants
        ..clear()
        ..addAll(_productsInfo.variants.map(ProductVariantForm.fromModel));

      if (myMap['cateInfo'] is Map) {
        CategoryModel cateData = CategoryModel.fromJson(
            Map<String, dynamic>.from(myMap['cateInfo']));
        selectedCateName = cateData.name.toString();
      }
      if (myMap['subCateInfo'] is Map) {
        SubCategoriesModel subCateData = SubCategoriesModel.fromJson(
            Map<String, dynamic>.from(myMap['subCateInfo']));
        selectedSubName = subCateData.name.toString();
      }

      gallery = List<String>.filled(galleryViews.length, '');
      if (_productsInfo.galleryItems.isNotEmpty) {
        for (final item in _productsInfo.galleryItems) {
          final view = (item.view ?? 'other').toLowerCase();
          final url = item.url ?? '';
          if (url.isEmpty) continue;
          final index = galleryViews.indexOf(view);
          if (index >= 0) {
            gallery[index] = url;
          } else {
            gallery.add(url);
          }
        }
        if (gallery.isNotEmpty && gallery[0].trim().isNotEmpty) {
          cover = gallery[0];
        } else {
          cover = cover.isEmpty || cover == 'null'
              ? (_productsInfo.displayImage ?? cover)
              : cover;
        }
      } else {
        dynamic images = [];
        try {
          images = jsonDecode(_productsInfo.images.toString());
        } catch (_) {
          images = [];
        }
        if (images is List && images.isNotEmpty) {
          int index = 0;
          for (final element in images) {
            if (index >= gallery.length) break;
            gallery[index] = element.toString();
            index++;
          }
        }
      }
      expDate = DateTime.tryParse(_productsInfo.expDate.toString()) ??
          DateTime.now();
      update();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> updateProduct() async {
    void showValidationDialog(String message) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: ThemeProvider.whiteColor,
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Field Required',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ThemeProvider.appColor,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'regular', fontSize: 16, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: ThemeProvider.appColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontFamily: 'regular', color: ThemeProvider.whiteColor),
              ),
            ),
          ],
        ),
      );
    }

    // Validate fields with specific messages
    if (selectedCateId.isEmpty) {
      showValidationDialog('Please select a category.');
      return;
    }
    if (selectedSubId.isEmpty) {
      showValidationDialog('Please select a sub-category.');
      return;
    }
    if (cover.isEmpty && _galleryPayload().isEmpty) {
      showValidationDialog('Please upload a cover or front/back/side image.');
      return;
    }
    if (productNameTextEditor.text.isEmpty) {
      showValidationDialog('Please enter a product name.');
      return;
    }
    if (sellPriceTextEditor.text.isEmpty) {
      showValidationDialog('Please enter a sell price.');
      return;
    }
    final unitError = _unitAmountValidationError();
    if (unitError != null) {
      showValidationDialog(unitError);
      return;
    }
    Get.dialog(
      SimpleDialog(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 30,
              ),
              const CircularProgressIndicator(
                color: ThemeProvider.appColor,
              ),
              const SizedBox(
                width: 30,
              ),
              SizedBox(
                  child: Text(
                "Please wait".tr,
                style: const TextStyle(fontFamily: 'bold'),
              )),
            ],
          )
        ],
      ),
      barrierDismissible: false,
    );

    final variantRows = _variantPayload();
    final galleryRows = _galleryPayload();
    final stockQty = int.tryParse(stockQtyTextEditor.text.trim()) ?? 0;
    final originalPrice =
        num.tryParse(productsPriceTextEditor.text.trim()) ?? 0;
    final sellPrice = num.tryParse(sellPriceTextEditor.text.trim()) ?? 0;
    final discount = num.tryParse(discountTextEditor.text.trim()) ??
        (originalPrice > sellPrice ? originalPrice - sellPrice : 0);
    var body = {
      "id": selectedProductId,
      "product_id": selectedProductId,
      "freelacer_id": int.tryParse(parser.getFreelancerId()) ??
          parser.getFreelancerId(),
      "freelancer_id": int.tryParse(parser.getFreelancerId()) ??
          parser.getFreelancerId(),
      "cover": cover.isEmpty && galleryRows.isNotEmpty
          ? galleryRows.first['url']
          : cover,
      "name": productNameTextEditor.text,
      "original_price": originalPrice,
      "original": originalPrice,
      "sell_price": sellPrice,
      "discount": discount,
      "color": colorTextEditor.text.trim(),
      "colour": colorTextEditor.text.trim(),
      "color_name": colorTextEditor.text.trim(),
      ..._mainUnitFields(),
      "descriptions": descriptionTextEditor.text,
      "disclaimer": disclaimerTextEditor.text,
      // "in_home": inHome == true ? 1 : 0,
      "in_home": 0,

      //     "is_single": inSingle == true ? 1 : 0,
      "is_single": 0,

      "have_gram": 0,
      "have_kg": 0,
      "have_pcs": 0,
      "have_liter": 0,
      "have_ml": 0,
      "cate_id": int.tryParse(selectedCateId) ?? selectedCateId,
      "sub_cate_id": int.tryParse(selectedSubId) ?? selectedSubId,
      "hsn_code": hsnCodeTextEditor.text,
      if (variantRows.isNotEmpty) "variants": variantRows,
      if (galleryRows.isNotEmpty) "gallery": galleryRows,
      if (galleryRows.isNotEmpty)
        "images": galleryRows.map((row) => row['url']).toList(),
      "stock": stockQty,
      "stock_qty": stockQty,
      "in_stock": stockQty,
      "gram": 0,
      "kg": 0,
      "pcs": 0,
      "liter": 0,
      "ml": 0,
      //"in_offer": inOffers == true ? 1 : 0,
      "in_offer": 0,
      "exp_date":
          Jiffy.parseFromDateTime(expDate).format(pattern: 'yyyy-MM-dd'),
      "rating": 0,
      "total_rating": 0,
      ..._returnPaymentFields(),
    };

    debugPrint(body.toString());
    Response response = await parser.updateProducts(body);
    Get.back();
    debugPrint(response.toString());
    if (response.statusCode == 200) {
      onBack();
      Get.find<ProductsController>().getProductWFreelancer();
      successToast('Update Products');
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onShopCategories() {
    Get.delete<ShopCategoriesController>(force: true);
    Get.toNamed(AppRouter.getShopCategoriesRoute(),
        arguments: [selectedCateId]);
  }

  void onShopSubCategories() {
    if (selectedCateId == '' || selectedCateId.isEmpty) {
      showToast('Please select category');
      return;
    }
    Get.delete<ShopSubCategoriesController>(force: true);
    Get.toNamed(AppRouter.getShopSubCategoriesRoute(),
        arguments: [selectedCateId]);
  }

  void updateinGrams(bool status) {
    inGrams = status;
    update();
  }

  void updateinKG(bool status) {
    inKG = status;
    update();
  }

  void updateinLiter(bool status) {
    inLiter = status;
    update();
  }

  void updateinPCs(bool status) {
    inPCs = status;
    update();
  }

  void updateinML(bool status) {
    inML = status;
    update();
  }

  void updateinHome(bool status) {
    inHome = status;
    update();
  }

  void updateinSingle(bool status) {
    inSingle = status;
    update();
  }

  void updateOfferStatus(int status) {
    selectedOfferStatus = status;
    update();
  }

  void updateStackStatus(int status) {
    selectedStackStatus = status;
    update();
  }

  void onSaveproductCate(String id, String name) {
    debugPrint(id);
    selectedCateId = id;
    selectedCateName = name;
    selectedSubId = '';
    selectedSubName = '';
    update();
  }

  void onSaveSubCate(String id, String name) {
    debugPrint(id);
    selectedSubId = id;
    selectedSubName = name;
    update();
  }

  Future<void> saveProducts() async {
    // Helper function to show validation dialog
    void showValidationDialog(String message) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: ThemeProvider.whiteColor,
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Field Required',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ThemeProvider.appColor,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'regular', fontSize: 16, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: ThemeProvider.appColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontFamily: 'regular', color: ThemeProvider.whiteColor),
              ),
            ),
          ],
        ),
      );
    }

    // Validate fields with specific messages
    if (selectedCateId.isEmpty) {
      showValidationDialog('Please select a category.');
      return;
    }
    if (selectedSubId.isEmpty) {
      showValidationDialog('Please select a sub-category.');
      return;
    }
    if (cover.isEmpty && _galleryPayload().isEmpty) {
      showValidationDialog('Please upload a cover or front/back/side image.');
      return;
    }
    if (productNameTextEditor.text.isEmpty) {
      showValidationDialog('Please enter a product name.');
      return;
    }
    if (sellPriceTextEditor.text.isEmpty) {
      showValidationDialog('Please enter a sell price.');
      return;
    }
    final unitError = _unitAmountValidationError();
    if (unitError != null) {
      showValidationDialog(unitError);
      return;
    }

    // Show loading dialog
    Get.dialog(
      SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: ThemeProvider.whiteColor,
        children: [
          Row(
            children: [
              const SizedBox(width: 30),
              const CircularProgressIndicator(
                color: ThemeProvider.appColor,
              ),
              const SizedBox(width: 30),
              Text(
                "Please wait".tr,
                style: const TextStyle(
                  fontFamily: 'bold',
                  fontSize: 16,
                  color: ThemeProvider.blackColor,
                ),
              ),
            ],
          )
        ],
      ),
      barrierDismissible: false,
    );

    // PDF: on create, product_id = logged-in product user id.
    final uid = int.tryParse(parser.getFreelancerId()) ?? parser.getFreelancerId();
    final variantRows = _variantPayload();
    final galleryRows = _galleryPayload();
    final stockQty = int.tryParse(stockQtyTextEditor.text.trim()) ?? 0;
    final originalPrice =
        num.tryParse(productsPriceTextEditor.text.trim()) ?? 0;
    final sellPrice = num.tryParse(sellPriceTextEditor.text.trim()) ?? 0;
    final discount = num.tryParse(discountTextEditor.text.trim()) ??
        (originalPrice > sellPrice ? originalPrice - sellPrice : 0);
    var body = {
      "product_id": uid,
      "product_user_id": uid,
      "uid": uid,
      "freelacer_id": uid,
      "freelancer_id": uid,
      "cover": cover.isEmpty && galleryRows.isNotEmpty
          ? galleryRows.first['url']
          : cover,
      "name": productNameTextEditor.text,
      "original_price": originalPrice,
      "original": originalPrice,
      "sell_price": sellPrice,
      "hsn_code": hsnCodeTextEditor.text,
      "discount": discount,
      "color": colorTextEditor.text.trim(),
      "colour": colorTextEditor.text.trim(),
      "color_name": colorTextEditor.text.trim(),
      ..._mainUnitFields(),
      "descriptions": descriptionTextEditor.text,
      "disclaimer": disclaimerTextEditor.text,
      // "in_home": inHome == true ? 1 : 0,
      "in_home": 0,
      //     "is_single": inSingle == true ? 1 : 0,
      "is_single": 0,
      "have_gram": 0,
      "have_kg": 0,
      "have_pcs": 0,
      "have_liter": 0,
      "have_ml": 0,
      "cate_id": int.tryParse(selectedCateId) ?? selectedCateId,
      "sub_cate_id": int.tryParse(selectedSubId) ?? selectedSubId,
      if (galleryRows.isNotEmpty) "gallery": galleryRows,
      if (galleryRows.isNotEmpty)
        "images": galleryRows.map((row) => row['url']).toList(),
      if (variantRows.isNotEmpty) "variants": variantRows,
      "stock": stockQty,
      "stock_qty": stockQty,
      "gram": 0,
      "kg": 0,
      "pcs": 0,
      "liter": 0,
      "ml": 0,
      //"in_offer": inOffers == true ? 1 : 0,
      "in_offer": 0,
      "status": 1,

      "in_stock": stockQty,
      "exp_date":
          Jiffy.parseFromDateTime(expDate).format(pattern: 'yyyy-MM-dd'),
      "rating": 0,
      "total_rating": 0,
      ..._returnPaymentFields(),
    };

    debugPrint(body.toString());

    // API call
    var response = await parser.onCreateProducts(body);
    Get.back();
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      Get.find<ProductsController>().getProductWFreelancer();
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: ThemeProvider.whiteColor,
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Success',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ThemeProvider.appColor,
                ),
              ),
            ],
          ),
          content: const Text(
            'Product saved successfully!',
            style: TextStyle(fontFamily: 'regular', fontSize: 16, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                onBack();
              },
              style: TextButton.styleFrom(
                backgroundColor: ThemeProvider.appColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontFamily: 'regular', color: ThemeProvider.whiteColor),
              ),
            ),
          ],
        ),
      );
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  /// PDF: discount is a flat amount (e.g. 5000), not a percent.
  void onRealPrice(var input) {
    _syncSellFromOriginalAndDiscount();
  }

  void onDiscountPrice(var input) {
    _syncSellFromOriginalAndDiscount();
  }

  void onSellPriceChanged(var input) {
    final original = double.tryParse(productsPriceTextEditor.text) ?? 0.0;
    final sell = double.tryParse(sellPriceTextEditor.text) ?? 0.0;
    if (original > 0 && sell >= 0 && original >= sell) {
      final flat = original - sell;
      discountTextEditor.text =
          flat % 1 == 0 ? flat.toInt().toString() : flat.toStringAsFixed(2);
    }
    update();
  }

  void _syncSellFromOriginalAndDiscount() {
    final original = double.tryParse(productsPriceTextEditor.text) ?? 0.0;
    final discount = double.tryParse(discountTextEditor.text) ?? 0.0;
    if (productsPriceTextEditor.text.trim().isEmpty) {
      sellPriceTextEditor.text = '';
      update();
      return;
    }
    final sell = (original - discount).clamp(0, original);
    sellPriceTextEditor.text =
        sell % 1 == 0 ? sell.toInt().toString() : sell.toStringAsFixed(2);
    update();
  }

  void percentage(double percent, double total) {
    // Kept for compatibility; Create Product uses flat discount instead.
    sellPriceTextEditor.text =
        CurrencyHelper.discountedPrice(total, percent).toStringAsFixed(2);
    update();
  }

  void selectFromGallery(String kind) async {
    _selectedImage = await ImagePicker().pickImage(
        source: kind == 'gallery' ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 25);
    update();
    if (_selectedImage != null) {
      Get.dialog(
          SimpleDialog(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  const CircularProgressIndicator(
                    color: ThemeProvider.appColor,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                      child: Text(
                    "Please wait".tr,
                    style: const TextStyle(fontFamily: 'bold'),
                  )),
                ],
              )
            ],
          ),
          barrierDismissible: false);
      Response response = await parser.uploadImage(_selectedImage as XFile);
      Get.back();
      if (response.statusCode == 200) {
        _selectedImage = null;
        if (response.body['data'] != null && response.body['data'] != '') {
          dynamic body = response.body["data"];
          if (body['image_name'] != null && body['image_name'] != '') {
            cover = body['image_name'];
            debugPrint(cover);
            update();
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    }
  }

  void selectFromGalleryOthers(String kind, int index) async {
    _selectedImage = await ImagePicker().pickImage(
        source: kind == 'gallery' ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 25);
    update();
    if (_selectedImage != null) {
      Get.dialog(
          SimpleDialog(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  const CircularProgressIndicator(
                    color: ThemeProvider.appColor,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                      child: Text(
                    "Please wait".tr,
                    style: const TextStyle(fontFamily: 'bold'),
                  )),
                ],
              )
            ],
          ),
          barrierDismissible: false);
      Response response = await parser.uploadImage(_selectedImage as XFile);
      Get.back();
      if (response.statusCode == 200) {
        _selectedImage = null;
        if (response.body['data'] != null && response.body['data'] != '') {
          dynamic body = response.body["data"];
          if (body['image_name'] != null && body['image_name'] != '') {
            while (gallery.length <= index) {
              gallery.add('');
            }
            gallery[index] = body['image_name'];
            // PDF: cover falls back to front (or first) gallery image.
            if (index == 0 || cover.isEmpty) {
              cover = body['image_name'];
            }
            update();
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    }
  }

  void clearGalleryImage(int index) {
    if (index < 0 || index >= gallery.length) return;
    final removed = gallery[index];
    gallery[index] = '';
    if (cover == removed) {
      cover = gallery.firstWhere((url) => url.trim().isNotEmpty, orElse: () => '');
    }
    update();
  }

  void addExtraGallerySlot() {
    gallery.add('');
    update();
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  Future<void> openTimePicker() async {
    var context = Get.context as BuildContext;

    DateTime currentday = DateTime.now();
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: currentday,
      firstDate: currentday,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeProvider.appColor
                  .withOpacity(0.7), // header background color
              onPrimary: ThemeProvider.whiteColor, // header text color
              onSurface: ThemeProvider.blackColor, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ThemeProvider.appColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    newDate != null ? expDate = newDate : expDate;

    debugPrint(Jiffy.parseFromDateTime(expDate).format(pattern: 'yyyy-MM-dd'));
    update();
  }

  void addVariant() {
    final row = ProductVariantForm();
    row.measurementId = selectedMeasurementId;
    row.measurementValue.text = measurementValueTextEditor.text;
    row.color.text = colorTextEditor.text;
    variants.add(row);
    update();
  }

  void removeVariant(int index) {
    if (index < 0 || index >= variants.length) return;
    variants.removeAt(index).dispose();
    update();
  }

  List<Map<String, dynamic>> _galleryPayload() {
    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < gallery.length; i++) {
      final url = gallery[i].trim();
      if (url.isEmpty) continue;
      final view = i < galleryViews.length ? galleryViews[i] : 'extra_$i';
      rows.add({
        'view': view,
        'label': i < galleryViews.length
            ? '${view[0].toUpperCase()}${view.substring(1)}'
            : 'Image ${i + 1}',
        'url': url,
      });
    }
    return rows;
  }

  List<Map<String, dynamic>> _variantPayload() {
    return variants
        .where((row) =>
            row.name.text.trim().isNotEmpty ||
            row.color.text.trim().isNotEmpty ||
            row.sellPrice.text.trim().isNotEmpty)
        .map((row) => row.toJson())
        .toList();
  }

  Future<void> pickVariantImage(int index, {int? viewIndex}) async {
    if (index < 0 || index >= variants.length) return;
    _selectedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 25);
    if (_selectedImage == null) return;
    Get.dialog(
      SimpleDialog(
        children: [
          Row(
            children: [
              const SizedBox(width: 30),
              const CircularProgressIndicator(color: ThemeProvider.appColor),
              const SizedBox(width: 30),
              Text("Please wait".tr,
                  style: const TextStyle(fontFamily: 'bold')),
            ],
          )
        ],
      ),
      barrierDismissible: false,
    );
    Response response = await parser.uploadImage(_selectedImage as XFile);
    Get.back();
    if (response.statusCode == 200) {
      _selectedImage = null;
      final data = response.body['data'];
      final url = data is Map ? data['image_name']?.toString() ?? '' : '';
      if (url.isNotEmpty) {
        if (viewIndex == null) {
          variants[index].picture = url;
        } else if (viewIndex >= 0 &&
            viewIndex < variants[index].gallery.length) {
          variants[index].gallery[viewIndex] = url;
        }
        update();
      }
    } else {
      ApiChecker.checkApi(response);
    }
  }

  @override
  void onClose() {
    for (final row in variants) {
      row.dispose();
    }
    super.onClose();
  }
}

class ProductVariantForm {
  final TextEditingController name = TextEditingController();
  final TextEditingController color = TextEditingController();
  final TextEditingController originalPrice = TextEditingController();
  final TextEditingController sellPrice = TextEditingController();
  final TextEditingController discount = TextEditingController();
  final TextEditingController inStock = TextEditingController();
  final TextEditingController measurementValue = TextEditingController();
  int? measurementId;
  String picture = '';
  List<String> gallery =
      List<String>.filled(CreateProductsController.galleryViews.length, '');
  int? id;

  ProductVariantForm();

  factory ProductVariantForm.fromModel(ProductVariant item) {
    final form = ProductVariantForm();
    form.id = item.id;
    form.name.text = item.name ?? '';
    form.color.text = item.color ?? '';
    form.originalPrice.text = item.originalPrice?.toString() ?? '';
    form.sellPrice.text = item.sellPrice?.toString() ?? '';
    form.discount.text = item.discount?.toString() ?? '';
    form.inStock.text = item.inStock?.toString() ?? '';
    form.measurementId = item.measurementId;
    form.measurementValue.text = item.measurementValue ?? '';
    form.picture = item.cover ?? '';
    for (final galleryItem in item.galleryItems) {
      final view = (galleryItem.view ?? '').toLowerCase();
      final url = galleryItem.url ?? '';
      final index = CreateProductsController.galleryViews.indexOf(view);
      if (index >= 0 && url.isNotEmpty) {
        form.gallery[index] = url;
      }
    }
    return form;
  }

  Map<String, dynamic> toJson() {
    final galleryRows = <Map<String, dynamic>>[];
    for (var i = 0;
        i < CreateProductsController.galleryViews.length && i < gallery.length;
        i++) {
      final url = gallery[i].trim();
      if (url.isEmpty) continue;
      final view = CreateProductsController.galleryViews[i];
      galleryRows.add({
        'view': view,
        'label': '${view[0].toUpperCase()}${view.substring(1)}',
        'url': url,
      });
    }
    final stock = int.tryParse(inStock.text.trim());
    final original = num.tryParse(originalPrice.text.trim());
    final sell = num.tryParse(sellPrice.text.trim()) ?? 0;
    final off = num.tryParse(discount.text.trim()) ??
        (original != null && original > sell ? original - sell : null);
    return {
      if (id != null) 'id': id,
      'name': name.text.trim(),
      'color': color.text.trim(),
      'colour': color.text.trim(),
      ...CreateProductsController.unitFields(
        id: measurementId,
        value: measurementValue.text,
      ),
      if (original != null) 'original_price': original,
      if (original != null) 'original': original,
      'sell_price': sell,
      if (off != null) 'discount': off,
      'in_stock': stock ?? 1,
      'stock': stock ?? 1,
      if (picture.trim().isNotEmpty) 'cover': picture.trim(),
      if (picture.trim().isNotEmpty) 'picture': picture.trim(),
      if (picture.trim().isNotEmpty) 'image': picture.trim(),
      if (galleryRows.isNotEmpty) 'gallery': galleryRows,
    };
  }

  void dispose() {
    name.dispose();
    color.dispose();
    measurementValue.dispose();
    originalPrice.dispose();
    sellPrice.dispose();
    discount.dispose();
    inStock.dispose();
  }
}
