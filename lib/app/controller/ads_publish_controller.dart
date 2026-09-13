import 'dart:convert';
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_services_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/ads_publish_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_names_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class PaywallsListItem {
  String id;
  AdaptyPaywall? paywall;
  AdaptyError? error;
  PaywallsListItem({required this.id, this.paywall, this.error});
}

class AdsPublishController extends GetxController implements GetxService {
  final AdsPublishParser parser;

  String title = 'Add Service'.tr;
  XFile? _selectedImage;

  List<String> gallery = ['', '', '', '', '', ''];

  String selectedServiceName = '';
  String selectedCategoryName = '';

  String selectedServicesId = '';
  String selectedCategoryId = '';

  int? selectedTypeValue = 6;
  int adsDays = 0;
  String selectedDurationValue = '';
  int? selectedPagePositionValue = 1;

  String selectedPrice = "";

  final TextEditingController nameTextEditor = TextEditingController();

  Map<String, int> dropdownItemsType = {
    'Shop Page': 2,
    // 'External Link': 6,
  };
  // late List<GlassfySku> skuListHome;
  //late List<GlassfySku> skuListSearch;

  //late GlassfySku sku;

  // Map<String, int> dropdownItemsDurationHome = {
  //   '1 Month': 1000,
  //   '3 Months': 2000,
  //   '6 Months': 3000,
  // };

  // Map<String, int> dropdownItemsDurationSearch = {
  //   '1 Month': 1500,
  //   '3 Months': 2500,
  //   '6 Months': 3500,
  // };

  Map<String, int> dropdownItemsPosition = {
    'Home Page': 1,
    'Search Page': 2,
  };

  Map<String, int> dropdownTypes = {
    'Shop/Freelancer Page': 6,
    'External Link': 5,
  };

  final adapty = Adapty();
  List<AdaptyPaywallProduct>? paywallProductsHome;
  List<AdaptyPaywallProduct>? paywallProductsSearch;
  late AdaptyPaywallProduct adaptyProduct;

  bool isSearchPage = true;
  num? adPrice = 0;

  TextEditingController textControllerTitle = TextEditingController();
  TextEditingController textControllerLink = TextEditingController();

  //final nameTextEditor = TextEditingController();
  // final durationTextEditor = TextEditingController();
  // final priceTextEditor = TextEditingController();
  // final discountTextEditor = TextEditingController();
  // final offTextEditor = TextEditingController();
  final descriptionsTextEditor = TextEditingController();
  int selectedStatus = 1;

  bool apiCalled = false;

  String cover = '';

  int serviceId = 0;
  String action = 'new';

  bool linkTextField = false;
  AdsPublishController({required this.parser});

  @override
  void onInit() {
    getOfferingsHome();
    getOfferingsSearch();
    super.onInit();
    if (Get.arguments[0] == 'edit') {
      action = 'edit';
      serviceId = Get.arguments[1] as int;
      debugPrint('service id --> $serviceId');
      // getServiceById();
    } else {
      apiCalled = true;
    }
  }

  void setLinkTextField(bool value) {
    linkTextField = value;
    textControllerLink.clear();
    if (value) {
      selectedTypeValue = 5;
    } else {
      selectedTypeValue = 6;
    }

    update();
  }

  void setSearchPageAd(bool value) {
    isSearchPage = value;
    update();
  }

  void setAdPrice(num value) {
    adPrice = value;
    update();
  }

  void setSku(AdaptyPaywallProduct product) {
    adaptyProduct = product;
    update();
  }

  void onSaveCategory(String id, String name) {
    selectedCategoryId = id;
    selectedCategoryName = name;
    debugPrint('got from service list');
    update();
  }

  void onSaveServiceName(String id, String name) {
    selectedServicesId = id;
    selectedServiceName = name;
    debugPrint('got from service list');
    update();
  }

