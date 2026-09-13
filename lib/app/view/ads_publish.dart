// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:skeletons/skeletons.dart';
// import 'package:ultimate_salon_owner_flutter/app/controller/ads_publish_controller.dart';
// import 'package:ultimate_salon_owner_flutter/app/env.dart';
// import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

// class AdsPublishScreen extends StatefulWidget {
//   const AdsPublishScreen({Key? key}) : super(key: key);

//   @override
//   State<AdsPublishScreen> createState() => _AdsPublishScreenState();
// }

// class _AdsPublishScreenState extends State<AdsPublishScreen> {
//   int? selectedIndex;
//   int? selectedIndex2;

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<AdsPublishController>(builder: (value) {
//       return Scaffold(
//         backgroundColor: ThemeProvider.whiteColor,
//         appBar: AppBar(
//           backgroundColor: ThemeProvider.appColor,
//           iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
//           centerTitle: true,
//           elevation: 0,
//           toolbarHeight: 50,
//           title: const Text(
//             // value.type == 'create' ? 'Create Service' : 'Update Service',
//             'Submit Ads',
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.start,
//             style: ThemeProvider.titleStyle,
//           ),
//         ),
//         body: value.apiCalled == false
//             ? SkeletonListView()
//             : SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Column(
//                     children: [
//                       Text('Select Your Ad Image'.tr,
//                           style: TextStyle(
//                               color: ThemeProvider.blackColor,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 10),
//                       GestureDetector(
//                         onTap: () {
//                           showCupertinoModalPopup<void>(
//                             context: context,
//                             builder: (BuildContext context) =>
//                                 CupertinoActionSheet(
//                               title: Text('Choose From'.tr),
//                               actions: <CupertinoActionSheetAction>[
//                                 CupertinoActionSheetAction(
//                                   isDefaultAction: true,
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                     value.selectFromGallery('camera');
//                                   },
//                                   child: Text('Camera'.tr),
//                                 ),
//                                 CupertinoActionSheetAction(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                     value.selectFromGallery('gallery');
//                                   },
//                                   child: Text('Gallery'.tr),
//                                 ),
//                                 CupertinoActionSheetAction(
//                                   isDestructiveAction: true,
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                   },
//                                   child: Text('Cancel'.tr),
//                                 )
//                               ],
//                             ),
//                           );
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Image.network(
//                               '${Environments.imageURL}${value.cover}',
//                               width: double.infinity,
//                               height: 150,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 // Return an alternative widget if the image fails to load
//                                 return Image.asset(
//                                   'assets/images/notfound.png',
//                                   fit: BoxFit.cover,
//                                   width: double.infinity,
//                                   height: 150,
//                                 );
//                               },
//                               loadingBuilder: (context, child, progress) {
//                                 if (progress == null) {
//                                   // When the image is loaded, display it
//                                   return child;
//                                 } else {
//                                   // While the image is loading, display a placeholder
//                                   return const Center(
//                                     child: CircularProgressIndicator(
//                                       color: ThemeProvider
//                                           .appColor, // Customize the color if needed
//                                     ),
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(vertical: 10),
//                       //   child: SizedBox(
//                       //     width: double.infinity,
//                       //     child: TextField(
//                       //       controller: value.nameTextEditor,
//                       //       decoration: InputDecoration(
//                       //         filled: true,
//                       //         fillColor: ThemeProvider.whiteColor,
//                       //         hintText: 'Service Name'.tr,
//                       //         contentPadding: const EdgeInsets.only(
//                       //             bottom: 8.0, top: 14.0, left: 10),
//                       //         focusedBorder: const OutlineInputBorder(
//                       //           borderSide:
//                       //               BorderSide(color: ThemeProvider.appColor),
//                       //         ),
//                       //         enabledBorder: const OutlineInputBorder(
//                       //             borderSide: BorderSide(
//                       //                 color: ThemeProvider.greyColor)),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(vertical: 10),
//                       //   child: Container(
//                       //     decoration: BoxDecoration(
//                       //       borderRadius: BorderRadius.circular(5.0),
//                       //       border: Border.all(
//                       //           color: Colors.grey, style: BorderStyle.solid),
//                       //     ),
//                       //     child: InkWell(
//                       //       onTap: () {
//                       //         value.onServiceCategories();
//                       //       },
//                       //       child: Padding(
//                       //         padding: const EdgeInsets.symmetric(
//                       //             horizontal: 10.0, vertical: 10),
//                       //         child: Column(
//                       //           crossAxisAlignment: CrossAxisAlignment.start,
//                       //           children: [
//                       //             Text(
//                       //               'Categories'.tr,
//                       //               style: const TextStyle(
//                       //                   color: ThemeProvider.greyColor,
//                       //                   fontSize: 14),
//                       //             ),
//                       //             Row(
//                       //               mainAxisAlignment:
//                       //                   MainAxisAlignment.spaceBetween,
//                       //               children: [
//                       //                 value.selectedCategoryName == ''
//                       //                     ? Text(
//                       //                         'Select Categories'.tr,
//                       //                         style:
//                       //                             const TextStyle(fontSize: 17),
//                       //                       )
//                       //                     : Text(value.selectedCategoryName,
//                       //                         style: const TextStyle(
//                       //                             fontSize: 17)),
//                       //                 const Icon(
//                       //                   Icons.expand_more,
//                       //                   color: ThemeProvider.greyColor,
//                       //                 ),
//                       //               ],
//                       //             ),
//                       //           ],
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       const SizedBox(
//                         width: double.infinity,
//                         child: Padding(
//                           padding: EdgeInsets.only(left: 8.0),
//                           child: Text('Recommended Image Size - 1024x500'.tr,
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500)),
//                         ),
//                       ),
//                       const SizedBox(height: 20.0),

//                       const Align(
//                         alignment: Alignment.centerLeft,
//                         child: Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Text('Select Ad Title'.tr,
//                               style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             border:
//                                 Border.all(color: Colors.grey), // Add border
//                             borderRadius: BorderRadius.circular(
//                                 5.0), // Optional: add border radius
//                           ),
//                           child: TextField(
//                             controller: value
//                                 .textControllerTitle, // Assign the controller
//                             decoration: InputDecoration(
//                               hintText:
//                                   'Enter title', // Hint text for the TextField
//                               border: InputBorder
//                                   .none, // Hide the default border of the TextField
//                               contentPadding: EdgeInsets.all(
//                                   10.0), // Padding inside the TextField
//                             ),
//                           ),
//                         ),
//                       ),
//                       // const SizedBox(height: 10.0),

//                       // const Align(
//                       //   alignment: Alignment.centerLeft,
//                       //   child: Padding(
//                       //     padding: EdgeInsets.all(8.0),
//                       //     child: Text('Select Ad Type'.tr,
//                       //         style: TextStyle(
//                       //             color: Colors.black,
//                       //             fontSize: 18,
//                       //             fontWeight: FontWeight.bold)),
//                       //   ),
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.all(8.0),
//                       //   child: Container(
//                       //     decoration: BoxDecoration(
//                       //       border:
//                       //           Border.all(color: Colors.grey), // Add border
//                       //       borderRadius: BorderRadius.circular(
//                       //           5.0), // Optional: add border radius
//                       //     ),
//                       //     child: Padding(
//                       //       padding:
//                       //           const EdgeInsets.symmetric(horizontal: 8.0),
//                       //       child: DropdownButtonFormField(
//                       //         value: value.selectedTypeValue,
//                       //         hint: const Text(
//                       //           'Select',
//                       //           style: TextStyle(
//                       //               color:
//                       //                   Colors.grey), // Displaying hint on top
//                       //         ),
//                       //         onChanged: (newValue) {
//                       //           value.selectedTypeValue = newValue;
//                       //           if (value.selectedTypeValue == 6) {
//                       //             value.setIsLink(true);
//                       //           } else {
//                       //             value.setIsLink(false);
//                       //           }
//                       //         },
//                       //         items: value.dropdownItemsType.keys
//                       //             .map((String item) {
//                       //           return DropdownMenuItem(
//                       //             value: value.dropdownItemsType[item],
//                       //             child: Text(item),
//                       //           );
//                       //         }).toList(),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       const SizedBox(height: 10.0),

//                       // value.isLink
//                       //     ? Column(
//                       //         children: [
//                       //           Padding(
//                       //             padding: const EdgeInsets.all(8.0),
//                       //             child: Container(
//                       //               decoration: BoxDecoration(
//                       //                 border: Border.all(
//                       //                     color: Colors.grey), // Add border
//                       //                 borderRadius: BorderRadius.circular(
//                       //                     5.0), // Optional: add border radius
//                       //               ),
//                       //               child: TextField(
//                       //                 controller: value
//                       //                     .textControllerLink, // Assign the controller
//                       //                 decoration: const InputDecoration(
//                       //                   hintText:
//                       //                       'Enter link', // Hint text for the TextField
//                       //                   border: InputBorder
//                       //                       .none, // Hide the default border of the TextField
//                       //                   contentPadding: EdgeInsets.all(
//                       //                       10.0), // Padding inside the TextField
//                       //                 ),
//                       //               ),
//                       //             ),
//                       //           ),
//                       //           const SizedBox(height: 10.0),
//                       //         ],
//                       //       )
//                       //     : Container(),

//                       const Align(
//                         alignment: Alignment.centerLeft,
//                         child: Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Text('Select Page Position'.tr,
//                               style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             border:
//                                 Border.all(color: Colors.grey), // Add border
//                             borderRadius: BorderRadius.circular(
//                                 5.0), // Optional: add border radius
//                           ),
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: DropdownButtonFormField(
//                               value: value.selectedPagePositionValue,
//                               hint: const Text(
//                                 'Select',
//                                 style: TextStyle(
//                                     color:
//                                         Colors.grey), // Displaying hint on top
//                               ),
//                               onChanged: (newValue) {
//                                 value.selectedPagePositionValue = newValue;
//                                 print(newValue);
//                                 if (value.selectedPagePositionValue == 2) {
//                                   value.setSearchPageAd(false);
//                                   print(value.isSearchPage);
//                                 } else {
//                                   value.setSearchPageAd(true);
//                                 }
//                               },
//                               items: value.dropdownItemsPosition.keys
//                                   .map((String item) {
//                                 return DropdownMenuItem(
//                                   value: value.dropdownItemsPosition[item],
//                                   child: Text(item),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10.0),
//                       const Align(
//                         alignment: Alignment.centerLeft,
//                         child: Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Text('Select Duration'.tr,
//                               style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                       ),
//                       value.isSearchPage
//                           ? Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: Colors.grey), // Add border
//                                   borderRadius: BorderRadius.circular(
//                                       5.0), // Optional: add border radius
//                                 ),
//                                 child: SizedBox(
//                                   height: 180,
//                                   child: Builder(
//                                     builder: (context) {
//                                       if (value.paywallProductsSearch == null ||
//                                           value
//                                               .paywallProductsSearch!.isEmpty) {
//                                         return const Center(
//                                             child: CircularProgressIndicator());
//                                       } else {
//                                         return ListView.builder(
//                                           itemCount:
//                                               value.paywallProductsHome!.length,
//                                           itemBuilder: (context, index) {
//                                             final isSelected =
//                                                 index == selectedIndex;

//                                             final price = value
//                                                 .paywallProductsHome![index]
//                                                 .price
//                                                 .amount;

//                                             final currency = value
//                                                 .paywallProductsHome![index]
//                                                 .price
//                                                 .currencySymbol!;

//                                             final title = value
//                                                 .paywallProductsHome![index]
//                                                 .localizedTitle;

//                                             return InkWell(
//                                               onTap: () {
//                                                 setState(() {
//                                                   selectedIndex =
//                                                       isSelected ? null : index;

//                                                   final RegExp digitRegex =
//                                                       RegExp(r'\d+');
//                                                   final match = digitRegex
//                                                       .firstMatch(title);

// // Extract digits or handle if no digits found
//                                                   final extractedDigits =
//                                                       match != null
//                                                           ? match.group(0)
//                                                           : 'No digits found';

//                                                   print(
//                                                       'Extracted digits: $extractedDigits');

//                                                   value.selectedDurationValue =
//                                                       extractedDigits!;
//                                                   // value
//                                                   //     .paywallProductsHome![
//                                                   //         index]
//                                                   //     .subscriptionDetails!
//                                                   //     .localizedSubscriptionPeriod!;

//                                                   value.setAdPrice(price);

//                                                   value.setSku(value
//                                                           .paywallProductsHome![
//                                                       index]);

//                                                   print(value
//                                                       .selectedDurationValue);
//                                                 });
//                                               },
//                                               child: Container(
//                                                 decoration: BoxDecoration(
//                                                   border: Border.all(
//                                                     color: isSelected
//                                                         ? Colors.blue
//                                                         : Colors
//                                                             .white, // Mark selected item
//                                                     width: 2.0, // Border width
//                                                   ),
//                                                 ),
//                                                 padding:
//                                                     const EdgeInsets.all(8.0),
//                                                 child: Column(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.start,
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     SingleChildScrollView(
//                                                       scrollDirection:
//                                                           Axis.horizontal,
//                                                       child: Row(
//                                                         children: [
//                                                           Container(
//                                                             width:
//                                                                 20, // Selection marker width
//                                                             height:
//                                                                 20, // Selection marker height
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               shape: BoxShape
//                                                                   .circle,
//                                                               border: Border.all(
//                                                                   color: Colors
//                                                                       .grey),
//                                                               color: isSelected
//                                                                   ? Colors.blue
//                                                                   : Colors
//                                                                       .transparent, // Mark selected item
//                                                             ),
//                                                           ),
//                                                           const SizedBox(
//                                                               width: 10),
//                                                           Text(
//                                                             'Plan : $title', // Display duration
//                                                             style: TextStyle(
//                                                               fontSize: 13,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                               color: isSelected
//                                                                   ? Colors.blue
//                                                                   : Colors
//                                                                       .black, // Mark selected item
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                     Padding(
//                                                       padding:
//                                                           const EdgeInsets.only(
//                                                               left: 30.0),
//                                                       child: Text(
//                                                         'Price : ${price.toString()} $currency', // Display price
//                                                         style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           color: isSelected
//                                                               ? Colors.blue
//                                                               : Colors
//                                                                   .black, // Mark selected item
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         );
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: Colors.grey), // Add border
//                                   borderRadius: BorderRadius.circular(
//                                       5.0), // Optional: add border radius
//                                 ),
//                                 child:
//                                     // Padding(
//                                     //   padding:
//                                     //       const EdgeInsets.symmetric(horizontal: 8.0),
//                                     //   child: DropdownButtonFormField(
//                                     //     value: value.selectedDurationValue,
//                                     //     hint: const Text(
//                                     //       'Select',
//                                     //       style: TextStyle(
//                                     //           color:
//                                     //               Colors.grey), // Displaying hint on top
//                                     //     ),
//                                     //     onChanged: (newValue) {
//                                     //       value.selectedDurationValue = newValue;
//                                     //       switch (newValue) {
//                                     //         case 1:
//                                     //           value.setAdPrice(1000);
//                                     //           break;
//                                     //         case 3:
//                                     //           value.setAdPrice(1500);
//                                     //           break;
//                                     //         case 6:
//                                     //           value.setAdPrice(2000);
//                                     //           break;
//                                     //       }
//                                     //     },
//                                     //     items: value.dropdownItemsDuration.keys
//                                     //         .map((String item) {
//                                     //       return DropdownMenuItem(
//                                     //         value: value.dropdownItemsDuration[item],
//                                     //         child: Text(item),
//                                     //       );
//                                     //     }).toList(),
//                                     //   ),
//                                     // ),

//                                     SizedBox(
//                                   height: 180,
//                                   child: Builder(
//                                     builder: (context) {
//                                       if (value.paywallProductsHome == null ||
//                                           value.paywallProductsHome!.isEmpty) {
//                                         return const Center(
//                                             child: CircularProgressIndicator());
//                                       } else {
//                                         return ListView.builder(
//                                           itemCount: value
//                                               .paywallProductsSearch!.length,
//                                           itemBuilder: (context, index) {
//                                             final isSelected2 =
//                                                 index == selectedIndex2;

//                                             final price = value
//                                                 .paywallProductsSearch![index]
//                                                 .price
//                                                 .amount;
//                                             final currency = value
//                                                 .paywallProductsSearch![index]
//                                                 .price
//                                                 .currencySymbol!;
//                                             final title = value
//                                                 .paywallProductsSearch![index]
//                                                 .localizedTitle;

//                                             return InkWell(
//                                               onTap: () {
//                                                 setState(() {
//                                                   selectedIndex2 = isSelected2
//                                                       ? null
//                                                       : index;

//                                                   final RegExp digitRegex =
//                                                       RegExp(r'\d+');
//                                                   final match = digitRegex
//                                                       .firstMatch(title);

// // Extract digits or handle if no digits found
//                                                   final extractedDigits =
//                                                       match != null
//                                                           ? match.group(0)
//                                                           : 'No digits found';

//                                                   print(
//                                                       'Extracted digits: $extractedDigits');

//                                                   value.selectedDurationValue =
//                                                       extractedDigits!;

//                                                   // value.selectedDurationValue = value
//                                                   //     .paywallProductsSearch![
//                                                   //         index]
//                                                   //     .subscriptionDetails!
//                                                   //     .localizedSubscriptionPeriod!;

//                                                   value.setAdPrice(price);

//                                                   value.setSku(value
//                                                           .paywallProductsSearch![
//                                                       index]);

//                                                   print(value
//                                                       .selectedDurationValue);
//                                                 });
//                                               },
//                                               child: Container(
//                                                 decoration: BoxDecoration(
//                                                   border: Border.all(
//                                                     width: 2.0, // Border width
//                                                     color: isSelected2
//                                                         ? Colors.blue
//                                                         : Colors
//                                                             .white, // Dynamic border color
//                                                   ),
//                                                 ),
//                                                 padding:
//                                                     const EdgeInsets.all(8.0),
//                                                 child: Column(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.start,
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     SingleChildScrollView(
//                                                       scrollDirection:
//                                                           Axis.horizontal,
//                                                       child: Row(
//                                                         children: [
//                                                           Container(
//                                                             width:
//                                                                 20, // Selection marker width
//                                                             height:
//                                                                 20, // Selection marker height
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               shape: BoxShape
//                                                                   .circle,
//                                                               border: Border.all(
//                                                                   color: Colors
//                                                                       .grey),
//                                                               color: isSelected2
//                                                                   ? Colors.blue
//                                                                   : Colors
//                                                                       .transparent, // Mark selected item
//                                                             ),
//                                                           ),
//                                                           const SizedBox(
//                                                               width: 10),
//                                                           Text(
//                                                             'Plan : $title',
//                                                             style: TextStyle(
//                                                               fontSize: 13,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                               color: isSelected2
//                                                                   ? Colors.blue
//                                                                   : Colors
//                                                                       .black, // Dynamic text color
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                     //const SizedBox(width: 30),
//                                                     Padding(
//                                                       padding:
//                                                           const EdgeInsets.only(
//                                                               left: 30.0),
//                                                       child: Text(
//                                                         'Price : ${price.toString()} $currency',
//                                                         style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           color: isSelected2
//                                                               ? Colors.blue
//                                                               : Colors
//                                                                   .black, // Dynamic text color
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         );
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ),
//                       const SizedBox(height: 10.0),

//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(vertical: 10),
//                       //   child: Container(
//                       //     decoration: BoxDecoration(
//                       //       borderRadius: BorderRadius.circular(5.0),
//                       //       border: Border.all(
//                       //           color: Colors.grey, style: BorderStyle.solid),
//                       //     ),
//                       //     child: InkWell(
//                       //       onTap: () {
//                       //         value.onServiceNames(value.selectedCategoryId);
//                       //       },
//                       //       child: Padding(
//                       //         padding: const EdgeInsets.symmetric(
//                       //             horizontal: 10.0, vertical: 10),
//                       //         child: Column(
//                       //           crossAxisAlignment: CrossAxisAlignment.start,
//                       //           children: [
//                       //             Text(
//                       //               'Service Name'.tr,
//                       //               style: const TextStyle(
//                       //                   color: ThemeProvider.greyColor,
//                       //                   fontSize: 14),
//                       //             ),
//                       //             Row(
//                       //               mainAxisAlignment:
//                       //                   MainAxisAlignment.spaceBetween,
//                       //               children: [
//                       //                 value.selectedServiceName == ''
//                       //                     ? Text(
//                       //                         'Select Service'.tr,
//                       //                         style:
//                       //                             const TextStyle(fontSize: 17),
//                       //                       )
//                       //                     : Text(value.selectedServiceName,
//                       //                         style: const TextStyle(
//                       //                             fontSize: 17)),
//                       //                 const Icon(
//                       //                   Icons.expand_more,
//                       //                   color: ThemeProvider.greyColor,
//                       //                 ),
//                       //               ],
//                       //             ),
//                       //           ],
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(vertical: 10),
//                       //   child: SizedBox(
//                       //     width: double.infinity,
//                       //     child: TextField(
//                       //       controller: value.priceTextEditor,
//                       //       onChanged: (String txt) {
//                       //         value.onRealPrice(txt);
//                       //       },
//                       //       decoration: InputDecoration(
//                       //         filled: true,
//                       //         fillColor: ThemeProvider.whiteColor,
//                       //         hintText: 'Service Price'.tr,
//                       //         contentPadding: const EdgeInsets.only(
//                       //             bottom: 8.0, top: 14.0, left: 10),
//                       //         focusedBorder: const OutlineInputBorder(
//                       //           borderSide:
//                       //               BorderSide(color: ThemeProvider.appColor),
//                       //         ),
//                       //         enabledBorder: const OutlineInputBorder(
//                       //             borderSide: BorderSide(
//                       //                 color: ThemeProvider.greyColor)),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(vertical: 10),
//                       //   child: SizedBox(
//                       //     width: double.infinity,
//                       //     child: TextField(
//                       //       controller: value.discountTextEditor,
//                       //       onChanged: (String txt) {
//                       //         value.onDiscountPrice(txt);
//                       //       },
//                       //       decoration: InputDecoration(
//                       //         filled: true,
//                       //         fillColor: ThemeProvider.whiteColor,
//                       //         hintText: 'Discount %'.tr,
//                       //         contentPadding: const EdgeInsets.only(
//                       //             bottom: 8.0, top: 14.0, left: 10),
//                       //         focusedBorder: const OutlineInputBorder(
//                       //           borderSide:
//                       //               BorderSide(color: ThemeProvider.appColor),
//                       //         ),
//                       //         enabledBorder: const OutlineInputBorder(
//                       //             borderSide: BorderSide(
//                       //                 color: ThemeProvider.greyColor)),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(vertical: 10),
//                       //   child: SizedBox(
//                       //     width: double.infinity,
//                       //     child: TextField(
//                       //       controller: value.offTextEditor,
//                       //       decoration: InputDecoration(
//                       //         filled: true,
//                       //         enabled: false,
//                       //         disabledBorder: const OutlineInputBorder(
//                       //             borderSide: BorderSide(
//                       //                 color: ThemeProvider.greyColor)),
//                       //         fillColor: ThemeProvider.whiteColor,
//                       //         hintText: 'Sell Price'.tr,
//                       //         contentPadding: const EdgeInsets.only(
//                       //             bottom: 8.0, top: 14.0, left: 10),
//                       //         focusedBorder: const OutlineInputBorder(
//                       //           borderSide:
//                       //               BorderSide(color: ThemeProvider.appColor),
//                       //         ),
//                       //         enabledBorder: const OutlineInputBorder(
//                       //             borderSide: BorderSide(
//                       //                 color: ThemeProvider.greyColor)),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(vertical: 10),
//                       //   child: SizedBox(
//                       //     width: double.infinity,
//                       //     child: TextField(
//                       //       controller: value.durationTextEditor,
//                       //       keyboardType: TextInputType.number,
//                       //       decoration: InputDecoration(
//                       //         filled: true,
//                       //         disabledBorder: const OutlineInputBorder(
//                       //             borderSide: BorderSide(
//                       //                 color: ThemeProvider.greyColor)),
//                       //         fillColor: ThemeProvider.whiteColor,
//                       //         hintText: 'Service Duration'.tr,
//                       //         contentPadding: const EdgeInsets.only(
//                       //             bottom: 8.0, top: 14.0, left: 10),
//                       //         focusedBorder: const OutlineInputBorder(
//                       //           borderSide:
//                       //               BorderSide(color: ThemeProvider.appColor),
//                       //         ),
//                       //         enabledBorder: const OutlineInputBorder(
//                       //             borderSide: BorderSide(
//                       //                 color: ThemeProvider.greyColor)),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(vertical: 10),
//                       //   child: SizedBox(
//                       //     width: double.infinity,
//                       //     child: TextField(
//                       //       controller: value.descriptionsTextEditor,
//                       //       maxLines: 5,
//                       //       decoration: InputDecoration(
//                       //         filled: true,
//                       //         disabledBorder: const OutlineInputBorder(
//                       //             borderSide: BorderSide(
//                       //                 color: ThemeProvider.greyColor)),
//                       //         fillColor: ThemeProvider.whiteColor,
//                       //         hintText: 'Description'.tr,
//                       //         contentPadding: const EdgeInsets.only(
//                       //             bottom: 8.0, top: 14.0, left: 10),
//                       //         focusedBorder: const OutlineInputBorder(
//                       //           borderSide:
//                       //               BorderSide(color: ThemeProvider.appColor),
//                       //         ),
//                       //         enabledBorder: const OutlineInputBorder(
//                       //             borderSide: BorderSide(
//                       //                 color: ThemeProvider.greyColor)),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(vertical: 10),
//                       //   child: Container(
//                       //     decoration: BoxDecoration(
//                       //       borderRadius: BorderRadius.circular(5.0),
//                       //       border: Border.all(
//                       //           color: Colors.grey, style: BorderStyle.solid),
//                       //     ),
//                       //     child: InkWell(
//                       //       onTap: () {
//                       //         showCupertinoModalPopup<void>(
//                       //           context: context,
//                       //           builder: (BuildContext context) =>
//                       //               CupertinoActionSheet(
//                       //             title: Text(
//                       //               'Choose From'.tr,
//                       //               style: const TextStyle(
//                       //                   fontFamily: 'bold',
//                       //                   color: ThemeProvider.blackColor,
//                       //                   fontSize: 14),
//                       //             ),
//                       //             actions: <CupertinoActionSheetAction>[
//                       //               CupertinoActionSheetAction(
//                       //                 child: Text(
//                       //                   'Available'.tr,
//                       //                   style: const TextStyle(
//                       //                       color: ThemeProvider.appColor,
//                       //                       fontSize: 15),
//                       //                 ),
//                       //                 onPressed: () {
//                       //                   value.updateStatus(1);
//                       //                   Navigator.pop(context);
//                       //                 },
//                       //               ),
//                       //               CupertinoActionSheetAction(
//                       //                 child: Text(
//                       //                   'Hide'.tr,
//                       //                   style: const TextStyle(
//                       //                       color: ThemeProvider.appColor,
//                       //                       fontSize: 15),
//                       //                 ),
//                       //                 onPressed: () {
//                       //                   value.updateStatus(0);
//                       //                   Navigator.pop(context);
//                       //                 },
//                       //               ),
//                       //               CupertinoActionSheetAction(
//                       //                 child: Text(
//                       //                   'Cancel'.tr,
//                       //                   style: const TextStyle(
//                       //                       fontFamily: 'bold',
//                       //                       color: ThemeProvider.redColor,
//                       //                       fontSize: 14),
//                       //                 ),
//                       //                 onPressed: () {
//                       //                   Navigator.pop(context);
//                       //                 },
//                       //               ),
//                       //             ],
//                       //           ),
//                       //         );
//                       //       },
//                       //       child: Padding(
//                       //         padding: const EdgeInsets.symmetric(
//                       //             horizontal: 10.0, vertical: 10),
//                       //         child: Column(
//                       //           crossAxisAlignment: CrossAxisAlignment.start,
//                       //           children: [
//                       //             Text(
//                       //               'Status'.tr,
//                       //               style: const TextStyle(
//                       //                   color: ThemeProvider.greyColor,
//                       //                   fontSize: 14),
//                       //             ),
//                       //             Row(
//                       //               mainAxisAlignment:
//                       //                   MainAxisAlignment.spaceBetween,
//                       //               children: [
//                       //                 Text(
//                       //                   value.selectedStatus == 1
//                       //                       ? 'Available'.tr
//                       //                       : 'Hide'.tr,
//                       //                   style: const TextStyle(fontSize: 17),
//                       //                 ),
//                       //                 const Icon(
//                       //                   Icons.expand_more,
//                       //                   color: ThemeProvider.greyColor,
//                       //                 ),
//                       //               ],
//                       //             ),
//                       //           ],
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(vertical: 10),
//                       //   child: Row(
//                       //     children: [
//                       //       Text(
//                       //         'Upload More Image'.tr,
//                       //         style: const TextStyle(
//                       //             fontFamily: 'bold', fontSize: 14),
//                       //       ),
//                       //     ],
//                       //   ),
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.only(bottom: 20),
//                       //   child: GridView.count(
//                       //     primary: false,
//                       //     crossAxisCount: 3,
//                       //     mainAxisSpacing: 10,
//                       //     crossAxisSpacing: 10,
//                       //     shrinkWrap: true,
//                       //     childAspectRatio: 100 / 100,
//                       //     padding: EdgeInsets.zero,
//                       //     children: List.generate(
//                       //       value.gallery.length,
//                       //       (index) {
//                       //         return GestureDetector(
//                       //           onTap: () {
//                       //             showCupertinoModalPopup<void>(
//                       //               context: context,
//                       //               builder: (BuildContext context) =>
//                       //                   CupertinoActionSheet(
//                       //                 title: Text('Choose From'.tr),
//                       //                 actions: <CupertinoActionSheetAction>[
//                       //                   CupertinoActionSheetAction(
//                       //                     isDefaultAction: true,
//                       //                     onPressed: () {
//                       //                       Navigator.pop(context);
//                       //                       value.selectFromGalleryOthers(
//                       //                           'camera', index);
//                       //                     },
//                       //                     child: Text('Camera'.tr),
//                       //                   ),
//                       //                   CupertinoActionSheetAction(
//                       //                     onPressed: () {
//                       //                       Navigator.pop(context);
//                       //                       value.selectFromGalleryOthers(
//                       //                           'gallery', index);
//                       //                     },
//                       //                     child: Text('Gallery'.tr),
//                       //                   ),
//                       //                   CupertinoActionSheetAction(
//                       //                     isDestructiveAction: true,
//                       //                     onPressed: () {
//                       //                       Navigator.pop(context);
//                       //                     },
//                       //                     child: Text('Cancel'.tr),
//                       //                   )
//                       //                 ],
//                       //               ),
//                       //             );
//                       //           },
//                       //           child: SizedBox(
//                       //             height: 150,
//                       //             width: 150,
//                       //             child: ClipRRect(
//                       //               borderRadius: BorderRadius.circular(5.0),
//                       //               child: FadeInImage(
//                       //                 image: NetworkImage(
//                       //                     '${Environments.imageURL}${value.gallery[index].toString()}'),
//                       //                 placeholder: const AssetImage(
//                       //                     "assets/images/placeholder.jpeg"),
//                       //                 imageErrorBuilder:
//                       //                     (context, error, stackTrace) {
//                       //                   return Image.asset(
//                       //                     'assets/images/notfound.png',
//                       //                     fit: BoxFit.cover,
//                       //                     height: 150,
//                       //                     width: 150,
//                       //                   );
//                       //                 },
//                       //                 fit: BoxFit.cover,
//                       //                 height: 150,
//                       //                 width: 150,
//                       //               ),
//                       //             ),
//                       //           ),
//                       //         );
//                       //       },
//                       //     ),
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//         bottomNavigationBar: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//           child: value.action == 'new'
//               ? InkWell(
//                   onTap: () {
//                     // value.onSubmit();
//                     value.purchasePremium(context);
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 13.0),
//                     decoration: contentButtonStyle(),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'SUBMIT'.tr,
//                           style: const TextStyle(
//                               color: ThemeProvider.whiteColor, fontSize: 17),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               : InkWell(
//                   onTap: () {
//                     // value.onUpdateService();
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 13.0),
//                     decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.all(
//                         Radius.circular(100.0),
//                       ),
//                       color: ThemeProvider.greenColor,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'UPDATE'.tr,
//                           style: const TextStyle(
//                               color: ThemeProvider.whiteColor, fontSize: 17),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//         ),
//       );
//     });
//   }
// }

