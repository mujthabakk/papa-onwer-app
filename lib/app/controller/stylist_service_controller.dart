import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/add_profile_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/stylist_categories_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/stylist_service_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_stylist_controller.dart';

class StylistServiceController extends GetxController implements GetxService {
  final StylistServiceParser parser;

  bool apiCalled = false;

  List<AddProfileModel> _selectEditProfileList = <AddProfileModel>[];
  List<AddProfileModel> get selectEditProfileList => _selectEditProfileList;
  // List<ServiceNameModel> _serviceList = <ServiceNameModel>[];
  //List<ServiceNameModel> get serviceList => _serviceList;

  List<int> selectedCategories = [];
  List<String> selectedCateName = [];

  List<int> selectedServices = [];
  List<String> selectedServiceName = [];

  bool userType = true;

  StylistServiceController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    userType = parser.getType();
    getSelectedCategories();
    if (Get.arguments[0] != null && Get.arguments[0] != '') {
      var ids = Get.arguments[0].toString(); // 1,2,3,4;
      ids.split(',').forEach((element) {
        selectedServices.add(int.parse(element));
      });
    }
  }

  // Future<void> selectCategories() async {
  //   var response = await parser.selectCategories();
  //   apiCalled = true;
  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
  //     var cates = myMap['data'];
  //     _selectEditProfileList = [];
  //     cates.forEach((data) {
  //       AddProfileModel datas = AddProfileModel.fromJson(data);
  //       if (selectedCategories.contains(datas.id)) {
  //         datas.isChecked = true;
  //         selectedCateName.add(datas.name.toString());
  //       } else {
  //         datas.isChecked = false;
  //       }
  //       _selectEditProfileList.add(datas);
  //     });
  //     debugPrint(selectEditProfileList.length.toString());
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   update();
  // }

  Future<void> getSelectedServiceNames(String catId) async {
    var response = await parser.selectServices({"id": catId});
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'];
      _selectEditProfileList = [];
      body.forEach((data) {
        AddProfileModel services = AddProfileModel.fromJson(data);
        //_serviceList.add(services);
        if (selectedServices.contains(services.id)) {
          services.isChecked = true;
          selectedServiceName.add(services.name.toString());
        } else {
          services.isChecked = false;
        }
        _selectEditProfileList.add(services);
      });
      debugPrint(selectEditProfileList.length.toString());
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getSelectedCategories() async {
    if (userType == true) {
      debugPrint('for salon');
      var response = await parser.selectCategories(
          {"id": parser.sharedPreferencesManager.getString('uid')});
      apiCalled = true;
      if (response.statusCode == 200) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        var body = myMap['data'];
        // _selectEditProfileList = [];
        body.forEach((data) {
          AddProfileModel datas = AddProfileModel.fromJson(data);
          selectedCategories.add(datas.id!);
          selectedCateName.add(datas.name.toString());
          getSelectedServiceNames(datas.id.toString());
          // if (selectedCategories.contains(datas.id)) {
          //   datas.isChecked = true;
          //   selectedCateName.add(datas.name.toString());
          // } else {
          //   datas.isChecked = false;
          // }
          // _selectEditProfileList.add(datas);
        });
        debugPrint(selectEditProfileList.length.toString());
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    } else {
      debugPrint('for individual');
      var response = await parser.individualCategories(
          {"id": parser.sharedPreferencesManager.getString('uid')});
      apiCalled = true;
      if (response.statusCode == 200) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        var body = myMap['data'];
        //_selectEditProfileList = [];
        body.forEach((data) {
          AddProfileModel datas = AddProfileModel.fromJson(data);
          selectedCategories.add(datas.id!);
          selectedCateName.add(datas.name.toString());
          getSelectedServiceNames(datas.id.toString());

          // if (selectedCategories.contains(datas.id)) {

          //   datas.isChecked = true;
          //   selectedCateName.add(datas.name.toString());
          // } else {
          //   datas.isChecked = false;
          // }
          // _selectEditProfileList.add(datas);
        });
        debugPrint(selectEditProfileList.length.toString());
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void updateStatus(bool status, int id, String name) {
    debugPrint(status.toString());
    debugPrint(id.toString());
    var itemIndex =
        _selectEditProfileList.indexWhere((element) => element.id == id);
    _selectEditProfileList[itemIndex].isChecked = status;
    if (status == false) {
      // remove
      selectedServices.remove(id);
      selectedServiceName.remove(name);
    } else {
      selectedServices.add(id);
      selectedServiceName.add(name);
      // add
    }
    debugPrint(selectedServices.join(','));
    update();
  }

  Future<void> onAdd() async {
    Get.find<AddStylistController>().onSaveCategory(
        selectedCategories.join(','),
        // selectedServices.join(','),
        selectedCateName);
    //selectedServiceName);
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }
}
