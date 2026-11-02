import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/product/api/products_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/create_products_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/product_complete_history_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/product_history_model.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/products_model.dart';
import 'package:ultimate_salon_owner_flutter/app/product/view/product_complete_history.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class ProductDetailController extends GetxController implements GetxService {
  final ProductsParser parser;
  ProductDetailController({required this.parser});

  bool apiCalled = false;
  ProductsModel product = ProductsModel();
  ProductVariant? selectedVariant;
  ProductHistoryBundle history = ProductHistoryBundle();
  String currencySide = AppConstants.defaultCurrencySide;
  String currencySymbol = AppConstants.defaultCurrencySymbol;

  @override
  void onInit() {
    super.onInit();
    currencySide = parser.getCurrencySide();
    currencySymbol = parser.getCurrencySymbol();
    final id = Get.arguments;
    if (id != null) {
      load(id);
    } else {
      apiCalled = true;
    }
  }

  List<String> get galleryUrls {
    final variantUrls = selectedVariant?.imageUrls ?? [];
    if (variantUrls.isNotEmpty) return variantUrls;
    final urls = <String>[];
    for (final item in product.galleryItems) {
      final url = item.url ?? '';
      if (url.isNotEmpty) urls.add(url);
    }
    for (final url in product.imagesList) {
      if (url.isNotEmpty && !urls.contains(url)) urls.add(url);
    }
    if (urls.isEmpty && product.cover != null && product.cover!.isNotEmpty) {
      urls.add(product.cover!);
    }
    return urls;
  }

  String get displayName {
    final variantTitle = selectedVariant?.title ?? '';
    if (variantTitle.isNotEmpty) {
      return '${product.name ?? ''}  •  $variantTitle';
    }
    return product.name ?? '';
  }

  num get displaySellPrice =>
      selectedVariant?.sellPrice ?? product.sellPrice ?? 0;

  num get displayOriginalPrice =>
      selectedVariant?.originalPrice ?? product.originalPrice ?? 0;

  num get displayDiscount =>
      selectedVariant?.discount ?? product.discount ?? 0;

  int get displayStock =>
      selectedVariant?.inStock ??
      product.stockAvailable ??
      product.stockQty ??
      product.inStock ??
      0;

  String money(num? amount) {
    final value = amount ?? 0;
    return currencySide == 'left'
        ? '$currencySymbol$value'
        : '$value$currencySymbol';
  }

  void selectVariant(ProductVariant row) {
    final same = selectedVariant != null &&
        ((selectedVariant!.id != null && selectedVariant!.id == row.id) ||
            identical(selectedVariant, row));
    selectedVariant = same ? null : row;
    update();
  }

  Future<void> load(dynamic id) async {
    apiCalled = false;
    update();
    final response = await parser.getProductById(id);
    apiCalled = true;
    if (response.statusCode == 200) {
      final myMap = Map<String, dynamic>.from(response.body);
      final data = myMap['data'];
      if (data is Map) {
        product = ProductsModel.fromJson(Map<String, dynamic>.from(data));
        selectedVariant = null;
      }
      final embedded = myMap['history'] ??
          myMap['sections'] ??
          (data is Map ? data['history'] : null);
      if (embedded is Map) {
        history = ProductHistoryBundle.fromResponse({
          ...myMap,
          'sections': embedded['sections'] ?? embedded,
          'counts': myMap['history_counts'] ??
              myMap['counts'] ??
              embedded['counts'],
          'totals': myMap['history_totals'] ?? myMap['totals'],
        });
      }
      await _loadHistory(id);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> _loadHistory(dynamic id) async {
    final response = await parser.getProductHistory(id);
    if (response.statusCode != 200 || response.body is! Map) return;
    history = ProductHistoryBundle.fromResponse(
        Map<String, dynamic>.from(response.body));
  }

  void onOpenHistory() {
    if (product.id == null) return;
    Get.delete<ProductCompleteHistoryController>(force: true);
    Get.to(
      () => const ProductCompleteHistoryScreen(),
      binding: BindingsBuilder(() {
        Get.put(ProductCompleteHistoryController(parser: parser));
      }),
      arguments: {
        'id': product.id,
        'name': product.name ?? 'History',
        'bundle': history,
      },
    );
  }

  void onEdit() {
    if (product.id == null) return;
    Get.delete<CreateProductsController>(force: true);
    Get.toNamed(AppRouter.getCreateProductsRoute(),
        arguments: ['update', product.id]);
  }
}