  Future<void> onSubmit() async {
    if (parser.getUID == '' ||
        selectedDurationValue == '' ||
        textControllerTitle.text.isEmpty ||
        cover == '' ||
        cover.isEmpty) {
      showToast('All fields are required!');
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

    adsDays = 0;
    if (selectedDurationValue == '1') {
      adsDays = 7;
    } else if (selectedDurationValue == '2') {
      adsDays = 14;
    } else if (selectedDurationValue == '4') {
      adsDays = 28;
    }
    debugPrint('adDays $adsDays');
    var body = {
      "uid": parser.getUID(),
      "cover": cover,
      "days": adsDays,
      "position": selectedPagePositionValue! - 1,
      "title": textControllerTitle.text,
      "price": adPrice,
      "link": textControllerLink.text,
      // "type": selectedTypeValue,
    };

    debugPrint(body.toString());

    var response = await parser.onSubmit(body);
    Get.back();
    if (response.statusCode == 200) {
      debugPrint(response.bodyString);
      // Get.find<ServicesController>().getServices();
      // successToast('Your Ad is succesfully submitted !');
      showAdSuccessDialog();
      //onBack();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void showAdSuccessDialog() {
    HapticFeedback.lightImpact();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Success Icon with Background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green[400]!,
                      Colors.green[600]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Success Title
              Text(
                'Success!'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Success Message
              Text(
                'Your Ad has been successfully submitted!'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),

              // Additional Info
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green[200]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Your ad will be visible for\n${adsDays.toString()} days.'
                          .tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeProvider.appColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              Row(
                children: [
                  // View Ads Button (Optional)

                  // OK Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: Colors.green.withOpacity(0.3),
                      ),
                      child: Text(
                        'Done'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  void updateStatus(int status) {
    selectedStatus = status;
    update();
  }

  // Future<void> getServiceById() async {
  //   var response = await parser.getServiceByID({"id": serviceId});
  //   apiCalled = true;
  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
  //     var body = myMap['data'];
  //     debugPrint(body.toString());
  //     cover = body['cover'];
  //     selectedCategoryId = body['cate_id'].toString();
  //     selectedServiceName = body['name'];
  //     selectedCategoryName = body['web_cates_data']['name'].toString();
  //     durationTextEditor.text = body['duration'].toString();
  //     priceTextEditor.text = body['price'].toString();
  //     discountTextEditor.text = body['discount'].toString();
  //     offTextEditor.text = body['off'].toString();
  //     descriptionsTextEditor.text = body['descriptions'];
  //     selectedStatus = body['status'];
  //     var imgs = jsonDecode(body['images']);
  //     gallery = [];
  //     imgs.forEach((element) {
  //       gallery.add(element.toString());
  //     });
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   update();
  // }

  // Future<void> onUpdateService() async {
  //   var body = {
  //     "name": selectedServiceName,
  //     "cate_id": selectedCategoryId,
  //     "duration": durationTextEditor.text,
  //     "price": priceTextEditor.text,
  //     "off": offTextEditor.text,
  //     "discount": discountTextEditor.text,
  //     "images": jsonEncode(gallery),
  //     "cover": cover,
  //     "extra_field": 'NA',
  //     "status": selectedStatus,
  //     "descriptions": descriptionsTextEditor.text,
  //     "id": serviceId
  //   };
  //   var response = await parser.onUpdateService(body);
  //   Get.back();
  //   if (response.statusCode == 200) {
  //     debugPrint(response.bodyString);
  //     Get.find<ServicesController>().getServices();
  //     successToast('services update !');
  //     onBack();
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  // }

  // void onRealPrice(var input) {
  //   if (input != '' && discountTextEditor.text != '') {
  //     double value = num.tryParse(input)!.toDouble();
  //     debugPrint(value.toString());
  //     double sellPriceFinal = num.tryParse(discountTextEditor.text)!.toDouble();
  //     if (sellPriceFinal > 0 && value > 1) {
  //       double discountPriceFinal =
  //           num.tryParse(discountTextEditor.text)!.toDouble();
  //       double realPrice = num.tryParse(priceTextEditor.text)!.toDouble();
  //       percentage(discountPriceFinal, realPrice);
  //     }
  //   }
  // }

  // void onDiscountPrice(var input) {
  //   if (input != '' && priceTextEditor.text != '') {
  //     double value = num.tryParse(input)!.toDouble();
  //     double realPrice = num.tryParse(priceTextEditor.text)!.toDouble();
  //     if (realPrice > 0 && value <= 99) {
  //       double discountPriceFinal =
  //           num.tryParse(discountTextEditor.text)!.toDouble();
  //       percentage(discountPriceFinal, realPrice);
  //     }
  //     if (value >= 99) {
  //       discountTextEditor.text = '';
  //       discountTextEditor.text = '99';
  //       showToast('Discount must be less than 100');
  //       update();
  //     }
  //   }
  // }

  // void percentage(double percent, double total) {
  //   double sum = (total * percent) / 100;
  //   sum = double.parse((sum).toStringAsFixed(2));
  //   debugPrint(sum.toString());
  //   double realPrice = num.tryParse(priceTextEditor.text)!.toDouble();
  //   offTextEditor.text = (realPrice - sum).toString();
  //   update();
  // }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
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
            gallery[index] = body['image_name'];
            update();
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    }
  }

  purchasePremium(BuildContext context) async {
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
                'Fields Required ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ThemeProvider.appColor,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
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
                style: TextStyle(color: ThemeProvider.whiteColor),
              ),
            ),
          ],
        ),
      );
    }

    // Validate required fields
    if (parser.getUID().isEmpty) {
      showValidationDialog('Please provide a valid UID.');
      return;
    }
    if (selectedDurationValue.isEmpty) {
      showValidationDialog('Please select duration.');
      return;
    }
    if (textControllerTitle.text.isEmpty) {
      showValidationDialog('Please enter a title.');
      return;
    }
    if (cover.isEmpty) {
      showValidationDialog('Please upload an ad image.');
      return;
    }
    try {
      EasyLoading.show(status: 'Please wait...');

      final purchaseResult = await Adapty().makePurchase(product: adaptyProduct);

      switch (purchaseResult) {
        case AdaptyPurchaseResultSuccess():
          EasyLoading.dismiss();
          onSubmit();
          Fluttertoast.showToast(
              msg: "Purchase Successful",
              toastLength: Toast.LENGTH_LONG,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.lightBlue,
              textColor: Colors.white,
              fontSize: 16.0);
          break;
        case AdaptyPurchaseResultPending():
          EasyLoading.dismiss();
          Fluttertoast.showToast(
              msg: "Purchase is pending...",
              toastLength: Toast.LENGTH_LONG,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              fontSize: 16.0);
          break;
        case AdaptyPurchaseResultUserCancelled():
          EasyLoading.dismiss();
          Fluttertoast.showToast(
              msg: "Purchase cancelled",
              toastLength: Toast.LENGTH_LONG,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0);
          break;
        default:
          EasyLoading.dismiss();
          Fluttertoast.showToast(
              msg: "Purchase failed, Try Again",
              toastLength: Toast.LENGTH_LONG,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
      }
    } on AdaptyError catch (e) {
      EasyLoading.dismiss();
      print("Adapty Error: $e");
      Fluttertoast.showToast(
          msg: "Purchase failed: ${e.message}",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      EasyLoading.dismiss();
      print("Adapty $e");
      Fluttertoast.showToast(
          msg: "Purchase failed, Unhandled Exception",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    update();
  }

  getOfferingsHome() async {
    final Map<String, PaywallsListItem> _paywallsItems = {};
    AdaptyPaywall? paywall;
    String id = 'AdsHome';
    try {
      paywall = await Adapty().getPaywall(placementId: 'adsHome');
      loadProductsHome(paywall);
    } on AdaptyError catch (e) {
      _paywallsItems[id] = PaywallsListItem(id: id, error: e);
    } catch (e) {}
  }

  getOfferingsSearch() async {
    final Map<String, PaywallsListItem> _paywallsItems = {};
    AdaptyPaywall? paywall;
    String id = 'AdsSearch';
    try {
      paywall = await Adapty().getPaywall(placementId: 'adsSearch');
      loadProductsSearch(paywall);
    } on AdaptyError catch (e) {
      _paywallsItems[id] = PaywallsListItem(id: id, error: e);
    } catch (e) {}
  }

  Future<void> loadProductsHome(AdaptyPaywall paywallNew) async {
    paywallProductsHome =
        await Adapty().getPaywallProducts(paywall: paywallNew);
    // notifyListeners();
    update();
  }

  Future<void> loadProductsSearch(AdaptyPaywall paywallNew) async {
    paywallProductsSearch =
        await Adapty().getPaywallProducts(paywall: paywallNew);
    // notifyListeners();
    update();
  }

  void onServiceCategories() {
    Get.delete<ServicesCategoriesController>(force: true);
    Get.toNamed(AppRouter.getServicesCategoriesRoute());
    update();
  }

  void onServiceNames(String catId) {
    Get.delete<ServicesNamesController>(force: true);
    Get.toNamed(AppRouter.getServicesNamesRoute(), arguments: catId);
    update();
  }
}
