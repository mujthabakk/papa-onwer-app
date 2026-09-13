/*Papabear*/
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/individual_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/profile_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/gallary_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class GallaryController extends GetxController implements GetxService {
  final GallaryParser parser;

  ProfileModel _profileInfo = ProfileModel();
  ProfileModel get profileInfo => _profileInfo;

  IndividualInfoModel _individualInfo = IndividualInfoModel();
  IndividualInfoModel get individualInfo => _individualInfo;

  XFile? _selectedImage;
  List<String> gallery = [''];

  bool apiCalled = false;

  bool userType = true;

  GallaryController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    userType = parser.getType();
    getCatebyId();
  }

  Future<void> getCatebyId() async {
    if (userType == true) {
      debugPrint('get id for salon');

      var response = await parser.getCateById();
      apiCalled = true;
      debugPrint(response.bodyString);
      if (response.statusCode == 200) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        var data = myMap['data'];
        ProfileModel profileData = ProfileModel.fromJson(data);
        _profileInfo = profileData;
        if (profileInfo.images != 'NA') {
          var images = jsonDecode(profileInfo.images.toString());
          images.forEach((element) {
            gallery.add(element);
          });
        }
        update();
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    } else {
      debugPrint('get id for individual');

      var response = await parser.getIndividualCateById();
      apiCalled = true;
      debugPrint(response.bodyString);
      if (response.statusCode == 200) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        var data = myMap['data'];
        IndividualInfoModel individualData = IndividualInfoModel.fromJson(data);
        _individualInfo = individualData;
        if (individualInfo.images != 'NA') {
          var images = jsonDecode(individualInfo.images.toString());
          images.forEach((element) {
            gallery.add(element);
          });
        }
        update();
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void selectFromGalleryOthers(String kind) async {
    _selectedImage = await ImagePicker().pickImage(
        source: kind == 'gallery' ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 25);
    update();
    if (_selectedImage != null) {
      final file = File(_selectedImage!.path);
      final fileSize = await file.length();
      if (fileSize > 1048576) {
        Get.dialog(
          SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "      Error".tr,
                            style: const TextStyle(
                              fontFamily: 'bold',
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Image size exceeds 1 MB. Please select a smaller image."
                                .tr,
                            style: const TextStyle(fontFamily: 'regular'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          barrierDismissible: true,
        );
        _selectedImage = null;
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
          barrierDismissible: false);
      Response response = await parser.uploadImage(_selectedImage as XFile);
      Get.back();
      if (response.statusCode == 200) {
        _selectedImage = null;
        if (response.body['data'] != null && response.body['data'] != '') {
          dynamic body = response.body["data"];
          if (body['image_name'] != null && body['image_name'] != '') {
            gallery.add(body['image_name']);
            update();
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    }
  }

  void deletePhoto(String name) {
    debugPrint(name);
    gallery.remove(name);
    update();
  }

  Future<void> onSave() async {
    if (userType == true) {
      debugPrint('for salon');

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
      gallery = gallery.where((element) => element != '').toList();

      var body = {
        "id": profileInfo.id,
        "images": gallery.isEmpty ? 'NA' : jsonEncode(gallery)
      };
      debugPrint(body.toString());
      Response response = await parser.updateSalon(body);
      Get.back();
      debugPrint(response.bodyString);
      if (response.statusCode == 200) {
        onBack();
        successToast('Gallery Updated');
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    } else {
      debugPrint('for individual');

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
      gallery = gallery.where((element) => element != '').toList();

      var body = {
        "id": individualInfo.id,
        "images": gallery.isEmpty ? 'NA' : jsonEncode(gallery)
      };
      debugPrint(body.toString());
      Response response = await parser.individualUpdate(body);
      Get.back();
      debugPrint(response.bodyString);
      if (response.statusCode == 200) {
        onBack();
        successToast('Gallery Updated');
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }
}
