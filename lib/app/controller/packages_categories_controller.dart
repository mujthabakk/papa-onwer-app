import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/services_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/packages_categories.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/add_packages_controller.dart';

class PackagesCategoriesController extends GetxController
    implements GetxService {
  final PackagesCategoriesParser parser;

  String title = 'Packages'.tr;
  List<ServicesModel> _servicesList = <ServicesModel>[];
  List<ServicesModel> get servicesList => _servicesList;

  List<int> selectedServices = [];
  List<String> selectedServicesName = [];
  List<double> selectedServicePrice = [];

  bool apiCalled = false;
  PackagesCategoriesController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    getServices();
    if (Get.arguments[0] != null && Get.arguments[0] != '') {
      var ids = Get.arguments[0].toString(); // 1,2,3,4;
      ids.split(',').forEach((element) {
        selectedServices.add(int.parse(element));
      });
    }

    if (Get.arguments[1] != null && Get.arguments[1] != '') {
      selectedServicesName = Get.arguments[1];
    }
  }

  Future<void> getServices() async {
    var response = await parser
        .getServices({"id": parser.sharedPreferencesManager.getString('uid')});
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'];
      _servicesList = [];
      body.forEach((element) {
        ServicesModel service = ServicesModel.fromJson(element);
        var index = selectedServices.indexOf(service.id as int);
        if (index >= 0) {
          service.isChecked = true;
        } else {
          service.isChecked = false;
        }
        _servicesList.add(service);
        _servicesList = _servicesList.reversed.toList();

        debugPrint(response.bodyString.toString());
      });

      // FIX: Rebuild the selectedServicePrice list after loading services
      _rebuildSelectedServicePrice();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  // FIX: New method to rebuild the price list based on selected services
  void _rebuildSelectedServicePrice() {
    selectedServicePrice.clear();
    for (int serviceId in selectedServices) {
      final index =
          _servicesList.indexWhere((element) => element.id == serviceId);
      if (index == -1) {
        continue;
      }
      selectedServicePrice
          .add(double.tryParse('${_servicesList[index].off}') ?? 0.0);
    }
    debugPrint('Rebuilt selected prices: ${selectedServicePrice.toString()}');
  }

  void removeAll() {
    selectedServices.clear();
    selectedServicesName.clear();
    selectedServicePrice.clear();
    Get.find<AddPackagesController>().onClearAll();
    update();
  }

  void updateStatus(bool status, int id) {
    debugPrint(status.toString());
    debugPrint(id.toString());
    var itemIndex = _servicesList.indexWhere((element) => element.id == id);

    if (itemIndex == -1) {
      debugPrint('Service not found with id: $id');
      return;
    }

    _servicesList[itemIndex].isChecked = status;

    if (status == false) {
      selectedServices.remove(id);
      selectedServicesName.remove('${_servicesList[itemIndex].name}');
    } else {
      selectedServices.add(id);
      selectedServicesName.add('${_servicesList[itemIndex].name}');
    }

    // Rebuild price list from scratch based on selected services
    _rebuildSelectedServicePrice();

    debugPrint(selectedServices.toString());
    debugPrint('Selected prices: ${selectedServicePrice.toString()}');
    update();
  }

  Future<void> onAdd() async {
    double price = selectedServicePrice.fold(0, (sum, item) => sum + item);
    debugPrint('Final calculated price: $price'); // Add debug print
    Get.find<AddPackagesController>().onSaveCategory(
        selectedServices.join(','), selectedServicesName, price);
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }
}
