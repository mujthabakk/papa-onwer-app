import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_services_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_names_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class AddServicesController extends GetxController implements GetxService {
  final AddServicesParser parser;

  String title = 'Add Service'.tr;
  XFile? _selectedImage;

  List<String> gallery = ['', '', '', '', '', ''];

  String selectedServiceName = '';
  String selectedCategoryName = '';

  String selectedServicesId = '';
  String selectedCategoryId = '';

  //final nameTextEditor = TextEditingController();
  final durationTextEditor = TextEditingController();
  final durationHoursEditor = TextEditingController();
  final durationMinutesEditor = TextEditingController();
  final priceTextEditor = TextEditingController();
  final discountTextEditor = TextEditingController();
  final offTextEditor = TextEditingController();
  final descriptionsTextEditor = TextEditingController();
  int selectedStatus = 1;
  int selectedType = 0;
  int editType = 0;

  bool apiCalled = false;

  String cover = '';

  int serviceId = 0;
  // int catId = 0;
  String action = 'new';

  double tax = 0.0;
  String currencySymbol = '₹';
  String currencySide = 'left';

  String get finalPriceWithTax {
    if (offTextEditor.text.isNotEmpty) {
      double sellPrice = double.tryParse(offTextEditor.text) ?? 0.0;
      return (sellPrice + (sellPrice * tax / 100)).toStringAsFixed(2);
    }
    return '0.00';
  }

  int get durationTotalMinutes {
    final hours = int.tryParse(durationHoursEditor.text) ?? 0;
    final minutes = int.tryParse(durationMinutesEditor.text) ?? 0;
    return (hours * 60) + minutes;
  }

  void syncDurationFromFields() {
    durationTextEditor.text = durationTotalMinutes.toString();
  }

  void applyDurationFromApi(dynamic raw) {
    final digits = raw.toString().replaceAll(RegExp(r'[^0-9]'), '');
    final total = int.tryParse(digits) ?? 0;
    durationHoursEditor.text = total >= 60 ? '${total ~/ 60}' : '';
    durationMinutesEditor.text = (total % 60).toString();
    durationTextEditor.text = total.toString();
  }

  Future<void> _showSuccessThenBack(String message) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            Text('Success'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: ThemeProvider.appColor,
            ),
            child: Text('OK'.tr,
                style: const TextStyle(color: ThemeProvider.whiteColor)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    onBack();
  }

  AddServicesController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    tax = parser.getTax();
    currencySymbol = parser.getCurrencySymbol();
    currencySide = parser.getCurrencySide();
    // catId = Get.arguments[1] as int;

    if (Get.arguments[0] == 'edit') {
      // catId = Get.arguments[2] as int;
      editType = 1;
      action = 'edit';
      serviceId = Get.arguments[1] as int;
      debugPrint('service id --> $serviceId');
      getServiceById();
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

  Future<void> onSubmit() async {
    void showValidationDialog(String message) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: ThemeProvider.whiteColor,
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Field Required ',
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
            style: TextStyle(fontSize: 16, color: Colors.black87),
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
              child: Text(
                'OK',
                style: TextStyle(color: ThemeProvider.whiteColor),
              ),
            ),
          ],
        ),
      );
    }
    // if (
    //     // nameTextEditor.text == '' ||
    //     //   nameTextEditor.text.isEmpty ||

    //     selectedCategoryId == '' ||
    //         selectedCategoryName.isEmpty ||
    //         selectedServicesId == '' ||
    //         selectedServicesId.isEmpty ||
    //         durationTextEditor.text == '' ||
    //         durationTextEditor.text.isEmpty ||
    //         priceTextEditor.text == '' ||
    //         priceTextEditor.text.isEmpty ||
    //         discountTextEditor.text == '' ||
    //         discountTextEditor.text.isEmpty ||
    //         descriptionsTextEditor.text == '' ||
    //         descriptionsTextEditor.text.isEmpty ||
    //         cover == '' ||
    //         cover.isEmpty) {
    //   showToast('All fields are required!');
    //   return;
    // }
    if (cover.isEmpty) {
      showValidationDialog('Please upload a service image.');
      return;
    }
    if (selectedCategoryId.isEmpty) {
      showValidationDialog('Please select a category.');
      return;
    }
    if (selectedCategoryName.isEmpty) {
      showValidationDialog('Please enter a category name.');
      return;
    }
    if (selectedServicesId.isEmpty) {
      showValidationDialog('Please select a service.');
      return;
    }
    if (durationTotalMinutes <= 0) {
      showValidationDialog('Please enter duration in hours or minutes.');
      return;
    }
    if (priceTextEditor.text.isEmpty) {
      showValidationDialog('Please enter a price.');
      return;
    }
    if (discountTextEditor.text.isEmpty) {
      showValidationDialog('Please enter a discount value.');
      return;
    }
    if (descriptionsTextEditor.text.isEmpty) {
      showValidationDialog('Please enter a description.');
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

    var body = {
      "uid": parser.getUID(),
      "name": selectedServiceName,
      "service_id": selectedServicesId,
      "cate_id": selectedCategoryId,
      "duration": durationTotalMinutes.toString(),
      "price": priceTextEditor.text,
      "off": offTextEditor.text,
      "discount": discountTextEditor.text,
      "images": jsonEncode(gallery),
      "cover": cover,
      "extra_field": 'NA',
      "status": selectedStatus,
      "gender": selectedType,
      "descriptions": descriptionsTextEditor.text,
    };

    var response = await parser.onSubmit(body);
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    if (response.statusCode == 200) {
      debugPrint(response.bodyString);
      if (Get.isRegistered<ServicesController>()) {
        Get.find<ServicesController>().getServices();
      }
      await _showSuccessThenBack('Service added successfully.'.tr);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void updateStatus(int status) {
    selectedStatus = status;
    update();
  }

  void updateType(int type) {
    selectedType = type;
    update();
  }

  Future<void> getServiceById() async {
    var response = await parser.getServiceByID({"id": serviceId});
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'];
      debugPrint(body.toString());
      cover = body['cover'];
      selectedCategoryId = body['cate_id'].toString();
      selectedServiceName = body['name'];
      selectedServicesId = body['service_id'].toString();
      selectedType = body['gender'];
      selectedCategoryName = body['web_cates_data']['name'].toString();
      durationTextEditor.text = body['duration'].toString();
      applyDurationFromApi(body['duration']);
      priceTextEditor.text = body['price'].toString();
      discountTextEditor.text = body['discount'].toString();
      offTextEditor.text = body['off'].toString();
      descriptionsTextEditor.text = body['descriptions'];
      selectedStatus = body['status'];
      var imgs = jsonDecode(body['images']);
      gallery = [];
      imgs.forEach((element) {
        gallery.add(element.toString());
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> onUpdateService() async {
    if (cover.isEmpty) {
      showToast('Please upload a service image.');
      return;
    }
    if (selectedCategoryId.isEmpty) {
      showToast('Please select a category.');
      return;
    }
    if (selectedServicesId.isEmpty) {
      showToast('Please select a service.');
      return;
    }
    if (durationTotalMinutes <= 0 ||
        priceTextEditor.text.isEmpty ||
        discountTextEditor.text.isEmpty ||
        descriptionsTextEditor.text.isEmpty) {
      showToast('All fields are required!');
      return;
    }

    Get.dialog(
      SimpleDialog(
        children: [
          Row(
            children: [
              const SizedBox(width: 30),
              const CircularProgressIndicator(color: ThemeProvider.appColor),
              const SizedBox(width: 30),
              SizedBox(
                child: Text(
                  "Please wait".tr,
                  style: const TextStyle(fontFamily: 'bold'),
                ),
              ),
            ],
          )
        ],
      ),
      barrierDismissible: false,
    );

    var body = {
      "name": selectedServiceName,
      "cate_id": selectedCategoryId,
      "service_id": selectedServicesId,
      "gender": selectedType,
      "duration": durationTotalMinutes.toString(),
      "price": priceTextEditor.text,
      "off": offTextEditor.text,
      "discount": discountTextEditor.text,
      "images": jsonEncode(gallery),
      "cover": cover,
      "extra_field": 'NA',
      "status": selectedStatus,
      "descriptions": descriptionsTextEditor.text,
      "id": serviceId
    };
    var response = await parser.onUpdateService(body);
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    if (response.statusCode == 200) {
      debugPrint(response.bodyString);
      if (Get.isRegistered<ServicesController>()) {
        Get.find<ServicesController>().getServices();
      }
      await _showSuccessThenBack('Service updated successfully.'.tr);
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void onRealPrice(var input) {
    if (input != '') {
      double realPrice = double.tryParse(input.toString()) ?? 0.0;
      double discount = double.tryParse(discountTextEditor.text) ?? 0.0;
      percentage(discount, realPrice);
    } else {
      offTextEditor.text = '';
      update();
    }
  }

  void onDiscountPrice(var input) {
    if (input != '') {
      double discount = double.tryParse(input.toString()) ?? 0.0;
      if (discount >= 100) {
        discount = 99.0;
        discountTextEditor.text = '99';
        showToast('Discount must be less than 100');
      }
      double realPrice = double.tryParse(priceTextEditor.text) ?? 0.0;
      percentage(discount, realPrice);
    } else {
      double realPrice = double.tryParse(priceTextEditor.text) ?? 0.0;
      percentage(0.0, realPrice);
    }
  }

  void percentage(double percent, double total) {
    double sum = (total * percent) / 100;
    sum = double.parse(sum.toStringAsFixed(2));
    debugPrint(sum.toString());
    offTextEditor.text = (total - sum).toStringAsFixed(2);
    update();
  }

  void onBack() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    Get.back(result: true);
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
      if (Get.isDialogOpen == true) {
        Get.back();
      }
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
      if (Get.isDialogOpen == true) {
        Get.back();
      }
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

  void onServiceCategories() {
    Get.delete<ServicesCategoriesController>(force: true);
    Get.toNamed(AppRouter.getServicesCategoriesRoute());
  }

  void onServiceNames(int catId) {
    if (catId <= 0) {
      showToast('Please select a category first');
      return;
    }
    debugPrint('CategoryID $catId');
    Get.delete<ServicesNamesController>(force: true);
    Get.toNamed(AppRouter.getServicesNamesRoute(), arguments: [catId]);
  }
}
