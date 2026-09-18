import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/ads_managing_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:intl/intl.dart';

import '../backend/models/ad_managing_model.dart';

class AdsManageScreen extends StatefulWidget {
  const AdsManageScreen({Key? key}) : super(key: key);
  @override
  State<AdsManageScreen> createState() => _AdsManageScreenState();
}

class _AdsManageScreenState extends State<AdsManageScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdsManagingController>(builder: (value) {
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
            title: Text('Manage Advertisements'.tr,
              style: ThemeProvider.titleStyle,
            ),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.add_circle_outline),
            //     onPressed: () {
            //       // Add new ad functionality
            //       _showCreateAdDialog(context, value);
            //     },
            //   ),
            // ],
          ),
          body: value.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : value.adListings.isEmpty
                  ? _buildEmptyState()
                  : _buildAdsList(value),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.ad_units_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text('No advertisements yet'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          // Text(
          //   'Tap the + button to create your first ad',
          //   style: TextStyle(
          //     fontSize: 14,
          //     color: Colors.grey[500],
          //   ),
          // ),
          const SizedBox(height: 24),
          // ElevatedButton.icon(
          //   icon: const Icon(Icons.add),
          //   label: Text('Create New Ad'.tr),
          //   style: ElevatedButton.styleFrom(
          //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(30),
          //     ),
          //   ),
          //   onPressed: () {
          //   //  _showCreateAdDialog(context, Get.find<AdsManagingController>());
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildAdsList(AdsManagingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        itemCount: controller.adListings.length,
        itemBuilder: (context, index) {
          AdsManagingModel ad = controller.adListings[index];
          return _buildAdCard(ad, controller, index);
        },
      ),
    );
  }

  Widget _buildAdCard(
      AdsManagingModel ad, AdsManagingController controller, int index) {
    // Calculate expiry status
    final now = DateTime.now();
    final expiryDate = ad.to;
    final isExpired = expiryDate != null && expiryDate.isBefore(now);
    final isExpiringSoon = expiryDate != null &&
        expiryDate.isAfter(now) &&
        expiryDate.difference(now).inDays < 7;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: AppNetImage(
                    path: ad.cover.value,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 60, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Status Badge
                if (isExpired || isExpiringSoon)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isExpired ? Colors.red : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isExpired ? 'Expired' : 'Expiring Soon',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                // Position Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ad.position == 0
                          ? Colors.blue[700]
                          : Colors.purple[600],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ad.position == 0 ? 'Home' : 'Search',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ad.title.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          CurrencyHelper.format(ad.price),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Expires: ${expiryDate != null ? DateFormat('dd MMM, yyyy').format(expiryDate) : 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isExpired ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.edit),
                          label: Text('Edit'.tr),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color.fromARGB(255, 8, 8, 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                  color: const Color.fromARGB(255, 0, 0, 0)!),
                            ),
                          ),
                          onPressed: () {
                            _showEditDialog(context, ad, controller, index);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.delete_outline),
                          label: Text('Delete'.tr),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                          onPressed: () {
                            _showDeleteConfirmationDialog(
                                context, ad, controller);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, AdsManagingModel ad,
      AdsManagingController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Delete Advertisement".tr),
          content: Text("Are you sure you want to delete this ad? This action cannot be undone.".tr),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel".tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  Text("Delete".tr, style: TextStyle(color: Colors.white)),
              onPressed: () {
                controller.deleteAds(ad.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, AdsManagingModel ad,
      AdsManagingController controller, int position) {
    TextEditingController titleController =
        TextEditingController(text: ad.title.value);
    TextEditingController priceController =
        TextEditingController(text: ad.price.toString());
    TextEditingController linkController =
        TextEditingController(text: ad.link ?? '');

    int selectedPosition = ad.position ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Edit Advertisement'.tr),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Uncomment and use the price TextField if needed
                  // TextField(
                  //   controller: priceController,
                  //   keyboardType: TextInputType.number,
                  //   decoration: InputDecoration(
                  //     labelText: 'Price (INR)'.tr,
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     prefixIcon: const Icon(Icons.currency_rupee),
                  //   ),
                  // ),
                  // const SizedBox(height: 16),
                  // Uncomment and use the position selection if needed
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Text('Position'.tr,
                  //         style: TextStyle(
                  //             fontSize: 16, fontWeight: FontWeight.w500)),
                  //     const SizedBox(height: 8),
                  //     Row(
                  //       children: [
                  //         Expanded(
                  //           child: GestureDetector(
                  //             onTap: () {
                  //               setState(() {
                  //                 selectedPosition = 0;
                  //               });
                  //             },
                  //             child: Container(
                  //               padding: const EdgeInsets.all(12),
                  //               decoration: BoxDecoration(
                  //                 color: selectedPosition == 0
                  //                     ? Colors.blue.withOpacity(0.1)
                  //                     : Colors.grey.withOpacity(0.1),
                  //                 borderRadius: BorderRadius.circular(12),
                  //                 border: Border.all(
                  //                   color: selectedPosition == 0
                  //                       ? Colors.blue
                  //                       : Colors.grey.withOpacity(0.5),
                  //                 ),
                  //               ),
                  //               child: Column(
                  //                 children: [
                  //                   Icon(
                  //                     Icons.home,
                  //                     color: selectedPosition == 0
                  //                         ? Colors.blue
                  //                         : Colors.grey,
                  //                   ),
                  //                   const SizedBox(height: 4),
                  //                   Text('Home'.tr),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //         const SizedBox(width: 12),
                  //         Expanded(
                  //           child: GestureDetector(
                  //             onTap: () {
                  //               setState(() {
                  //                 selectedPosition = 1;
                  //               });
                  //             },
                  //             child: Container(
                  //               padding: const EdgeInsets.all(12),
                  //               decoration: BoxDecoration(
                  //                 color: selectedPosition == 1
                  //                     ? Colors.purple.withOpacity(0.1)
                  //                     : Colors.grey.withOpacity(0.1),
                  //                 borderRadius: BorderRadius.circular(12),
                  //                 border: Border.all(
                  //                   color: selectedPosition == 1
                  //                       ? Colors.purple
                  //                       : Colors.grey.withOpacity(0.5),
                  //                 ),
                  //               ),
                  //               child: Column(
                  //                 children: [
                  //                   Icon(
                  //                     Icons.search,
                  //                     color: selectedPosition == 1
                  //                         ? Colors.purple
                  //                         : Colors.grey,
                  //                   ),
                  //                   const SizedBox(height: 4),
                  //                   Text('Search'.tr),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  if (ad.link != null && ad.link!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: linkController,
                      decoration: InputDecoration(
                        labelText: 'Link'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.link),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text('Advertisement Image'.tr,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  GestureDetector(
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
                                controller.selectFromGallery(
                                    'camera', position);
                              },
                              child: Text('Camera'.tr),
                            ),
                            CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(context);
                                controller.selectFromGallery(
                                    'gallery', position);
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
                    child: Obx(() {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AppNetImage(
                                path: ad.cover.value,
                                errorAsset: 'assets/images/notfound.png',
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.edit, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'.tr),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ad.title = titleController.text.obs;
                  ad.cover = ad.cover.value.toString().obs;
                  ad.position = selectedPosition;
                  ad.link = linkController.text.isNotEmpty
                      ? linkController.text
                      : null;

                  // Update with new price if price field is enabled
                  try {
                    double newPrice = double.parse(priceController.text);
                    ad.price = newPrice;
                  } catch (e) {
                    // Fallback if price parsing fails
                  }

                  if (ad.link != null && ad.link!.isNotEmpty) {
                    controller.updateAdListing(
                      ad.id!,
                      titleController.text,
                      ad.cover.value,
                      ad.link,
                    );
                  } else {
                    controller.updateAdListing(
                      ad.id!,
                      titleController.text,
                      ad.cover.value,
                      '',
                    );
                  }

                  Navigator.pop(context);
                },
                child: Text('Save Changes'.tr),
              ),
            ],
          );
        });
      },
    );
  }

  // void _showCreateAdDialog(
  //     BuildContext context, AdsManagingController controller) {
  //   TextEditingController titleController = TextEditingController();
  //   TextEditingController priceController = TextEditingController();
  //   int selectedPosition = 0;

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(builder: (context, setState) {
  //         return AlertDialog(
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //           title: Text('Create New Advertisement'.tr),
  //           content: SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextField(
  //                   controller: titleController,
  //                   decoration: InputDecoration(
  //                     labelText: 'Title'.tr,
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     prefixIcon: const Icon(Icons.title),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 TextField(
  //                   controller: priceController,
  //                   keyboardType: TextInputType.number,
  //                   decoration: InputDecoration(
  //                     labelText: 'Price (INR)'.tr,
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     prefixIcon: const Icon(Icons.currency_rupee),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text('Position'.tr,
  //                         style: TextStyle(
  //                             fontSize: 16, fontWeight: FontWeight.w500)),
  //                     const SizedBox(height: 8),
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: GestureDetector(
  //                             onTap: () {
  //                               setState(() {
  //                                 selectedPosition = 0;
  //                               });
  //                             },
  //                             child: Container(
  //                               padding: const EdgeInsets.all(12),
  //                               decoration: BoxDecoration(
  //                                 color: selectedPosition == 0
  //                                     ? Colors.blue.withOpacity(0.1)
  //                                     : Colors.grey.withOpacity(0.1),
  //                                 borderRadius: BorderRadius.circular(12),
  //                                 border: Border.all(
  //                                   color: selectedPosition == 0
  //                                       ? Colors.blue
  //                                       : Colors.grey.withOpacity(0.5),
  //                                 ),
  //                               ),
  //                               child: Column(
  //                                 children: [
  //                                   Icon(
  //                                     Icons.home,
  //                                     color: selectedPosition == 0
  //                                         ? Colors.blue
  //                                         : Colors.grey,
  //                                   ),
  //                                   const SizedBox(height: 4),
  //                                   Text('Home'.tr),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 12),
  //                         Expanded(
  //                           child: GestureDetector(
  //                             onTap: () {
  //                               setState(() {
  //                                 selectedPosition = 1;
  //                               });
  //                             },
  //                             child: Container(
  //                               padding: const EdgeInsets.all(12),
  //                               decoration: BoxDecoration(
  //                                 color: selectedPosition == 1
  //                                     ? Colors.purple.withOpacity(0.1)
  //                                     : Colors.grey.withOpacity(0.1),
  //                                 borderRadius: BorderRadius.circular(12),
  //                                 border: Border.all(
  //                                   color: selectedPosition == 1
  //                                       ? Colors.purple
  //                                       : Colors.grey.withOpacity(0.5),
  //                                 ),
  //                               ),
  //                               child: Column(
  //                                 children: [
  //                                   Icon(
  //                                     Icons.search,
  //                                     color: selectedPosition == 1
  //                                         ? Colors.purple
  //                                         : Colors.grey,
  //                                   ),
  //                                   const SizedBox(height: 4),
  //                                   Text('Search'.tr),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 20),
  //                 Text('Advertisement Image'.tr,
  //                     style:
  //                         TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
  //                 const SizedBox(height: 12),
  //                 GestureDetector(
  //                   onTap: () {
  //                     showCupertinoModalPopup<void>(
  //                       context: context,
  //                       builder: (BuildContext context) => CupertinoActionSheet(
  //                         title: Text('Choose From'.tr),
  //                         actions: <CupertinoActionSheetAction>[
  //                           CupertinoActionSheetAction(
  //                             isDefaultAction: true,
  //                             onPressed: () {
  //                               Navigator.pop(context);
  //                               controller.selectFromGallery(
  //                                   'camera', -1); // -1 for new ad
  //                             },
  //                             child: Text('Camera'.tr),
  //                           ),
  //                           CupertinoActionSheetAction(
  //                             onPressed: () {
  //                               Navigator.pop(context);
  //                               controller.selectFromGallery(
  //                                   'gallery', -1); // -1 for new ad
  //                             },
  //                             child: Text('Gallery'.tr),
  //                           ),
  //                           CupertinoActionSheetAction(
  //                             isDestructiveAction: true,
  //                             onPressed: () {
  //                               Navigator.pop(context);
  //                             },
  //                             child: Text('Cancel'.tr),
  //                           )
  //                         ],
  //                       ),
  //                     );
  //                   },
  //                   child: Container(
  //                     height: 180,
  //                     width: double.infinity,
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey[100],
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(color: Colors.grey),
  //                     ),
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Icon(
  //                           Icons.add_photo_alternate,
  //                           size: 48,
  //                           color: Colors.grey[500],
  //                         ),
  //                         const SizedBox(height: 12),
  //                         Text(
  //                           'Tap to add an image',
  //                           style: TextStyle(
  //                             color: Colors.grey[600],
  //                             fontSize: 16,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: Text('Cancel'.tr),
  //             ),
  //             ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //               onPressed: () {
  //                 // Call create ad function in controller
  //                 // controller.createNewAd(titleController.text, priceController.text, selectedPosition);
  //                 Navigator.pop(context);

  //                 // Show snackbar confirmation
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text('New advertisement created successfully'.tr),
  //                     behavior: SnackBarBehavior.floating,
  //                   ),
  //                 );
  //               },
  //               child: Text('Create Ad'.tr),
  //             ),
  //           ],
  //         );
  //       });
  //     },
  //   );
  // }
}
