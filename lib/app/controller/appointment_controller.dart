// import 'dart:convert';
// import 'dart:io';

// import 'package:adapty_flutter/adapty_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:lottie/lottie.dart';
// import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
// import 'package:ultimate_salon_owner_flutter/app/backend/models/appointment_model.dart';
// import 'package:ultimate_salon_owner_flutter/app/backend/models/upgrade_model.dart';
// import 'package:ultimate_salon_owner_flutter/app/backend/parse/appointment_parse.dart';
// import 'package:ultimate_salon_owner_flutter/app/controller/inbox_controller.dart';
// import 'package:ultimate_salon_owner_flutter/app/controller/notification_controller.dart';
// import 'package:ultimate_salon_owner_flutter/app/controller/order_details_controller.dart';
// import 'package:ultimate_salon_owner_flutter/app/controller/premium_controller.dart';
// import 'package:ultimate_salon_owner_flutter/app/env.dart';
// import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
// import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
// import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../backend/models/banner_model.dart';

// class AppointmentController extends GetxController
//     with GetTickerProviderStateMixin
//     implements GetxService {
//   final AppointmentParser parser;

//   List<AppointmentModel> _appointmentList = <AppointmentModel>[];
//   List<AppointmentModel> get appointmentList => _appointmentList;

//   List<AppointmentModel> _appointmentListOld = <AppointmentModel>[];
//   List<AppointmentModel> get appointmentListOld => _appointmentListOld;

//   bool apiCalled = false;
//   String currencySide = AppConstants.defaultCurrencySide;
//   String currencySymbol = AppConstants.defaultCurrencySymbol;
//   String name = '';
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

//   List<BannerModel> _bannerList = <BannerModel>[];
//   List<BannerModel> get bannerList => _bannerList;

//   AppointmentController({required this.parser});
//   final adapty = Adapty();
//   List<AdaptyPaywallProduct>? paywallProducts;
//   late TabController tabController;
//   final box = GetStorage();

//   late bool premiumFlag = box.read('premium') ?? false;
//   bool get _premiumFlag => premiumFlag;

//   setPremium(bool value) {
//     premiumFlag = value;
//     box.write('premium', value);
//     update();
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     getBannerData();
//     currencySide = parser.getCurrencySide();
//     currencySymbol = parser.getCurrencySymbol();
//     tabController = TabController(length: 2, vsync: this);
//     getList();
//     updateCustomerStatus();
//   }

//   updateCustomerStatus() async {
//     final purchaserInfo = await Adapty().getProfile();

//     try {
//       if (purchaserInfo.accessLevels.isNotEmpty) {
//         if (purchaserInfo.accessLevels['premium']!.isActive) {
//           print('premium activated');
//           setPremium(true);
//           EasyLoading.dismiss();
//           parser.premiumStat(true);
//           postUpgradeLaunch("1"); // Navigator.pushReplacement(
//           //   context,
//           //   MaterialPageRoute(builder: (context) => HomePage()),
//           // );
//         } else {
//           parser.premiumStat(false);
//           postUpgradeLaunch("0");

//           setPremium(false);
//           getOfferings();
//           EasyLoading.dismiss();
//           // Navigator.pushReplacement(
//           //   context,
//           //   MaterialPageRoute(builder: (context) => const SubscriptionPage()),
//           // );
//           print('premium deactivated');
//         }
//       } else {
//         getOfferings();
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//     // return (purchaserInfo.accessLevels['premium']!.isActive);
//   }

//   purchasePremium(AdaptyPaywallProduct paywallProducts) async {
//     try {
//       EasyLoading.show(status: 'Please wait...');
//       // var sku = await Glassfy.skuWithId('no_ai_premium_subscription_6.99');
//       await Adapty().makePurchase(product: paywallProducts);

//       final profile = await Adapty().getProfile();

//       // Check the access level or subscription status
//       final accessLevel = profile.accessLevels['premium'];

