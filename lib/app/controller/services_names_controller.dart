import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/add_profile_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/add_service_name_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/services_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/service_names_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_services_controller.dart';

class ServicesNamesController extends GetxController implements GetxService {
  final ServicesNamesParser parser;

  String title = 'Select Service'.tr;

  bool userType = true;

  List<ServiceNameModel> _serviceList = <ServiceNameModel>[];
  List<ServiceNameModel> get serviceList => _serviceList;

  String selectedService = '';
  String selectedServiceName = '';

  bool apiCalled = false;

  ServicesNamesController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    userType = parser.getType();
    debugPrint(Get.arguments.toString());
    int catId = Get.arguments[0];
    debugPrint('CategoryID $catId');
    getSelectedServiceNames(catId);
    // selectedService = Get.arguments[0].toString();
  }

  Future<void> getSelectedServiceNames(int catId) async {
    //print(catId);
    var response = await parser.selectCategories({"id": catId});
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'];
      _serviceList = [];
      body.forEach((data) {
        ServiceNameModel services = ServiceNameModel.fromJson(data);
        _serviceList.add(services);
      });

      debugPrint(serviceList.length.toString());
      _serviceList = _serviceList.reversed.toList();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void saveServicesNames(String id) {
    selectedService = id;
    var name =
        _serviceList.firstWhere((element) => element.id.toString() == id).name;
    selectedServiceName = name as String;
    debugPrint('services selected');
    update();
  }

  Future<void> onSaveServicesNames() async {
    Get.find<AddServicesController>()
        .onSaveServiceName(selectedService, selectedServiceName);
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }
}
