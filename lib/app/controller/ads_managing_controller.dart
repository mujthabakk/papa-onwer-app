import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/ad_managing_model.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_names_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';
import '../backend/parse/ads_managing_parse.dart';

class PaywallsListItem {
  String id;
  AdaptyPaywall? paywall;
  AdaptyError? error;
  PaywallsListItem({required this.id, this.paywall, this.error});
}

class AdsManagingController extends GetxController implements GetxService {
  final adapty = Adapty();

  List<AdaptyPaywallProduct>? paywallProductsHome;
  List<AdaptyPaywallProduct>? paywallProductsSearch;

  final AdsManagingParser parser;

  String title = 'Manage Ads';
  XFile? _selectedImage;

  List<String> gallery = ['', '', '', '', '', ''];

  String selectedServiceName = '';
  String selectedCategoryName = '';

  String selectedServicesId = '';
  String selectedCategoryId = '';

  int? selectedTypeValue;

  String selectedDurationValue = '';
  int? selectedPagePositionValue = 1;

  String selectedPrice = "";

  final TextEditingController nameTextEditor = TextEditingController();

  // Map<String, int> dropdownItemsType = {
  //   'Shop Page': 2,
  //   // 'External Link': 6,
  // };
  // late List<GlassfySku> skuListHome;
  //late List<GlassfySku> skuListSearch;

  // late GlassfySku sku;

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

  // Map<String, int> dropdownItemsPosition = {
  //   'Home Page': 1,
  //   'Search Page': 2,
  // };

  bool isSearchPage = true;
  num? adPrice = 0;

  var adListings = <AdsManagingModel>[].obs;
  var isLoading = true.obs;

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

  // int serviceId = 0;
  String action = 'new';

  AdsManagingController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    getServiceById();

    if (Get.arguments[0] == 'edit') {
      action = 'edit';
      // serviceId = Get.arguments[1] as int;
    } else {
      apiCalled = true;
    }
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

  // Future<void> onSubmit() async {
  //   if (

  //       // nameTextEditor.text == '' ||
  //       //   nameTextEditor.text.isEmpty ||

  //       parser.getUID == '' ||
  //           // selectedCategoryName.isEmpty ||
  //           //selectedServicesId == '' ||
  //           selectedDurationValue == '' ||
  //           //   durationTextEditor.text == '' ||
  //           // durationTextEditor.text.isEmpty ||
  //           //  priceTextEditor.text == '' ||
  //           // priceTextEditor.text.isEmpty ||
  //           // discountTextEditor.text == '' ||
  //           // discountTextEditor.text.isEmpty ||
  //           textControllerTitle.text.isEmpty ||
  //           cover == '' ||
  //           cover.isEmpty) {
  //     showToast('All fields are required!');
  //     return;
  //   }

  //   Get.dialog(
  //     SimpleDialog(
  //       children: [
  //         Row(
  //           children: [
  //             const SizedBox(
  //               width: 30,
  //             ),
  //             const CircularProgressIndicator(
  //               color: ThemeProvider.appColor,
  //             ),
  //             const SizedBox(
  //               width: 30,
  //             ),
  //             SizedBox(
  //                 child: Text(
  //               "Please wait".tr,
  //               style: const TextStyle(fontFamily: 'bold'),
  //             )),
  //           ],
  //         )
  //       ],
  //     ),
  //     barrierDismissible: false,
  //   );

  //   var body = {
  //     "uid": parser.getUID(),
  //     "cover": cover,
  //     "days": selectedDurationValue,
  //     "position": selectedPagePositionValue! - 1,
  //     "title": textControllerTitle.text,
  //     "price": adPrice,
  //   };

  //   var response = await parser.onSubmit(body);
  //   Get.back();
  //   if (response.statusCode == 200) {
  //     debugPrint(response.bodyString);
  //     // Get.find<ServicesController>().getServices();
  //     successToast('Your Ad is succesfully submitted !');
  //     onBack();
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   update();
  // }

  void updateStatus(int status) {
    selectedStatus = status;
    update();
  }