//       if (accessLevel != null && accessLevel.isActive) {
//         EasyLoading.dismiss();
//         setPremium(true);
//         parser.premiumStat(true);
//         postUpgrade("1");

//         Fluttertoast.showToast(
//             msg: "Purchase Succesful, You Are Now A Premium Customer",
//             toastLength: Toast.LENGTH_LONG,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.lightBlue,
//             textColor: Colors.white,
//             fontSize: 16.0);
//       } else {
//         EasyLoading.dismiss();
//         Fluttertoast.showToast(
//             msg: "Purchase failed, Try Again",
//             toastLength: Toast.LENGTH_LONG,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.red,
//             textColor: Colors.white,
//             fontSize: 16.0);
//       }
//     } catch (e) {
//       EasyLoading.dismiss();

//       print("Glassfy" + e.toString());
//       Fluttertoast.showToast(
//           msg: "Purchase failed, Try Again",
//           toastLength: Toast.LENGTH_LONG,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//           fontSize: 16.0);
//     }
//     //EasyLoading.dismiss();
//     update();
//   }

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

//   void showUpgradeDialog(BuildContext context) {
//     showModalBottomSheet(
//       backgroundColor: Color.fromARGB(255, 12, 12, 12),
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
//       ),
//       builder: (BuildContext context) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               // Image at the top

//               Image.asset(
//                 'assets/images/icon_logo.png',
//                 fit: BoxFit.contain,
//                 width: 150,
//                 height: 150,
//               ),
//               const Text(
//                 'PapaBear Premium',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Color.fromARGB(255, 209, 165, 32),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               // List of upgrade benefits
//               const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     width: double.infinity,
//                     child: Text(
//                       '• Cash Payment at shop\n• Gallery Listing\n• Coupon Discount\n• Run Ads on customer app\n• Shop QR Code Option',
//                       style: TextStyle(
//                           color: Color.fromARGB(255, 189, 152, 41),
//                           fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     ),
//                   )
//                 ],
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   showOfferingDialog(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: ThemeProvider.golden,
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                 ),
//                 child: const Text('Upgrade Now',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color.fromARGB(255, 41, 41, 40),
//                     )),
//               ),
//               const SizedBox(height: 20),
//               IconButton.filled(
//                   style: const ButtonStyle(
//                       backgroundColor:
//                           MaterialStatePropertyAll(ThemeProvider.golden)),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   icon: const Icon(
//                     Icons.close,
//                     color: Color.fromARGB(255, 40, 39, 39),
//                   )),
//               const SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> updateCustomerStatusRestore(BuildContext context) async {
//     try {
//       EasyLoading.show(
//           status: 'Please wait...', maskType: EasyLoadingMaskType.clear);

//       final purchaserInfo = await Adapty().getProfile();
//       if (purchaserInfo.accessLevels['premium']!.isActive) {
//         print('premium activated');
//         setPremium(true);
//         parser.premiumStat(true);
//         postUpgrade("1");

//         Fluttertoast.showToast(
//             msg: "Purchase Restored Succesfully",
//             toastLength: Toast.LENGTH_LONG,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.lightBlue,
//             textColor: Colors.white,
//             fontSize: 16.0);
//       } else {
//         setPremium(false);
//         parser.premiumStat(false);
//         postUpgrade("0");

//         //  premiumFlag = false;
//         Fluttertoast.showToast(
//             msg: "Purchase Restored Failed",
//             toastLength: Toast.LENGTH_LONG,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.red,
//             textColor: Colors.white,
//             fontSize: 16.0);
//       }
//     } catch (e) {
//       print(e.toString());
//       Fluttertoast.showToast(
//           msg: "Purchase Restored Failed",
//           toastLength: Toast.LENGTH_LONG,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//           fontSize: 16.0);
//     }
//     EasyLoading.dismiss();

//     update();
//   }