// contentButtonStyle() {
//   return const BoxDecoration(
//     borderRadius: BorderRadius.all(
//       Radius.circular(100.0),
//     ),
//     gradient: LinearGradient(
//       begin: Alignment.centerLeft,
//       end: Alignment.centerRight,
//       colors: [
//         Color.fromARGB(229, 52, 1, 255),
//         Color.fromARGB(228, 111, 75, 255),
//       ],
//     ),
//   );
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/ads_publish_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class AdsPublishScreen extends StatefulWidget {
  const AdsPublishScreen({Key? key}) : super(key: key);

  @override
  State<AdsPublishScreen> createState() => _AdsPublishScreenState();
}

class _AdsPublishScreenState extends State<AdsPublishScreen> {
  int? selectedIndex;
  int? selectedIndex2;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdsPublishController>(builder: (value) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: ThemeProvider.whiteColor,
          appBar: AppBar(
            backgroundColor: ThemeProvider.appColor,
            iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
            centerTitle: true,
            elevation: 0,
            toolbarHeight: 50,
            title: Text('Submit Ads'.tr,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: ThemeProvider.titleStyle,
            ),
          ),
          body: value.apiCalled == false
              ? SkeletonListView()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Upload Section
                        _buildSectionHeader('Select Your Ad Image'),
                        const SizedBox(height: 10),
                        _buildImagePicker(value, context),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Recommended Image Size - 1024x500'.tr,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(height: 24),

                        // Ad Title Section
                        _buildSectionHeader('Ad Title'),
                        _buildTextField(
                          controller: value.textControllerTitle,
                          hintText: 'Enter compelling ad title'.tr,
                        ),
                        const SizedBox(height: 24),

                        // Page Position Section
                        _buildSectionHeader('Page Position'),
                        _buildDropdown(
                          value: value.selectedPagePositionValue,
                          items: value.dropdownItemsPosition,
                          onChanged: (newValue) {
                            value.selectedPagePositionValue = newValue;
                            if (value.selectedPagePositionValue == 2) {
                              value.setSearchPageAd(false);
                            } else {
                              value.setSearchPageAd(true);
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        _buildSectionHeader('Ad Type'),
                        _buildDropdown(
                          value: value.selectedTypeValue,
                          items: value.dropdownTypes,
                          onChanged: (newValue) {
                            value.selectedTypeValue = newValue;
                            if (value.selectedTypeValue == 5) {
                              value.setLinkTextField(true);
                            } else {
                              value.setLinkTextField(false);
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        value.linkTextField
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader(
                                      'Enter External Link Url'),
                                  _buildTextField(
                                    controller: value.textControllerLink,
                                    hintText: 'Enter url'.tr,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              )
                            : SizedBox.shrink(),

                        // Duration Section
                        _buildSectionHeader('Ad Duration'),
                        _buildDurationSection(value),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: value.action == 'new'
                  ? _buildSubmitButton(value, context)
                  : _buildUpdateButton(value),
            ),
          ),
        ),
      );
    });
  }

