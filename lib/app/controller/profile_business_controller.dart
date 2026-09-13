import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/profile_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/timing_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/profile_categories_parser.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_timing_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/cities_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/facilities_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/holiday_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_menu_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/salon_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/coordinate_validator.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';
import 'package:geolocator/geolocator.dart';

class ProfileCategoriesController extends GetxController
    implements GetxService {
  final ProfileCategoriesParse parser;

  final salonNameTextEditor = TextEditingController();
  final aboutTextEditor = TextEditingController();
  final addressTextEditor = TextEditingController();
  final websiteTextEditor = TextEditingController();

  final zipCodeTextEditor = TextEditingController();
  final latTextEditor = TextEditingController();
  final lngTextEditor = TextEditingController();

  final bankNameTextEditor = TextEditingController();
  final bankCNameTextEditor = TextEditingController();

  final bankIFSCTextEditor = TextEditingController();
  final accNoTextEditor = TextEditingController();
  final whatsappTextEditor = TextEditingController();

  final panTextEditor = TextEditingController();
  final gstTextEditor = TextEditingController();

  ProfileModel _profileInfo = ProfileModel();
  ProfileModel get profileInfo => _profileInfo;

  XFile? _selectedImage;
  String cover = '';

  bool apiCalled = false;

  bool haveStylist = false;
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
  ProfileCategoriesController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    getCateById();
  }

  Future<void> getCateById() async {
    var response = await parser.getCateById();
    apiCalled = true;
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      debugPrint(myMap.toString());
      _timesList = [];
      var data = myMap['data'];
      ProfileModel profileData = ProfileModel.fromJson(data);
      _profileInfo = profileData;
      cover = _profileInfo.cover.toString();
      haveStylist = _profileInfo.haveStylist == 1 ? true : false;
      haveShop = _profileInfo.haveShop == 1 ? true : false;
      haveHome = _profileInfo.serviceAtHome == 1 ? true : false;
      salonNameTextEditor.text = profileInfo.name.toString();
      aboutTextEditor.text = profileInfo.about.toString();
      addressTextEditor.text = profileInfo.address.toString();
      websiteTextEditor.text = profileInfo.website.toString();

      zipCodeTextEditor.text = profileInfo.zipcode.toString();
      latTextEditor.text = profileInfo.lat.toString();
      lngTextEditor.text = profileInfo.lng.toString();

      bankNameTextEditor.text = profileInfo.bankName.toString();
      bankIFSCTextEditor.text = profileInfo.bankIfsc.toString();
      bankCNameTextEditor.text = profileInfo.bankCustomerName.toString();
      accNoTextEditor.text = profileInfo.bankAccountNumber.toString();

      panTextEditor.text = profileInfo.pan.toString();
      gstTextEditor.text = profileInfo.vat.toString();
      whatsappTextEditor.text = profileInfo.whatsappNumber.toString();

      if (profileInfo.timing != 'NA') {
        var times = jsonDecode(profileInfo.timing.toString());
        times.forEach((element) {
          TimingModel datas = TimingModel.fromJson(element);
          _timesList.add(datas);
        });
      }
      parser.saveId(profileInfo.id.toString());
      update();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void updateStylist(bool status) {
    haveStylist = status;
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
    Get.delete<SalonCategoriesController>(force: true);
    String catID =
        profileInfo.categories.toString().replaceAll(RegExp(r'[\[\]]'), '');
    Get.toNamed(AppRouter.getSalonCategoriesRoute(), arguments: [catID]);
  }

  void onSelectFacilities() {
    Get.delete<FacilitiesController>(force: true);
    Get.toNamed(
      AppRouter.getFacilities(),
    );
  }

  void onSelectCities() {
    Get.delete<CitiesCategoriesController>(force: true);
    Get.toNamed(AppRouter.getCitiesCategoriesRoute(),
        arguments: [profileInfo.cid]);
  }

  void onSaveCities(String cid, String name) {
    debugPrint('got from service list');
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

  Future<void> updateSalon() async {
    // if (cover == '' ||
    //     cover.isEmpty ||
    //     salonNameTextEditor.text == '' ||
    //     salonNameTextEditor.text.isEmpty ||
    //     addressTextEditor.text == '' ||
    //     addressTextEditor.text.isEmpty ||
    //     latTextEditor.text == '' ||
    //     latTextEditor.text.isEmpty ||
    //     lngTextEditor.text == '' ||
    //     lngTextEditor.text.isEmpty ||
    //     zipCodeTextEditor.text == '' ||
    //     zipCodeTextEditor.text.isEmpty ||
    //     aboutTextEditor.text == '' ||
    //     aboutTextEditor.text.isEmpty) {
    //   showToast('All fields are required!');
    //   return;
    // }

    if (cover.isEmpty) {
      _showValidationDialog(
          'Cover Image Missing', 'Please upload a cover image.');
      return;
    }
    if (salonNameTextEditor.text.isEmpty) {
      _showValidationDialog(
          'Salon Name Missing', 'Please enter the name of the salon.');
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
      _showValidationDialog('ZIP Code Missing', 'Please enter the ZIP code.');
      return;
    }
    if (aboutTextEditor.text.isEmpty) {
      _showValidationDialog(
          'About Section Missing', 'Please provide details about the salon.');
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
      "id": profileInfo.id,
      "name": salonNameTextEditor.text,
      "address": addressTextEditor.text,
      "website": websiteTextEditor.text,
      "lat": latTextEditor.text,
      "lng": lngTextEditor.text,
      "zipcode": zipCodeTextEditor.text,
      "about": aboutTextEditor.text,
      "cover": cover,
      "have_stylist": haveStylist == true ? 1 : 0,
      "have_shop": haveShop == true ? 1 : 0,
      "service_at_home": haveHome == true ? 1 : 0,
      "timing": _timesList.isNotEmpty ? jsonEncode(timesList) : 'NA',
      "bank_name": bankNameTextEditor.text,
      "bank_account_number": accNoTextEditor.text,
      "bank_customer_name": bankCNameTextEditor.text,
      "bank_ifsc": bankIFSCTextEditor.text,
      "pan": panTextEditor.text,
      "vat": gstTextEditor.text,
      "whatsapp_number": whatsappTextEditor.text,
    };

    debugPrint(body.toString());
    Response response = await parser.updateSalon(body);
    Get.back();
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      SharedPreferences? sharedPreferences;
      sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('name', salonNameTextEditor.text);
      ProfileController profileController = Get.find<ProfileController>();
      profileController.name.value = salonNameTextEditor.text;
      sharedPreferences.setString('cover', cover);
      profileController.cover.value = cover;
      onBack();
      successToast('Update Salon');
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
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

  void updateTime(int dayNumber, String openTime, String closeTime) {
    debugPrint(dayNumber.toString() + openTime.toString() + closeTime);
    var index = _timesList.indexWhere((element) => element.day == dayNumber);
    debugPrint(index.toString());
    _timesList[index].day = dayNumber;
    _timesList[index].openTime = openTime;
    _timesList[index].closeTime = closeTime;
    update();
  }

  void deleteOpeningHours(int dayNumber, String openTime, String closeTime) {
    //  debugPrint(dayNumber.toString() + openTime.toString() + closeTime);
    var index = _timesList.indexWhere((element) => element.day == dayNumber);
    debugPrint(index.toString());
    _timesList.removeAt(index);
    //  _timesList[index].day = dayNumber;
    // _timesList[index].openTime = openTime;
    // _timesList[index].closeTime = closeTime;
    update();
  }
}
