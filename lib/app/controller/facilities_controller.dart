/*Papabear*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/ad_managing_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/add_services_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/ads_publish_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_individual_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_business_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_names_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

import '../backend/models/facilities_model.dart';
import '../backend/parse/ads_managing_parse.dart';
import '../backend/parse/facilities_parse.dart';

class FacilitiesController extends GetxController implements GetxService {
  final FacilitiesParser parser;

  FacilitiesController({required this.parser});

  bool apiCalled = false;

  List<FacilityModel> _selectEditProfileList = <FacilityModel>[];
  List<FacilityModel> get selectEditProfileList => _selectEditProfileList;

  List<int?> selectedCategories = [];
  @override
  void onInit() {
    super.onInit();
    getfacilities();
  }

  Future<void> getfacilities() async {
    var response = await parser.getFacilities();
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var cates = myMap['data'];
      _selectEditProfileList = [];
      cates.forEach((data) {
        FacilityModel datas = FacilityModel.fromJson(data);
        if (datas.status == 1) {
          datas.isChecked = true;
          selectedCategories.add(datas.id);
        } else {
          datas.isChecked = false;
        }
        _selectEditProfileList.add(datas);
      });
      debugPrint(selectEditProfileList.length.toString());
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void updateStatus(bool status, int id) {
    debugPrint(status.toString());
    debugPrint(id.toString());
    var itemIndex =
        _selectEditProfileList.indexWhere((element) => element.id == id);
    _selectEditProfileList[itemIndex].isChecked = status;
    if (status == false) {
      // remove
      selectedCategories.remove(id);
    } else {
      selectedCategories.add(id);
      // add
    }
    debugPrint(selectedCategories.toString());
    update();
  }

  Future<void> updateCate() async {
    if (selectedCategories.isEmpty) {
      showToast('Please select one of the categories');
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
    UpdateCateResult result =
        await parser.updateCate(selectedCategories.join(','));
    bool type = result.type;
    var response = result.response;
    Get.back();
    debugPrint(response.bodyString);
    if (response.statusCode == 200) {
      successToast('Categories Updated');
      if (type == true) {
        Get.find<ProfileCategoriesController>().getCateById();
      } else {
        Get.find<IndividualProfileController>().getCateById();
      }
      // getfacilities();
      onBack();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }
}