  // Section Header Widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: ThemeProvider.blackColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Image Picker Widget
  Widget _buildImagePicker(AdsPublishController value, BuildContext context) {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            title: Text('Choose From'.tr),
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  value.selectFromGallery('camera');
                },
                child: Text('Camera'.tr),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  value.selectFromGallery('gallery');
                },
                child: Text('Gallery'.tr),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'.tr),
              )
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AppNetImage(
            path: value.cover,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            placeholder: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported,
                      size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to select image'.tr,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Text Field Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  // Dropdown Widget
  Widget _buildDropdown({
    required dynamic value,
    required Map<String, dynamic> items,
    required Function(dynamic) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField(
          value: value,
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
          hint: Text('Select'.tr,
            style: TextStyle(color: Colors.grey.shade500),
          ),
          onChanged: onChanged,
          items: items.keys.map((String item) {
            return DropdownMenuItem(
              value: items[item],
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Duration Selection Widget
  Widget _buildDurationSection(AdsPublishController value) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: value.isSearchPage
          ? _buildDurationList(value, value.paywallProductsHome, selectedIndex)
          : _buildDurationList(
              value, value.paywallProductsSearch, selectedIndex2),
    );
  }

  // Duration List Widget
  Widget _buildDurationList(
      AdsPublishController value, List? products, int? selectedIdx) {
    if (products == null || products.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: ThemeProvider.appColor),
              const SizedBox(height: 16),
              Text('Loading plans...'.tr,
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: products.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIdx;
          final price = products[index].price.amount;
          final currency = products[index].price.currencySymbol!;
          final title = products[index].localizedTitle;

          return InkWell(
            onTap: () {
              setState(() {
                if (value.isSearchPage) {
                  selectedIndex = isSelected ? null : index;
                } else {
                  selectedIndex2 = isSelected ? null : index;
                }

                final RegExp digitRegex = RegExp(r'\d+');
                final match = digitRegex.firstMatch(title);
                final extractedDigits =
                    match != null ? match.group(0) : 'No digits found';

                value.selectedDurationValue = extractedDigits!;
                value.setAdPrice(price);
                value.setSku(products[index]);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected ? ThemeProvider.appColor : Colors.grey,
                        width: 2,
                      ),
                      color: isSelected
                          ? ThemeProvider.appColor
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Plan: $title'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? ThemeProvider.appColor
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Price: $price $currency'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? ThemeProvider.appColor
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Submit Button Widget
  Widget _buildSubmitButton(AdsPublishController value, BuildContext context) {
    return ElevatedButton(
      onPressed: () => value.purchasePremium(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeProvider.appColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 2,
      ),
      child: Text(
        'SUBMIT AD'.tr,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Update Button Widget
  Widget _buildUpdateButton(AdsPublishController value) {
    return ElevatedButton(
      onPressed: () {
        // value.onUpdateService();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeProvider.greenColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 2,
      ),
      child: Text(
        'UPDATE'.tr,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
