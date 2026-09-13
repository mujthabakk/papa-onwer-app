import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/individual_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/timing_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/individual_profile_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_timing_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/individual_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/individual_cities_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_menu_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';
import 'package:ultimate_salon_owner_flutter/app/util/coordinate_validator.dart';
import 'package:geolocator/geolocator.dart';

import 'facilities_controller.dart';
import 'holiday_controller.dart';

class IndividualProfileController extends GetxController
    implements GetxService {
  final IndividualProfileParser parser;

  final aboutTextEditor = TextEditingController();
  final addressTextEditor = TextEditingController();
  final zipCodeTextEditor = TextEditingController();
  final latTextEditor = TextEditingController();
  final lngTextEditor = TextEditingController();
  final websiteTextEditor = TextEditingController();

  final bankNameTextEditor = TextEditingController();
  final bankCNameTextEditor = TextEditingController();

  final bankIFSCTextEditor = TextEditingController();
  final accNoTextEditor = TextEditingController();
  final whatsappTextEditor = TextEditingController();

  final panTextEditor = TextEditingController();
  final gstTextEditor = TextEditingController();

  IndividualInfoModel _individualInfo = IndividualInfoModel();
  IndividualInfoModel get individualInfo => _individualInfo;

  XFile? _selectedImage;
  var cover = ''.obs;

  bool havePopular = false;
  bool haveShop = false;
  bool haveHome = false;
  List<TimingModel> _timesList = <TimingModel>[];
  List<TimingModel> get timesList => _timesList;
  List<String> dayList = [
    'Sunday'.tr,
    'Monday'.tr,
    'Tuesday'.tr,
    'Wednesday'.tr,
    'Thursday'.tr,
    'Friday'.tr,
    'Saturday'.tr
  ];

  bool apiCalled = false;

  IndividualProfileController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    getCateById();
    cover.value = parser.getCover();
  }

  Future<void> getCateById() async {
    var response = await parser.getIndividualById();
    apiCalled = true;
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      debugPrint(myMap.toString());
      _timesList = [];
      var data = myMap['data'];
      IndividualInfoModel invidualData = IndividualInfoModel.fromJson(data);
      _individualInfo = invidualData;

      ///cover.value = _individualInfo.background.toString();
      haveHome = _individualInfo.inHome == 1 ? true : false;
      haveShop = _individualInfo.haveShop == 1 ? true : false;
      havePopular = _individualInfo.popular == 1 ? true : false;
      aboutTextEditor.text = individualInfo.about.toString();
      addressTextEditor.text = individualInfo.address.toString();
      websiteTextEditor.text = individualInfo.website.toString();

      zipCodeTextEditor.text = individualInfo.zipcode.toString();
      latTextEditor.text = individualInfo.lat.toString();
      lngTextEditor.text = individualInfo.lng.toString();

      bankNameTextEditor.text = individualInfo.bankName.toString();
      bankIFSCTextEditor.text = individualInfo.bankIfsc.toString();
      bankCNameTextEditor.text = individualInfo.bankCustomerName.toString();
      accNoTextEditor.text = individualInfo.bankAccountNumber.toString();

      panTextEditor.text = individualInfo.pan.toString();
      gstTextEditor.text = individualInfo.vat.toString();
      whatsappTextEditor.text = individualInfo.whatsappNumber.toString();

      if (individualInfo.timing != 'NA') {
        var times = jsonDecode(individualInfo.timing.toString());
        times.forEach((element) {
          TimingModel datas = TimingModel.fromJson(element);
          _timesList.add(datas);
        });
      }

      parser.saveId(individualInfo.id.toString());
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
        barrierDismissible: false,
      );
      Response response = await parser.uploadImage(_selectedImage as XFile);
      Get.back();
      if (response.statusCode == 200) {
        _selectedImage = null;
        if (response.body['data'] != null && response.body['data'] != '') {
          dynamic body = response.body["data"];
          if (body['image_name'] != null && body['image_name'] != '') {
            cover.value = body['image_name'];
            debugPrint(cover.value);
            update();
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    }
  }

  void _showValidationDialog(String title, String message) {
    if (Get.overlayContext != null) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: ThemeProvider.appColor,
                  fontFamily: 'bold',
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: ThemeProvider.appColor,
                  fontFamily: 'medium',
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  void getCurrentLocation() async {
    print('get location');
    LocationPermission permission;

    // Check if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, ask the user to enable them.
      await Geolocator.openLocationSettings();
      return;
    }

    // Check if the app has permission to access location.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle accordingly.
        Get.snackbar(
          "Permission Denied",
          "Location permission is required to fetch coordinates.",
          backgroundColor: Colors.red,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle accordingly.
      Get.snackbar(
        "Permission Denied",
        "Location permissions are permanently denied. Enable them from settings.",
        backgroundColor: Colors.red,
      );
      return;
    }

    // Get the current location.
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Update the latitude and longitude fields in the controller.
      latTextEditor.text = position.latitude.toString();
      lngTextEditor.text = position.longitude.toString();

      update();
    } catch (e) {
      Get.snackbar(
          backgroundColor: Colors.red,
          "Error",
          "Failed to get current location: $e");
    }
  }

  Future<void> updateIndividual() async {
    // if (addressTextEditor.text == '' ||
    //     addressTextEditor.text.isEmpty ||
    //     latTextEditor.text == '' ||
    //     latTextEditor.text.isEmpty ||
    //     lngTextEditor.text == '' ||
    //     lngTextEditor.text.isEmpty ||
    //     zipCodeTextEditor.text == '' ||
    //     zipCodeTextEditor.text.isEmpty ||
    //     aboutTextEditor.text == '' ||
    //     aboutTextEditor.text.isEmpty ||
    //     backgroundCover == '' ||
    //     backgroundCover.isEmpty) {
    //   showToast('All fields are required!');
    //   return;
    // }

    if (cover.isEmpty) {
      _showValidationDialog(
          'Cover Image Missing', 'Please upload a cover image.');
      return;
    }

    if (addressTextEditor.text.isEmpty) {
      _showValidationDialog(
          'Address Missing', 'Please provide the salon address.');
      return;
    }
    String? latError = CoordinateValidator.validateLatitude(latTextEditor.text);
    if (latError != null) {
      _showValidationDialog('Latitude Error', latError);
      return;
    }
    String? lngError =
        CoordinateValidator.validateLongitude(lngTextEditor.text);
    if (lngError != null) {
      _showValidationDialog('Longitude Error', lngError);
      return;
    }
    if (zipCodeTextEditor.text.isEmpty) {
      _showValidationDialog('Pincode Missing', 'Please enter the Pincode.');
      return;
    }
    if (bankNameTextEditor.text.isEmpty) {
      _showValidationDialog('Bank Name Missing', 'Please enter the Bank name.');
      return;
    }

    if (bankCNameTextEditor.text.isEmpty) {
      _showValidationDialog(
          'Bank A/C Name Missing', 'Please enter the A/C name.');
      return;
    }
    if (bankIFSCTextEditor.text.isEmpty) {
      _showValidationDialog('IFSC Code Missing', 'Please enter the IFSC code.');
      return;
    }
    if (accNoTextEditor.text.isEmpty) {
      _showValidationDialog(
          'Account Number Missing', 'Please enter the account number.');
      return;
    }
    if (whatsappTextEditor.text.isEmpty) {
      _showValidationDialog(
          'Whatsapp Number Missing', 'Please enter the whatsapp number.');
      return;
    }
    if (panTextEditor.text.isEmpty) {
      _showValidationDialog('PAN Missing', 'Please enter the PAN number.');
      return;
    }

    if (aboutTextEditor.text.isEmpty) {
      _showValidationDialog(
          'About Section Missing', 'Please provide details about the salon.');
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
      "id": individualInfo.id,
      "address": addressTextEditor.text,
      "website": websiteTextEditor.text,
      "lat": latTextEditor.text,
      "lng": lngTextEditor.text,
      "zipcode": zipCodeTextEditor.text,
      "about": aboutTextEditor.text,
      "cover": cover.value,
      //"background": backgroundCover.value,

      "bank_name": bankNameTextEditor.text,
      "bank_account_number": accNoTextEditor.text,
      "bank_customer_name": bankCNameTextEditor.text,
      "bank_ifsc": bankIFSCTextEditor.text,
      "pan": panTextEditor.text,
      "vat": gstTextEditor.text,
      "whatsapp_number": whatsappTextEditor.text,

      "popular": havePopular == true ? 1 : 0,
      "have_shop": haveShop == true ? 1 : 0,
      "in_home": haveHome == true ? 1 : 0,
      "timing": _timesList.isNotEmpty ? jsonEncode(timesList) : 'NA'
    };

    debugPrint(body.toString());
    Response response = await parser.updateIndividual(body);
    Get.back();
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      SharedPreferences? sharedPreferences;
      sharedPreferences = await SharedPreferences.getInstance();
      ProfileController profileController = Get.find<ProfileController>();
      sharedPreferences.setString('cover', cover.value);
      profileController.cover.value = cover.value;
      onBack();
      successToast('Details Updated Successfully');
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  void onSaveCities(String cid, String name) {
    debugPrint('got from service list');
    update();
  }

  void updatePopular(bool status) {
    havePopular = status;
    update();
  }

  void updateShop(bool status) {
    haveShop = status;
    update();
  }

  void updateHome(bool status) {
    haveHome = status;
    update();
  }

  void onSelectCategories() {
    Get.delete<IndividualprofileCategoriesController>(force: true);
    Get.toNamed(AppRouter.getIndividualProfileCategoriesRoute(),
        arguments: [individualInfo.categories]);
  }

  void onSelectFacilities() {
    Get.delete<FacilitiesController>(force: true);
    Get.toNamed(
      AppRouter.getFacilities(),
    );
  }

  void onSelectCities() {
    Get.delete<IndividualCitiesController>(force: true);
    Get.toNamed(AppRouter.getIndividualCitiesRoute(),
        arguments: [individualInfo.cid]);
  }

  String getDayName(int dayNumber) {
    return dayList[dayNumber];
  }

  void onAddNewTiming() {
    Get.delete<AddTimingController>(force: true);
    Get.toNamed(AppRouter.getAddTimingRoute(), arguments: ['new']);
  }

  void onHoliday() {
    Get.delete<HolidayController>(force: true);
    Get.toNamed(AppRouter.getHolidayRoutes());
  }

  void onSaveTime(int dayNumber, String openTime, String closeTime) {
    debugPrint('get Data');
    var param = {
      "day": dayNumber,
      "open_time": openTime,
      "close_time": closeTime
    };
    TimingModel data = TimingModel.fromJson(param);
    _timesList.add(data);
    debugPrint(jsonEncode(timesList).toString());
    update();
  }

  void onEditTime(String dayName, String openTime, String closeTime) {
    Get.delete<AddTimingController>(force: true);
    Get.toNamed(AppRouter.getAddTimingRoute(),
        arguments: ['edit', dayName, openTime, closeTime]);
  }

  void deleteOpeningHours(int dayNumber, String openTime, String closeTime) {
    // debugPrint(dayNumber.toString() + openTime.toString() + closeTime);
    var index = _timesList.indexWhere((element) => element.day == dayNumber);
    debugPrint(index.toString());
    _timesList.removeAt(index);
    //  _timesList[index].day = dayNumber;
    // _timesList[index].openTime = openTime;
    // _timesList[index].closeTime = closeTime;
    update();
  }

  void updateTime(int dayNumber, String openTime, String closeTime) {
    debugPrint(dayNumber.toString() + openTime.toString() + closeTime);
    var index = _timesList.indexWhere((element) => element.day == dayNumber);
    debugPrint(index.toString());
    _timesList[index].day = dayNumber;
    _timesList[index].openTime = openTime;
    _timesList[index].closeTime = closeTime;
    update();
  }
}
