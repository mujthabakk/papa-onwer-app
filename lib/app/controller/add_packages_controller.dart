import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/packages_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_packages_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/packages_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/packages_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/packages_specialist_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/tax_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class AddPackagesController extends GetxController implements GetxService {
  final AddPackagesParser parser;

  XFile? _selectedImage;
  String cover = '';

  bool userType = true;

  bool apiCalled = false;
  int selectedType = 3;

  int salonId = 0;
  int individualId = 1;

  PackagesModel _packagesInfo = PackagesModel();
  PackagesModel get packagesInfo => _packagesInfo;

  List<String> gallery = ['', '', '', '', '', ''];

  String selectedServicesName = '';
  String selectedServicesId = '';
  List<String> savedServices = [];

  String selectedSpecialistId = '';
  String selectedSpecialistName = '';

  //String selectedCategories = '';
  // List<String> savedCategories = [];

  String selectedSpecialist = '';
  List<String> savedSpecialist = [];

  String action = 'new';

  final packagesNameTextEditor = TextEditingController();
  final priceTextEditor = TextEditingController();
  final discountTextEditor = TextEditingController();
  final sellPriceTextEditor = TextEditingController();
  final descriptionTextEditor = TextEditingController();
  final durationTextEditor = TextEditingController();
  final durationHoursEditor = TextEditingController();
  final durationMinutesEditor = TextEditingController();
  int editType = 0;

  double tax = 0.0;
  String currencySymbol = CurrencyHelper.displaySymbol();
  String currencySide = 'left';

  String get finalPriceWithTax {
    if (sellPriceTextEditor.text.isNotEmpty) {
      final sellPrice = double.tryParse(sellPriceTextEditor.text) ?? 0.0;
      return CurrencyHelper.inclusiveFixed(sellPrice);
    }
    return '0.00';
  }

  int get durationTotalMinutes {
    final hours = int.tryParse(durationHoursEditor.text) ?? 0;
    final minutes = int.tryParse(durationMinutesEditor.text) ?? 0;
    return (hours * 60) + minutes;
  }

  void applyDurationFromApi(dynamic raw) {
    final digits = raw.toString().replaceAll(RegExp(r'[^0-9]'), '');
    final total = int.tryParse(digits) ?? 0;
    durationHoursEditor.text = total >= 60 ? '${total ~/ 60}' : '';
    durationMinutesEditor.text = (total % 60).toString();
    durationTextEditor.text = total.toString();
  }

  AddPackagesController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    tax = TaxHelper.isAvailable ? parser.getTax() : 0.0;
    currencySymbol = parser.getCurrencySymbol();
    currencySide = parser.getCurrencySide();
    userType = parser.getType();
    if (Get.arguments[0] == 'edit') {
      action = 'edit';
      editType = 1;
      salonId = Get.arguments[1] as int;
      debugPrint('packages id --> $salonId');
      getById();
    } else {
      apiCalled = true;
    }
  }

  void updateType(int type) {
    selectedType = type;
    update();
  }

  Future<void> onSave() async {
    // Helper function to show a validation dialog
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
                'Fields Required',
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

    if (cover.isEmpty) {
      showValidationDialog('Please upload a cover image.');
      return;
    }
    if (selectedServicesId.isEmpty) {
      showValidationDialog('Please select at least one service.');
      return;
    }
    // Validate required fields
    if (packagesNameTextEditor.text.isEmpty) {
      showValidationDialog('Please enter the package name.');
      return;
    }

    if (durationTotalMinutes <= 0) {
      showValidationDialog('Please enter duration in hours or minutes.');
      return;
    }
    if (priceTextEditor.text.isEmpty) {
      showValidationDialog('Please enter the price.');
      return;
    }
    if (discountTextEditor.text.isEmpty) {
      showValidationDialog('Please enter the discount.');
      return;
    }
    if (descriptionTextEditor.text.isEmpty) {
      showValidationDialog('Please enter the description.');
      return;
    }

    if (userType == true && selectedSpecialist.isEmpty) {
      showValidationDialog('Please select a specialist.');
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
              SizedBox(width: 30),
              CircularProgressIndicator(
                color: ThemeProvider.appColor,
              ),
              SizedBox(width: 30),
              Text(
                "Please wait".tr,
                style: TextStyle(
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

    // Prepare the request body
    var body = {
      "uid": parser.getUId(),
      "package_from": userType == true ? 0 : 1,
      "service_id": selectedServicesId,
      "specialist_ids": selectedSpecialist,
      "name": packagesNameTextEditor.text,
      "price": priceTextEditor.text,
      "gender": selectedType,
      "off": sellPriceTextEditor.text,
      "discount": discountTextEditor.text,
      "duration": durationTotalMinutes.toString(),
      "descriptions": descriptionTextEditor.text,
      "cover": cover,
      "images": jsonEncode(gallery),
      "extra_field": 'NA',
    };

    debugPrint(body.toString());
    gallery = gallery.where((element) => element.isNotEmpty).toList();

    // API call
    var response = await parser.onCreateProducts(body);
    Get.back();
    debugPrint(response.bodyString);

    if (response.statusCode == 200) {
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
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ThemeProvider.appColor,
                ),
              ),
            ],
          ),
          content: const Text(
            'Package saved successfully!',
            style: TextStyle(fontSize: 16, color: Colors.black87),
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
                style: TextStyle(color: ThemeProvider.whiteColor),
              ),
            ),
          ],
        ),
      );

      Get.find<PackagesController>().getByPackagesId();
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future<void> getById() async {
    var response = await parser.getByID({"id": salonId});
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      _packagesInfo = PackagesModel();
      var body = myMap['data'];
      PackagesModel info = PackagesModel.fromJson(body);
      _packagesInfo = info;
      cover = _packagesInfo.cover.toString();
      selectedServicesId = _packagesInfo.serviceId.toString();
      selectedSpecialist = _packagesInfo.specialistIds.toString();
      selectedType = _packagesInfo.gender!;

      packagesNameTextEditor.text = _packagesInfo.name.toString();
      priceTextEditor.text = _packagesInfo.price.toString();
      sellPriceTextEditor.text = _packagesInfo.off.toString();
      discountTextEditor.text = _packagesInfo.discount.toString();
      durationTextEditor.text = _packagesInfo.duration.toString();
      applyDurationFromApi(_packagesInfo.duration);
      descriptionTextEditor.text = _packagesInfo.descriptions.toString();

      for (var element in _packagesInfo.services!) {
        savedServices.add(element.name.toString());
      }

      if (_packagesInfo.specialist != null) {
        for (var element in _packagesInfo.specialist!) {
          savedSpecialist.add('${element.firstName} ${element.lastName}');
        }
      }

      var images = jsonDecode(_packagesInfo.images.toString());
      if (images.length > 0) {
        int index = 0;
        images.forEach((element) {
          gallery[index] = element;
          index++;
        });
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> onUpdate() async {
    if (packagesNameTextEditor.text == '' ||
        packagesNameTextEditor.text.isEmpty ||
        selectedServicesId == '' ||
        selectedServicesId.isEmpty ||
        durationTotalMinutes <= 0 ||
        priceTextEditor.text == '' ||
        priceTextEditor.text.isEmpty ||
        discountTextEditor.text == '' ||
        discountTextEditor.text.isEmpty ||
        descriptionTextEditor.text == '' ||
        descriptionTextEditor.text.isEmpty ||
        cover == '' ||
        cover.isEmpty) {
      showToast('All fields are required!');
      return;
    }

    if (userType == true) {
      if (selectedSpecialist == '' || selectedSpecialist.isEmpty) {
        showToast('Please select specialist');
        return;
      }
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
      "id": salonId,
      "service_id": selectedServicesId,
      "specialist_ids": selectedSpecialist,
      "name": packagesNameTextEditor.text,
      "price": priceTextEditor.text,
      "off": sellPriceTextEditor.text,
      "discount": discountTextEditor.text,
      "gender": selectedType,
      "duration": durationTotalMinutes.toString(),
      "descriptions": descriptionTextEditor.text,
      "cover": cover,
      "images": jsonEncode(gallery),
      "extra_field": 'NA',
    };
    var response = await parser.updatePackages(body);
    Get.back();
    if (response.statusCode == 200) {
      debugPrint(response.bodyString);
      successToast('packages update !');
      Get.find<PackagesController>().getByPackagesId();
      onBack();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  void onSaveCategory(String categoriesId, List<String> names, double price) {
    selectedServicesId = categoriesId;
    savedServices = names;
    debugPrint('add categories $categoriesId');
    priceTextEditor.text = price.toString();
    update();
  }

  void onClearAll() {
    selectedServicesId = '';
    savedServices = [];
    priceTextEditor.text = '';
    update();
  }

  void onSaveSpecialistCate(String specialistId, List<String> names) {
    selectedSpecialist = specialistId;
    savedSpecialist = names;
    debugPrint('add specialist $specialistId');
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
            gallery[index] = body['image_name'];
            update();
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    }
  }

  void onRealPrice(var input) {
    if (input != '') {
      double realPrice = double.tryParse(input) ?? 0.0;
      double discount = double.tryParse(discountTextEditor.text) ?? 0.0;
      percentage(discount, realPrice);
    } else {
      sellPriceTextEditor.text = '';
      update();
    }
  }

  void onDiscountPrice(var input) {
    if (input != '') {
      double discount = double.tryParse(input) ?? 0.0;
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
    sellPriceTextEditor.text =
        CurrencyHelper.discountedPrice(total, percent).toStringAsFixed(2);
    update();
  }

  void onSelectPackages() {
    Get.delete<PackagesCategoriesController>(force: true);
    Get.toNamed(AppRouter.getPackagesCategoriesRoute(),
        arguments: [selectedServicesId, savedServices]);
  }

  void onSelectSpecialist() {
    Get.delete<PackagesSpecialistController>(force: true);
    Get.toNamed(AppRouter.getPackagesSpecialistRoute(),
        arguments: [selectedSpecialist, savedSpecialist]);
  }
}