//   void showOfferingDialog(
//     BuildContext context,
//   ) {
//     showModalBottomSheet(
//       isScrollControlled: true,
//       context: context,
//       builder: (BuildContext context) {
//         return Wrap(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(15.0),
//               child: Column(
//                 children: <Widget>[
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   const Text(
//                     'PapaBear Premium',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 56, 80, 99)),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: SizedBox(
//                         width: 250,
//                         height: 70,
//                         child: Lottie.asset('assets/lottie/premium.zip')),
//                   ),
//                   Container(),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: paywallProducts?.length,
//                     itemBuilder: (context, index) {
//                       return Column(
//                         children: [
//                           Text(
//                             paywallProducts![index].localizedTitle,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                                 color: Color.fromARGB(255, 80, 73, 72),
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(
//                             height: 8,
//                           ),
//                           Text(
//                             '${paywallProducts?[index].localizedDescription}\nfor ${paywallProducts?[index].price}',
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                                 fontSize: 15, fontWeight: FontWeight.w500),
//                           ),
//                           const SizedBox(
//                             height: 8,
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: ElevatedButton.icon(
//                               style: ButtonStyle(
//                                 backgroundColor: MaterialStateProperty.all(
//                                     Colors.blue), // Set your desired color
//                                 foregroundColor: MaterialStateProperty.all(
//                                     Colors.white), // Text/Icon color
//                               ),
//                               onPressed: () {
//                                 purchasePremium(paywallProducts![index]);
//                                 Navigator.pop(context);
//                               },
//                               icon: const Icon(Icons.subscriptions),
//                               label: const Text('Subscribe',
//                                   style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w700)),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       MaterialButton(
//                         child: const Text('Privacy Policy',
//                             style: TextStyle(
//                                 color: Color.fromARGB(255, 171, 169, 169),
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12)),
//                         onPressed: () {
//                           _launchUrlPrivacy();
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                       MaterialButton(
//                         child: const Text('Terms of Service',
//                             style: TextStyle(
//                                 color: Color.fromARGB(255, 171, 169, 169),
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12)),
//                         onPressed: () {
//                           _launchUrlTerms();
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   ),
//                   MaterialButton(
//                     child: const Text('Restore Subscription',
//                         style: TextStyle(
//                             color: Color.fromARGB(255, 171, 169, 169),
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12.5)),
//                     onPressed: () {
//                       updateCustomerStatusRestore(context);
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                   if (Platform.isAndroid)
//                     const Text(
//                       'This subscription is only available on Android devices and cannot be used across platforms (eg : macOS, iOS etc)',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 12,
//                       ),
//                     ),
//                   if (Platform.isIOS)
//                     const Text(
//                       'This subscription is only available on iOS devices and cannot be used across platforms (eg : macOS, Android etc)',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 12,
//                       ),
//                     ),
//                   if (Platform.isMacOS)
//                     const Text(
//                       'This subscription is only available on macOS devices and cannot be used across platforms (eg : iOS, Android etc)',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 12,
//                       ),
//                     ),
//                   const SizedBox(
//                     height: 15,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: SizedBox(
//                       width: 45,
//                       height: 45,
//                       child: FloatingActionButton(
//                         child: const Icon(Icons.close),
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _launchUrlTerms() async {
//     if (!await launchUrl(
//         Uri.parse('https://blacksheepmedia.co.nz/papabear-terms-of-service'))) {
//       throw Exception('No Internet Connection');
//     }
//   }

//   Future<void> _launchUrlPrivacy() async {
//     if (!await launchUrl(
//         Uri.parse('https://blacksheepmedia.co.nz/papbear-privacy-policy'))) {
//       throw Exception('No Internet Connection');
//     }
//   }

//   getOfferings() async {
//     final Map<String, PaywallsListItem> _paywallsItems = {};
//     AdaptyPaywall? paywall;
//     String id = 'Premium';
//     try {
//       paywall = await Adapty().getPaywall(placementId: 'PremiumPlacement');
//       loadProducts(paywall);
//     } on AdaptyError catch (e) {
//       _paywallsItems[id] = PaywallsListItem(id: id, error: e);
//     } catch (e) {}
//   }

//   Future<void> loadProducts(AdaptyPaywall paywallNew) async {
//     Environments.paywallProducts =
//         await Adapty().getPaywallProducts(paywall: paywallNew);
//     update();
//   }

//   void getList() {
//     if (parser.getType() == 'salon') {
//       getSalonAppointmentById();
//     } else {
//       getIndividualAppointmentsById();
//     }
//   }

//   Future<void> postUpgrade(String premium) async {
//     String message = '';
//     if (parser.getType() == 'salon') {
//       EasyLoading.show(
//           status: 'Please wait...', maskType: EasyLoadingMaskType.clear);
//       Response response = await parser.postSalonUpgrade(premium);
//       if (response.statusCode == 200) {
//         EasyLoading.dismiss();
//         Map<String, dynamic> jsonMap = json.decode(response.bodyString!);
//         SalonUpgradeResponse jsonresponse =
//             SalonUpgradeResponse.fromJson(jsonMap);
//         bool status = jsonresponse.status;
//         message = jsonresponse.message;
//         print('Status: $status');
//         print('Message: $message');
//         if (status) {
//           showDialogScreen(
//               Get.key.currentContext!,
//               'Success\nYou are now a premium user',
//               message,
//               Icons.check_circle,
//               Colors.green);
//         } else {
//           showDialogScreen(
//               Get.key.currentContext!,
//               'Failed to upgrade account please try again',
//               message,
//               Icons.check_circle,
//               Colors.red);
//         }
//       } else {
//         EasyLoading.dismiss();
//         showDialogScreen(
//             Get.key.currentContext!,
//             'Unknown Error! please try again',
//             message,
//             Icons.error,
//             Colors.red);
//         print('Request failed with status: ${response.body}');
//       }
//     } else {
//       Response response = await parser.postIndividualUpgrade(premium);
//       EasyLoading.show(
//           status: 'Please wait...', maskType: EasyLoadingMaskType.clear);
//       if (response.statusCode == 200) {
//         EasyLoading.dismiss();
//         Map<String, dynamic> jsonMap = json.decode(response.bodyString!);
//         SalonUpgradeResponse jsonresponse =
//             SalonUpgradeResponse.fromJson(jsonMap);

//         bool status = jsonresponse.status;
//         message = jsonresponse.message;
//         if (status) {
//           showDialogScreen(
//               Get.key.currentContext!,
//               'Success\nYou are now a premium user',
//               message,
//               Icons.check_circle,
//               Colors.green);
//         } else {
//           showDialogScreen(
//               Get.key.currentContext!,
//               'Failed to upgrade account please try again',
//               message,
//               Icons.check_circle,
//               Colors.red);
//         }
//         print('Status: $status');
//         print('Message: $message');
//       } else {
//         EasyLoading.dismiss();
//         showDialogScreen(
//             Get.key.currentContext!,
//             'Failed to upgrade account please try again',
//             message,
//             Icons.check_circle,
//             Colors.red);
//         print('Request failed with status: ${response.statusCode}');
//       }
//     }
//     update();
//   }

//   Future<void> postUpgradeLaunch(String premium) async {
//     String message = '';
//     if (parser.getType() == 'salon') {
//       EasyLoading.show(
//           status: 'Please wait...', maskType: EasyLoadingMaskType.clear);
//       Response response = await parser.postSalonUpgrade(premium);
//       if (response.statusCode == 200) {
//         EasyLoading.dismiss();
//         Map<String, dynamic> jsonMap = json.decode(response.bodyString!);
//         SalonUpgradeResponse jsonresponse =
//             SalonUpgradeResponse.fromJson(jsonMap);
//         bool status = jsonresponse.status;
//         message = jsonresponse.message;
//         print('Status: $status');
//         print('Message: $message');
//       } else {
//         EasyLoading.dismiss();
//         print('Request failed with status: ${response.statusCode}');
//       }
//     } else {
//       Response response = await parser.postIndividualUpgrade(premium);
//       EasyLoading.show(
//           status: 'Please wait...', maskType: EasyLoadingMaskType.clear);
//       if (response.statusCode == 200) {
//         EasyLoading.dismiss();
//         Map<String, dynamic> jsonMap = json.decode(response.bodyString!);
//         SalonUpgradeResponse jsonresponse =
//             SalonUpgradeResponse.fromJson(jsonMap);

//         bool status = jsonresponse.status;
//         message = jsonresponse.message;
//         if (status) {
//         } else {}
//         print('Status: $status');
//         print('Message: $message');
//       } else {
//         EasyLoading.dismiss();
//         print('Request failed with status: ${response.statusCode}');
//       }
//     }
//     update();
//   }

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

//   void onBanner(String value) {
//     debugPrint(value);
//     debugPrint('external links');
//     launchInBrowser(value);
//   }

//   Future<void> getBannerData() async {
//     //  var param = {"lat": parser.getLat(), "lng": parser.getLng()};
//     Response response = await parser.getBannerData();
//     // apiCalled = true;

//     if (response.statusCode == 200) {
//       Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
//       var bannerData = myMap['data'];
//       _bannerList = [];

//       bannerData.forEach((data) {
//         BannerModel banner = BannerModel.fromJson(data);
//         _bannerList.add(banner);
//       });
//       debugPrint(bannerList.length.toString());

//       update();
//     } else {
//       ApiChecker.checkApi(response);
//     }
//     update();
//   }

//   Future<void> getSalonAppointmentById() async {
//     Response response = await parser.getSalonList();
//     apiCalled = true;
//     if (response.statusCode == 200) {
//       Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
//       var body = myMap['data'];
//       _appointmentList = [];
//       _appointmentListOld = [];

//       body.forEach((data) {
//         AppointmentModel appointment = AppointmentModel.fromJson(data);
//         name = appointment.salonInfo!.name!;
//         if (appointment.status == 0) {
//           _appointmentList.add(appointment);
//         } else {
//           _appointmentListOld.add(appointment);
//         }
//       });
//     } else {
//       ApiChecker.checkApi(response);
//     }
//     update();
//   }

//   Future<void> getIndividualAppointmentsById() async {
//     Response response = await parser.getIndividualAppointmentsList();
//     apiCalled = true;
//     if (response.statusCode == 200) {
//       Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
//       var body = myMap['data'];
//       _appointmentList = [];
//       _appointmentListOld = [];
//       body.forEach((data) {
//         AppointmentModel appointment = AppointmentModel.fromJson(data);
//         name = appointment.individualInfo!.firstName! +
//             "" +
//             appointment.individualInfo!.lastName!;
//         print(name + 'name');

//         if (appointment.status == 0) {
//           _appointmentList.add(appointment);
//         } else {
//           _appointmentListOld.add(appointment);
//         }
//       });
//     } else {
//       ApiChecker.checkApi(response);
//     }
//     update();
//   }

//   void onAppointment(int id) {
//     Get.delete<OrderDetailsController>(force: true);
//     Get.toNamed(AppRouter.getOrderDetailsRoute(), arguments: [id]);
//   }

//   Future<void> launchInBrowser(String link) async {
//     var url = Uri.parse(link);
//     if (!await launchUrl(
//       url,
//       mode: LaunchMode.externalApplication,
//     )) {
//       throw '${'Could not launch'.tr} $url';
//     }
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/appointment_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/payment_options_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/upgrade_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/appointment_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/services/payment_socket_service.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/inbox_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/notification_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/order_details_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/premium_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../backend/models/banner_model.dart';

class AppointmentController extends GetxController
    with GetTickerProviderStateMixin
    implements GetxService {
  final AppointmentParser parser;

  List<AppointmentModel> _appointmentList = <AppointmentModel>[];
  List<AppointmentModel> get appointmentList => _appointmentList;

  List<AppointmentModel> _appointmentListOld = <AppointmentModel>[];
  List<AppointmentModel> get appointmentListOld => _appointmentListOld;

  // Filter properties
  int _selectedNewBookingsFilter = -1; // -1 means "All"
  int _selectedHistoryFilter = -1; // -1 means "All"

  int get selectedNewBookingsFilter => _selectedNewBookingsFilter;
  int get selectedHistoryFilter => _selectedHistoryFilter;

  bool apiCalled = false;
  String currencySide = AppConstants.defaultCurrencySide;
  String currencySymbol = AppConstants.defaultCurrencySymbol;
  String name = '';
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

  List<BannerModel> _bannerList = <BannerModel>[];
  List<BannerModel> get bannerList => _bannerList;

  AppointmentController({required this.parser});
  // Play Store / App Store (Adapty) billing disabled — use API payment WebView.
  // final adapty = Adapty();
  // List<AdaptyPaywallProduct>? paywallProducts;
  late TabController tabController;
  final box = GetStorage();

  late bool premiumFlag = box.read('premium') ?? false;
  bool get _premiumFlag => premiumFlag;

  setPremium(bool value) {
    premiumFlag = value;
    box.write('premium', value);
    update();
  }

  // Filter methods
  void setNewBookingsFilter(int statusIndex) {
    _selectedNewBookingsFilter = statusIndex;
    update();
  }

  void setHistoryFilter(int statusIndex) {
    _selectedHistoryFilter = statusIndex;
    update();
  }

  void clearAllFilters() {
    _selectedNewBookingsFilter = -1;
    _selectedHistoryFilter = -1;
    update();
  }

  List<AppointmentModel> getFilteredNewBookings() {
    if (_selectedNewBookingsFilter == -1) {
      return _appointmentList;
    }
    return _appointmentList
        .where(
            (appointment) => appointment.status == _selectedNewBookingsFilter)
        .toList();
  }

  List<AppointmentModel> getFilteredHistory() {
    if (_selectedHistoryFilter == -1) {
      return _appointmentListOld;
    }
    return _appointmentListOld
        .where((appointment) => appointment.status == _selectedHistoryFilter)
        .toList();
  }

  List<int> getAvailableStatusesForNewBookings() {
    Set<int> statuses = {};
    for (var appointment in _appointmentList) {
      statuses.add(appointment.status as int);
    }
    return statuses.toList()..sort();
  }

  List<int> getAvailableStatusesForHistory() {
    Set<int> statuses = {};
    for (var appointment in _appointmentListOld) {
      statuses.add(appointment.status as int);
    }
    return statuses.toList()..sort();
  }

  int getAppointmentCountForStatus(int statusIndex, bool isNewBookings) {
    final list = isNewBookings ? _appointmentList : _appointmentListOld;
    return list
        .where((appointment) => appointment.status == statusIndex)
        .length;
  }

  @override
  void onInit() {
    super.onInit();
    name = parser.getName();
    currencySide = parser.getCurrencySide();
    currencySymbol = parser.getCurrencySymbol();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_onAppointmentTabChanged);
    if (!parser.sharedPreferencesManager.hasOwnerSession()) return;
    getBannerData();
    getList();
    loadPremiumStatus();
    _bindPaymentSocket();
  }

  void _onAppointmentTabChanged() {
    if (tabController.indexIsChanging) return;
    update();
  }

  @override
  void onClose() {
    tabController.removeListener(_onAppointmentTabChanged);
    if (Get.isRegistered<PaymentSocketService>()) {
      Get.find<PaymentSocketService>().removeListener(_onPaymentCompleted);
    }
    super.onClose();
  }

  Future<void> _bindPaymentSocket() async {
    if (!Get.isRegistered<PaymentSocketService>()) return;
    final socket = Get.find<PaymentSocketService>();
    socket.addListener(_onPaymentCompleted);
    await socket.ensureConnected();
  }

  void _onPaymentCompleted(PaymentOptionsModel payment) {
    final partnerUid = parser.sharedPreferencesManager.getString('uid');
    final salonMatch = payment.salonId.toString() == partnerUid;
    final freelancerMatch = payment.freelancerId.toString() == partnerUid;
    if (partnerUid == null || (!salonMatch && !freelancerMatch)) {
      // Still refresh if booking exists in current lists.
      final bookId =
          payment.bookId != 0 ? payment.bookId : payment.appointmentId;
      final inList = _appointmentList.any((a) => a.id == bookId) ||
          _appointmentListOld.any((a) => a.id == bookId);
      if (!inList) return;
    }
    getList();
  }

  void loadPremiumStatus() {
    final isPremium = parser.getPremium();
    setPremium(isPremium);
  }

  /*
  updateCustomerStatus() async {
    final purchaserInfo = await Adapty().getProfile();
    ...
  }

  purchasePremium(AdaptyPaywallProduct paywallProducts) async { ... }

  void showOfferingDialog(BuildContext context) { ... Play Store sheet ... }

  Future<void> updateCustomerStatusRestore(BuildContext context) async { ... }

  getOfferings() async { ... }

  Future<void> loadProducts(AdaptyPaywall paywallNew) async { ... }
  */

  void showOfferingDialog(BuildContext context) {
    onUpgradeScreen();
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

  void showUpgradeDialog(BuildContext context) {
    onUpgradeScreen();
  }

  /*
  void showUpgradeDialog(BuildContext context) {
    showModalBottomSheet(
      ...
    );
  }

  Future<void> updateCustomerStatusRestore(BuildContext context) async {
    final purchaserInfo = await Adapty().getProfile();
    ...
  }

  void showOfferingDialogOld(BuildContext context) {
    showModalBottomSheet(
      ...
    );
  }

  Future<void> _launchUrlTerms() async { ... }

  Future<void> _launchUrlPrivacy() async { ... }

  getOfferings() async { ... }

  Future<void> loadProducts(AdaptyPaywall paywallNew) async { ... }
  */

  void getList() {
    if (!parser.sharedPreferencesManager.hasOwnerSession()) return;
    if (parser.getType() == 'salon') {
      getSalonAppointmentById();
    } else {
      getIndividualAppointmentsById();
    }
  }

  Future<void> postUpgrade(String premium) async {
    String message = '';
    if (parser.getType() == 'salon') {
      EasyLoading.show(
          status: 'Please wait...', maskType: EasyLoadingMaskType.clear);
      Response response = await parser.postSalonUpgrade(premium);
      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        Map<String, dynamic> jsonMap = json.decode(response.bodyString!);
        SalonUpgradeResponse jsonresponse =
            SalonUpgradeResponse.fromJson(jsonMap);
        bool status = jsonresponse.status;
        message = jsonresponse.message;
        print('Status: $status');
        print('Message: $message');
        if (status) {
          showDialogScreen(
              Get.key.currentContext!,
              'Success\nYou are now a premium user',
              message,
              Icons.check_circle,
              Colors.green);
        } else {
          showDialogScreen(
              Get.key.currentContext!,
              'Failed to upgrade account please try again',
              message,
              Icons.check_circle,
              Colors.red);
        }
      } else {
        EasyLoading.dismiss();
        showDialogScreen(
            Get.key.currentContext!,
            'Unknown Error! please try again',
            message,
            Icons.error,
            Colors.red);
        print('Request failed with status: ${response.body}');
      }
    } else {
      Response response = await parser.postIndividualUpgrade(premium);
      EasyLoading.show(
          status: 'Please wait...', maskType: EasyLoadingMaskType.clear);
      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        Map<String, dynamic> jsonMap = json.decode(response.bodyString!);
        SalonUpgradeResponse jsonresponse =
            SalonUpgradeResponse.fromJson(jsonMap);

        bool status = jsonresponse.status;
        message = jsonresponse.message;
        if (status) {
          showDialogScreen(
              Get.key.currentContext!,
              'Success\nYou are now a premium user',
              message,
              Icons.check_circle,
              Colors.green);
        } else {
          showDialogScreen(
              Get.key.currentContext!,
              'Failed to upgrade account please try again',
              message,
              Icons.check_circle,
              Colors.red);
        }
        print('Status: $status');
        print('Message: $message');
      } else {
        EasyLoading.dismiss();
        showDialogScreen(
            Get.key.currentContext!,
            'Failed to upgrade account please try again',
            message,
            Icons.check_circle,
            Colors.red);
        print('Request failed with status: ${response.statusCode}');
      }
    }
    update();
  }

  Future<void> postUpgradeLaunch(String premium) async {
    String message = '';
    if (parser.getType() == 'salon') {
      EasyLoading.show(
          status: 'Please wait...', maskType: EasyLoadingMaskType.clear);
      Response response = await parser.postSalonUpgrade(premium);
      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        Map<String, dynamic> jsonMap = json.decode(response.bodyString!);
        SalonUpgradeResponse jsonresponse =
            SalonUpgradeResponse.fromJson(jsonMap);
        bool status = jsonresponse.status;
        message = jsonresponse.message;
        print('Status: $status');
        print('Message: $message');
      } else {
        EasyLoading.dismiss();
        print('Request failed with status: ${response.statusCode}');
      }
    } else {
      Response response = await parser.postIndividualUpgrade(premium);
      EasyLoading.show(
          status: 'Please wait...', maskType: EasyLoadingMaskType.clear);
      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        Map<String, dynamic> jsonMap = json.decode(response.bodyString!);
        SalonUpgradeResponse jsonresponse =
            SalonUpgradeResponse.fromJson(jsonMap);

        bool status = jsonresponse.status;
        message = jsonresponse.message;
        if (status) {
        } else {}
        print('Status: $status');
        print('Message: $message');
      } else {
        EasyLoading.dismiss();
        print('Request failed with status: ${response.statusCode}');
      }
    }
    update();
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
                const SizedBox(height: 18),
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

  void onBanner(String value) {
    debugPrint(value);
    debugPrint('external links');
    launchInBrowser(value);
  }

  Future<void> getBannerData() async {
    Response response = await parser.getBannerData();

    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var bannerData = myMap['data'];
      _bannerList = [];

      bannerData.forEach((data) {
        BannerModel banner = BannerModel.fromJson(data);
        _bannerList.add(banner);
      });
      bannerList.removeWhere((element) => element.status == 0);
      debugPrint(bannerList.length.toString());
      update();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getSalonAppointmentById() async {
    Response response = await parser.getSalonList();
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'];
      _appointmentList = [];
      _appointmentListOld = [];

      body.forEach((data) {
        AppointmentModel appointment = AppointmentModel.fromJson(data);
        final salonName = appointment.salonInfo?.name?.toString().trim() ?? '';
        if (salonName.isNotEmpty) {
          name = salonName;
        } else if (name.isEmpty) {
          name = parser.getName();
        }
        if (appointment.status == 0) {
          _appointmentList.add(appointment);
        } else {
          _appointmentListOld.add(appointment);
        }
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getIndividualAppointmentsById() async {
    Response response = await parser.getIndividualAppointmentsList();
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'];
      _appointmentList = [];
      _appointmentListOld = [];
      body.forEach((data) {
        AppointmentModel appointment = AppointmentModel.fromJson(data);
        final first = appointment.individualInfo?.firstName?.toString().trim() ?? '';
        final last = appointment.individualInfo?.lastName?.toString().trim() ?? '';
        final fullName = '$first $last'.trim();
        if (fullName.isNotEmpty) {
          name = fullName;
        } else if (name.isEmpty) {
          name = parser.getName();
        }

        if (appointment.status == 0) {
          _appointmentList.add(appointment);
        } else {
          _appointmentListOld.add(appointment);
        }
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onAppointment(int id) {
    Get.delete<OrderDetailsController>(force: true);
    Get.toNamed(AppRouter.getOrderDetailsRoute(), arguments: [id]);
  }

  Future<void> launchInBrowser(String link) async {
    var url = Uri.parse(link);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw '${'Could not launch'.tr} $url';
    }
  }
}
