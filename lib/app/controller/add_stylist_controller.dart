import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/stylist_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_stylist_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/stylist_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/stylist_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/stylist_service_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class AddStylistController extends GetxController implements GetxService {
  final AddStylistParser parser;

  XFile? _selectedImage;
  String salonUid = '';
  String cover = '';

  String selectedCategories = '';
  String selectedServices = '';

  List<String> savedCategories = [];
  List<String> savedServices = [];

  int salonId = 0;

  bool apiCalled = false;

  String action = 'new';

  StylistModel _stylistInfo = StylistModel();
  StylistModel get stylistInfo => _stylistInfo;

  final firstNameTextEditor = TextEditingController();
  final lastNameTextEditor = TextEditingController();

  AddStylistController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments[0] == 'edit') {
      action = 'edit';
      salonId = Get.arguments[1] as int;
      debugPrint('salon id --> $salonId');
      getById();
    } else {
      apiCalled = true;
    }
  }

  Future<void> saveSpecialist() async {
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
    // Validate required fields
    if (firstNameTextEditor.text.isEmpty) {
      showValidationDialog('Please enter the first name.');
      return;
    }
    if (lastNameTextEditor.text.isEmpty) {
      showValidationDialog('Please enter the last name.');
      return;
    }

    if (selectedCategories.isEmpty) {
      showValidationDialog('Please select at least one category.');
      return;
    }
    // if (selectedServices.isEmpty) {
    //   showValidationDialog('Please select at least one service.');
    //   return;
    // }

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

    // Prepare the request body
    var body = {
      "salon_uid": parser.getUid(),
      "cate_id": selectedCategories,
      "service_id": '1',
      "cover": cover,
      "first_name": firstNameTextEditor.text,
      "last_name": lastNameTextEditor.text,
      "status": 1,
    };

    debugPrint(body.toString());

    // API call
    var response = await parser.onCreateSpecialist(body);
    Get.back();
    debugPrint(response.bodyString);

    if (response.statusCode == 200) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: ThemeProvider.whiteColor,
          title: Row(
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
          content: Text(
            'Specialist saved successfully!',
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
              child: Text(
                'OK',
                style: TextStyle(color: ThemeProvider.whiteColor),
              ),
            ),
          ],
        ),
      );

      Get.find<StylistController>().getBySalonId();
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
      _stylistInfo = StylistModel();
      var body = myMap['data'];
      StylistModel info = StylistModel.fromJson(body);
      _stylistInfo = info;
      selectedCategories = _stylistInfo.cateId as String;
      //selectedServices = stylistInfo.service_id as String;
      cover = stylistInfo.cover as String;
      firstNameTextEditor.text = _stylistInfo.firstName.toString();
      lastNameTextEditor.text = _stylistInfo.lastName.toString();
      for (var element in _stylistInfo.webCatesData!) {
        savedCategories.add(element.name.toString());
      }
      for (var element in _stylistInfo.webCatesData!) {
        savedServices.add(element.name.toString());
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
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

  Future<void> onUpdateSpecialist() async {
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
      "cate_id": selectedCategories,
      "service_id": '1',
      "cover": cover,
      "first_name": firstNameTextEditor.text,
      "last_name": lastNameTextEditor.text,
      "id": salonId
    };
    var response = await parser.onUpdateService(body);
    Get.back();
    if (response.statusCode == 200) {
      debugPrint(response.bodyString);
      onBack();
      successToast('services update !');
      Get.find<StylistController>().getBySalonId();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void onSaveCategory(
    String categoriesId,
    //String serviceIds,
    List<String> categoryNames,
    // List<String> serviceNames
  ) {
    selectedCategories = categoriesId;
    // selectedServices = serviceIds;

    savedCategories = categoryNames;
    // savedServices = serviceNames;
    //  debugPrint('add specialist services $serviceIds');
    debugPrint('add specialist categories $categoriesId');
    update();
  }

  // void onSaveService(
  //     // String categoriesId,
  //     String serviceIds,
  //     //List<String> categoryNames,
  //     List<String> serviceNames) {
  //   // selectedCategories = categoriesId;
  //   selectedServices = serviceIds;

  //   //savedCategories = categoryNames;
  //   savedServices = serviceNames;
  //   debugPrint('add specialist services $serviceIds');
  //   // debugPrint('add specialist categories $categoriesId');
  //   update();
  // }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  // void onSelectStylistServices() {
  //   Get.delete<StylistServiceController>(force: true);
  //   Get.toNamed(AppRouter.getStylistServiceRoute(),
  //       arguments: [selectedServices]);
  // }

  void onSelectStylistCategories() {
    Get.delete<StylistCategoriesController>(force: true);
    Get.toNamed(AppRouter.getStylistCategoriesRoute(),
        arguments: [selectedCategories]);
  }
}