  Future<void> getServiceById() async {
    var response = await parser.getListAds({"uid": parser.getUID()});
    apiCalled = true;
    if (response.statusCode == 200) {
      var adListingsData = response.body['data'] as List;
      adListingsData = adListingsData.reversed.toList();
      adListings.value = adListingsData
          .map((json) => AdsManagingModel.fromJson(json))
          .toList();
      isLoading.value = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> deleteAds(int? id) async {
    var response = await parser.postDeleteAd({"id": id});
    apiCalled = true;
    if (response.statusCode == 200) {
      bool success = response.body['success'];
      if (success) {
        successToast('Your Ad is succesfully deleted !');
        deleteAdListing(id!);
      }
      isLoading.value = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> updateAdListing(
      int id, String title, String cover, String? link) async {
    try {
      // Prepare data for API call
      Map<String, dynamic> payload = {
        'id': id.toString(),
        'title': title,
        'cover': cover,
        if (link != null && link.isNotEmpty) 'link': link,
      };

      // Set loading state
      isLoading.value = true;

      // Make API call to update the ad
      var response = await parser.postUpdateAds(payload);
      apiCalled = true;

      if (response.statusCode == 200) {
        bool success = response.body['success'] ?? false;
        if (success) {
          successToast('Your Ad is successfully updated!');
        } else {
          showToast(
              'Failed to update ad: ${response.body['message'] ?? 'Unknown error'}');
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      showToast('An error occurred while updating the ad: $e');
    } finally {
      isLoading.value = false;
      update(); // Notify listeners to update UI
    }
  }

  void deleteAdListing(int id) {
    adListings.removeWhere((element) => element.id == id);
    update();
  }

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

  void selectFromGallery(String kind, int position) async {
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
            adListings[position].cover.value = cover;

            update();
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    }
  }

  // purchasePremium(
  //     BuildContext context, AdaptyPaywallProduct paywallProducts) async {
  //   if (parser.getUID == '' ||
  //       selectedDurationValue == '' ||
  //       textControllerTitle.text.isEmpty ||
  //       cover == '' ||
  //       cover.isEmpty) {
  //     showToast('All fields are required!');
  //     return;
  //   }

  //   try {
  //     EasyLoading.show(status: 'Please wait...');
  //     // var sku = await Glassfy.skuWithId('no_ai_premium_subscription_6.99');
  //     final profile = await Adapty().makePurchase(product: paywallProducts);

  //     //final profile = await Adapty().getProfile();

  //     // Check the access level or subscription status
  //     // final accessLevel = profile.accessLevels['premium'];

  //     if (profile!.nonSubscriptions.isNotEmpty) {
  //       // premiumFlag = true;
  //       EasyLoading.dismiss();
  //       onSubmit();

  //       Fluttertoast.showToast(
  //           msg: "Purchase Successful",
  //           toastLength: Toast.LENGTH_LONG,
  //           timeInSecForIosWeb: 1,
  //           backgroundColor: Colors.lightBlue,
  //           textColor: Colors.white,
  //           fontSize: 16.0);

  //       //notifyListeners();
  //     } else {
  //       EasyLoading.dismiss();
  //       Fluttertoast.showToast(
  //           msg: "Purchase failed, Try Again",
  //           toastLength: Toast.LENGTH_LONG,
  //           timeInSecForIosWeb: 1,
  //           backgroundColor: Colors.red,
  //           textColor: Colors.white,
  //           fontSize: 16.0);
  //     }
  //   } catch (e) {
  //     EasyLoading.dismiss();
  //     print("Adapty $e");
  //     Fluttertoast.showToast(
  //         msg: "Purchase failed, Try Again Later",
  //         toastLength: Toast.LENGTH_LONG,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0);
  //   }
  //   //EasyLoading.dismiss();
  //   update();
  // }

  getOfferingsHome() async {
    final Map<String, PaywallsListItem> _paywallsItems = {};
    AdaptyPaywall? paywall;
    String id = 'ads';
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
    String id = 'ads';
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

  // getOfferingsHome() async {
  //   try {
  //     var offerings = await Glassfy.offerings();
  //     var offering = offerings.all?.singleWhere(
  //       (offering) => offering.offeringId == 'premium-home',
  //     );
  //     if (offering != null) {
  //       skuListHome = offering.skus!;
  //       debugPrint(skuListHome.toString());
  //     }
  //   } catch (e) {
  //     print("Glassfy - Offerings $e");
  //   }
  //   update();
  // }

  // getOfferingsSearch() async {
  //   try {
  //     var offerings = await Glassfy.offerings();
  //     var offering = offerings.all?.singleWhere(
  //       (offering) => offering.offeringId == 'premium-search',
  //     );
  //     if (offering != null) {
  //       skuListSearch = offering.skus!;
  //       debugPrint(skuListSearch.toString());
  //     }
  //   } catch (e) {
  //     print("Glassfy - Offerings $e");
  //   }
  //   update();
  // }

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
