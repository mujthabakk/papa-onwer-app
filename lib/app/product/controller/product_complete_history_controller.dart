import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/product/api/products_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/product_history_model.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class ProductCompleteHistoryController extends GetxController
    implements GetxService {
  final ProductsParser parser;
  ProductCompleteHistoryController({required this.parser});

  bool apiCalled = false;
  String title = 'History';
  ProductHistoryBundle bundle = ProductHistoryBundle();
  String currencySide = AppConstants.defaultCurrencySide;
  String currencySymbol = AppConstants.defaultCurrencySymbol;

  @override
  void onInit() {
    super.onInit();
    currencySide = parser.getCurrencySide();
    currencySymbol = parser.getCurrencySymbol();
    final args = Get.arguments;
    dynamic id;
    if (args is Map) {
      id = args['id'];
      title = (args['name'] ?? 'History').toString();
      if (args['bundle'] is ProductHistoryBundle) {
        bundle = args['bundle'];
      }
    } else {
      id = args;
    }
    if (id != null) {
      load(id);
    } else {
      apiCalled = true;
    }
  }

  Future<void> load(dynamic id) async {
    apiCalled = false;
    update();
    final response = await parser.getProductHistory(id);
    apiCalled = true;
    if (response.statusCode == 200 && response.body is Map) {
      bundle = ProductHistoryBundle.fromResponse(
          Map<String, dynamic>.from(response.body));
    } else if (response.statusCode != 200) {
      ApiChecker.checkApi(response);
    }
    update();
  }

  String money(num? amount) {
    final value = amount ?? 0;
    return currencySide == 'left'
        ? '$currencySymbol$value'
        : '$value$currencySymbol';
  }
}
