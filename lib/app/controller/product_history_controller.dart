// /*
//   Authors : initappz (Rahul Jograna)
//   Website : https://initappz.com/
//   App Name : Ultimate Salon Full App Flutter V2
//   This App Template Source code is licensed as per the
//   terms found in the Website https://initappz.com/license
//   Copyright and Good Faith Purchasers © 2023-present initappz.
// */
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
// import 'package:ultimate_salon_owner_flutter/app/backend/models/products_order_model.dart';
// import 'package:ultimate_salon_owner_flutter/app/backend/parse/history_parse.dart';
// import 'package:ultimate_salon_owner_flutter/app/controller/inbox_controller.dart';
// import 'package:ultimate_salon_owner_flutter/app/controller/notification_controller.dart';
// import 'package:ultimate_salon_owner_flutter/app/controller/premium_controller.dart';
// import 'package:ultimate_salon_owner_flutter/app/controller/product_order_details_controller.dart';
// import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
// import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

// class HistoryController extends GetxController
//     with GetTickerProviderStateMixin
//     implements GetxService {
//   final HistoryParser parser;

//   late TabController tabController;

//   List<ProductSalonModel> _productSalonList = <ProductSalonModel>[];
//   List<ProductSalonModel> get productSalonList => _productSalonList;

//   List<ProductSalonModel> _productSalonListOld = <ProductSalonModel>[];
//   List<ProductSalonModel> get productSalonListOld => _productSalonListOld;

//   bool apiCalled = false;

//   String currencySide = AppConstants.defaultCurrencySide;
//   String currencySymbol = AppConstants.defaultCurrencySymbol;

//   List<String> statusName = [
//     'Created'.tr,
//     'Accepted'.tr,
//     'Rejected'.tr,
//     'Ongoing'.tr,
//     'Completed'.tr,
//     'Cancelled'.tr,
//     'Refunded'.tr,
//     'Delayed'.tr,
//     'Pending Payment'.tr,
//   ];
//   void showDialogScreen(BuildContext context, String title, String message,
//       IconData icon, Color iconColor) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(20.0)),
//           ),
//           // title: Column(
//           //   children: [
//           //     Icon(icon, color: iconColor),
//           //     const SizedBox(width: 10),
//           //     Text(title),
//           //   ],
//           // ),
//           content: SizedBox(
//             height: 200,
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(18.0),
//                   child: Icon(
//                     icon,
//                     color: iconColor,
//                     size: 60,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(title,
//                     style: const TextStyle(
//                         fontSize: 16.5,
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold)),
//                 const SizedBox(
//                   height: 18,
//                 ),
//                 Text(
//                   message,
//                   style: const TextStyle(fontSize: 16, color: Colors.black),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text(
//                 'OK',
//                 style: TextStyle(
//                   color: Colors.blue,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   final Map<int, Color> statusColors = {
//     0: Colors.blue, // Created
//     1: Colors.green, // Accepted
//     2: Colors.red, // Rejected
//     3: Colors.orange, // Ongoing
//     4: Colors.purple, // Completed
//     5: Colors.grey, // Cancelled
//     6: Colors.yellow, // Refunded
//     7: Colors.brown, // Delayed
//     8: Colors.teal, // Pending Payment
//   };
//   HistoryController({required this.parser});
//   void onOpenNotifications() {
//     Get.delete<NotificationController>(force: true);
//     Get.toNamed(AppRouter.getNotifications());
//   }

//   void onInbox() {
//     Get.delete<InboxController>(force: true);
//     Get.toNamed(AppRouter.getInboxRoute());
//   }

//   void onUpgradeScreen() {
//     Get.delete<PremiumController>(force: true);
//     Get.toNamed(AppRouter.getPremiumRoute());
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     currencySide = parser.getCurrencySide();
//     currencySymbol = parser.getCurrencySymbol();
//     tabController = TabController(length: 2, vsync: this);
//     getList();
//   }

//   void getList() {
//     if (parser.getType() == 'salon') {
//       getSalonList();
//     } else {
//       getIndividualOrdersList();
//     }
//   }

//   Future<void> getIndividualOrdersList() async {
//     Response response = await parser.getIndividualOrdersList();

//     apiCalled = true;
//     if (response.statusCode == 200) {
//       Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
//       var body = myMap['data'];
//       _productSalonList = [];
//       _productSalonListOld = [];
//       body.forEach((data) {
//         ProductSalonModel productSalon = ProductSalonModel.fromJson(data);
//         if (productSalon.status == 0) {
//           _productSalonList.add(productSalon);
//         } else {
//           _productSalonListOld.add(productSalon);
//         }
//       });
//     } else {
//       ApiChecker.checkApi(response);
//     }
//     update();
//   }

//   Future<void> getSalonList() async {
//     Response response = await parser.getSalonList();

//     apiCalled = true;
//     if (response.statusCode == 200) {
//       Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
//       var body = myMap['data'];
//       _productSalonList = [];
//       _productSalonListOld = [];
//       body.forEach((data) {
//         ProductSalonModel productSalon = ProductSalonModel.fromJson(data);
//         if (productSalon.status == 0) {
//           _productSalonList.add(productSalon);
//         } else {
//           _productSalonListOld.add(productSalon);
//         }
//       });
//     } else {
//       ApiChecker.checkApi(response);
//     }
//     update();
//   }

//   void onProductDetail(int id) {
//     Get.delete<ProductOrderDetailsController>(force: true);
//     Get.toNamed(AppRouter.getProductOrderDetailsRoutes(), arguments: [id]);
//   }
// }
/*Papabear*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/products_order_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/history_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/inbox_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/notification_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/premium_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/product_order_details_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class HistoryController extends GetxController
    with GetTickerProviderStateMixin
    implements GetxService {
  final HistoryParser parser;

  late TabController tabController;

  List<ProductSalonModel> _productSalonList = <ProductSalonModel>[];
  List<ProductSalonModel> get productSalonList => _productSalonList;

  List<ProductSalonModel> _productSalonListOld = <ProductSalonModel>[];
  List<ProductSalonModel> get productSalonListOld => _productSalonListOld;

  // Filter properties
  int _selectedNewOrdersFilter = -1; // -1 means "All"
  int _selectedPastOrdersFilter = -1; // -1 means "All"

  int get selectedNewOrdersFilter => _selectedNewOrdersFilter;
  int get selectedPastOrdersFilter => _selectedPastOrdersFilter;

  bool apiCalled = false;

  String currencySide = AppConstants.defaultCurrencySide;
  String currencySymbol = AppConstants.defaultCurrencySymbol;

  List<String> get statusName => [
        'Created',
        'Accepted',
        'Rejected',
        'Ongoing',
        'Completed',
        'Cancelled',
        'Refunded',
        'Delayed',
        'Pending Payment',
      ];

  final Map<int, Color> statusColors = {
    0: Colors.blue, // Created
    1: Colors.green, // Accepted
    2: Colors.red, // Rejected
    3: Colors.orange, // Ongoing
    4: Colors.purple, // Completed
    5: Colors.grey, // Cancelled
    6: Colors.yellow, // Refunded
    7: Colors.brown, // Delayed
    8: Colors.teal, // Pending Payment
  };

  HistoryController({required this.parser});

  // Filter methods
  void setNewOrdersFilter(int statusIndex) {
    _selectedNewOrdersFilter = statusIndex;
    update();
  }

  void setPastOrdersFilter(int statusIndex) {
    _selectedPastOrdersFilter = statusIndex;
    update();
  }

  void clearAllFilters() {
    _selectedNewOrdersFilter = -1;
    _selectedPastOrdersFilter = -1;
    update();
  }

  List<ProductSalonModel> getFilteredNewOrders() {
    if (_selectedNewOrdersFilter == -1) {
      return _productSalonList;
    }
    return _productSalonList
        .where((order) => order.status == _selectedNewOrdersFilter)
        .toList();
  }

  List<ProductSalonModel> getFilteredPastOrders() {
    if (_selectedPastOrdersFilter == -1) {
      return _productSalonListOld;
    }
    return _productSalonListOld
        .where((order) => order.status == _selectedPastOrdersFilter)
        .toList();
  }

  List<int> getAvailableStatusesForNewOrders() {
    Set<int> statuses = {};
    for (var order in _productSalonList) {
      statuses.add(order.status as int);
    }
    return statuses.toList()..sort();
  }

  List<int> getAvailableStatusesForPastOrders() {
    Set<int> statuses = {};
    for (var order in _productSalonListOld) {
      statuses.add(order.status as int);
    }
    return statuses.toList()..sort();
  }

  int getOrderCountForStatus(int statusIndex, bool isNewOrders) {
    final list = isNewOrders ? _productSalonList : _productSalonListOld;
    return list.where((order) => order.status == statusIndex).length;
  }

  void showDialogScreen(BuildContext context, String title, String message,
      IconData icon, Color iconColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          content: SizedBox(
            height: 200,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 60,
                  ),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16.5,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 18,
                ),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onOpenNotifications() {
    Get.delete<NotificationController>(force: true);
    Get.toNamed(AppRouter.getNotifications());
  }

  void onInbox() {
    Get.delete<InboxController>(force: true);
    Get.toNamed(AppRouter.getInboxRoute());
  }

  void onUpgradeScreen() {
    Get.delete<PremiumController>(force: true);
    Get.toNamed(AppRouter.getPremiumRoute());
  }

  @override
  void onInit() {
    super.onInit();
    currencySide = parser.getCurrencySide();
    currencySymbol = parser.getCurrencySymbol();
    tabController = TabController(length: 2, vsync: this);
    if (!parser.sharedPreferencesManager.hasOwnerSession()) return;
    getList();
  }

  void getList() {
    if (!parser.sharedPreferencesManager.hasOwnerSession()) return;
    if (parser.getType() == 'salon') {
      getSalonList();
    } else {
      getIndividualOrdersList();
    }
  }

  Future<void> getIndividualOrdersList() async {
    Response response = await parser.getIndividualOrdersList();

    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'];
      _productSalonList = [];
      _productSalonListOld = [];
      body.forEach((data) {
        ProductSalonModel productSalon = ProductSalonModel.fromJson(data);
        if (productSalon.status == 0) {
          _productSalonList.add(productSalon);
        } else {
          _productSalonListOld.add(productSalon);
        }
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getSalonList() async {
    Response response = await parser.getSalonList();

    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'];
      _productSalonList = [];
      _productSalonListOld = [];
      body.forEach((data) {
        ProductSalonModel productSalon = ProductSalonModel.fromJson(data);
        if (productSalon.status == 0) {
          _productSalonList.add(productSalon);
        } else {
          _productSalonListOld.add(productSalon);
        }
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onProductDetail(int id) {
    Get.delete<ProductOrderDetailsController>(force: true);
    Get.toNamed(AppRouter.getProductOrderDetailsRoutes(), arguments: [id]);
  }
}
