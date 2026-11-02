import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/product_order_details_model.dart';
import 'package:ultimate_salon_owner_flutter/app/product/api/product_order_details_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/chat_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/complaints_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/product_history_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/order_details_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductOrderDetailsController extends GetxController
    implements GetxService {
  final ProductOrderDetailsParse parser;

  int id = 0;
  ProductOrderDetailsModel _productOrderDetails = ProductOrderDetailsModel();
  ProductOrderDetailsModel get productOrderDetails => _productOrderDetails;

  String currencySide = AppConstants.defaultCurrencySide;
  String currencySymbol = AppConstants.defaultCurrencySymbol;

  bool apiCalled = false;
  bool trackingLoading = false;

  static const List<String> statusLabels = [
    'Created',
    'Accepted',
    'Rejected',
    'Ongoing',
    'Completed',
    'Cancelled',
    'Refunded',
    'Delayed',
    'Payment is Pending',
  ];

  List<String> paymentName = [
    'NA'.tr,
    'COD'.tr,
    'Stripe'.tr,
    'PayPal'.tr,
    'Paytm'.tr,
    'Razorpay'.tr,
    'Instamojo'.tr,
    'Paystack'.tr,
    'Flutterwave'.tr
  ];

  /// Seller can move accepted/ongoing/delayed orders to these statuses.
  List<String> selectStatus = [
    'Ongoing'.tr,
    'Completed'.tr,
    'Delayed'.tr,
  ];
  String orderStatus = '';
  String savedStatus = 'Ongoing'.tr;
  String invoiceURL = '';
  String invoiceURLCommission = '';
  ProductOrderDetailsController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    id = Get.arguments[0];
    currencySide = parser.getCurrencySide();
    currencySymbol = parser.getCurrencySymbol();
    invoiceURL =
        '${parser.apiService.appBaseUrl}${AppConstants.getProductOrderInvoice}$id&token=${parser.getToken()}';
    invoiceURLCommission =
        '${parser.apiService.appBaseUrl}${AppConstants.getProductInvoiceCommision}$id&token=${parser.getToken()}';
    getAppointmentDetails();
  }

  String labelForStatus(int? status) {
    if (status == null || status < 0 || status >= statusLabels.length) {
      return 'Unknown'.tr;
    }
    return statusLabels[status].tr;
  }

  void _syncStatusLabels() {
    final status = _productOrderDetails.status ?? 0;
    orderStatus = (_productOrderDetails.statusLabel?.isNotEmpty == true)
        ? _productOrderDetails.statusLabel!
        : labelForStatus(status);
    if (status == 3) {
      savedStatus = 'Ongoing'.tr;
    } else if (status == 4) {
      savedStatus = 'Completed'.tr;
    } else if (status == 7) {
      savedStatus = 'Delayed'.tr;
    } else if (status == 1) {
      savedStatus = 'Ongoing'.tr;
    }
  }

  Future<void> getAppointmentDetails() async {
    var loaded = false;
    try {
      final response =
          await parser.getOrderDetails({"id": id, "order_id": id});
      if (response.statusCode == 200 && response.body is Map) {
        final myMap = Map<String, dynamic>.from(response.body);
        dynamic body = myMap['data'] ?? myMap;
        // Some PDF responses nest the order under data.order / data.info.
        if (body is Map &&
            body['id'] == null &&
            body['order_id'] == null) {
          body = body['order'] ?? body['info'] ?? body;
        }
        if (body is Map) {
          _productOrderDetails = ProductOrderDetailsModel.fromJson(
              Map<String, dynamic>.from(body));
          _syncStatusLabels();
          loaded = true;
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint('product order details error: $e');
      showToast('Failed to load order details');
    } finally {
      apiCalled = true;
      update();
    }
    // Load tracking after UI is visible so a slow tracking API cannot block.
    if (loaded) {
      loadTracking();
    }
  }

  Future<void> loadTracking() async {
    trackingLoading = true;
    update();
    try {
      final response =
          await parser.getTracking({"id": id, "order_id": id});
      if (response.statusCode == 200 && response.body is Map) {
        final body = Map<String, dynamic>.from(response.body);
        final data = body['data'];
        if (data is Map) {
          _productOrderDetails
              .applyTrackingPayload(Map<String, dynamic>.from(data));
          _syncStatusLabels();
        }
      }
    } catch (_) {
      // Tracking optional — ignore failures.
    } finally {
      trackingLoading = false;
      update();
    }
  }

  Future<void> onUpdateAppointmentStatus(int status, {String? note}) async {
    Get.dialog(
        SimpleDialog(
          children: [
            Row(
              children: [
                const SizedBox(width: 30),
                const CircularProgressIndicator(color: ThemeProvider.appColor),
                const SizedBox(width: 30),
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
    final body = {
      "id": id,
      "order_id": id,
      "status": status,
      if (note != null && note.trim().isNotEmpty) "note": note.trim(),
    };
    Response response = await parser.updateStatus(body);
    if (response.statusCode != 200) {
      // Fallback for older backends.
      response = await parser.updateProductOrder(body);
    }
    Get.back();
    if (response.statusCode == 200) {
      successToast('Status Updated'.tr);
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().getList();
      }
      await getAppointmentDetails();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  void onSelectStatus(String choice) {
    savedStatus = choice;
    update();
  }

  void updateStatus() {
    int index = 3;
    if (savedStatus == 'Ongoing'.tr) {
      index = 3;
    } else if (savedStatus == 'Completed'.tr) {
      index = 4;
    } else if (savedStatus == 'Delayed'.tr) {
      index = 7;
    }
    onUpdateAppointmentStatus(index);
  }

  bool get canAddTracking {
    final status = _productOrderDetails.status ?? -1;
    return status == 1 || status == 3 || status == 7;
  }

  Future<void> openTrackingSheet() async {
    final courierCtrl = TextEditingController(
        text: _productOrderDetails.courier ?? '');
    final awbCtrl = TextEditingController(
        text: _productOrderDetails.trackingNumber ?? '');
    final urlCtrl = TextEditingController(
        text: _productOrderDetails.trackingUrl ?? '');
    final etaCtrl = TextEditingController(
        text: _productOrderDetails.estimatedDelivery ?? '');
    final noteCtrl = TextEditingController();
    var markShipped = (_productOrderDetails.status ?? 0) < 3;

    await Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: StatefulBuilder(
            builder: (context, setModal) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ship / Tracking'.tr,
                      style: const TextStyle(
                        fontFamily: 'bold',
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: courierCtrl,
                      decoration: InputDecoration(
                        labelText: 'Courier'.tr,
                        hintText: 'BlueDart',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: awbCtrl,
                      decoration: InputDecoration(
                        labelText: 'Tracking number / AWB'.tr,
                        hintText: 'BD123456',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: urlCtrl,
                      decoration: InputDecoration(
                        labelText: 'Tracking URL'.tr,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: etaCtrl,
                      readOnly: true,
                      onTap: () async {
                        final initial = DateTime.tryParse(etaCtrl.text.trim()) ??
                            DateTime.now().add(const Duration(days: 3));
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initial.isBefore(DateTime.now())
                              ? DateTime.now()
                              : initial,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365 * 2)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme:
                                    Theme.of(context).colorScheme.copyWith(
                                          primary: ThemeProvider.appColor,
                                        ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          final y = picked.year.toString();
                          final m = picked.month.toString().padLeft(2, '0');
                          final d = picked.day.toString().padLeft(2, '0');
                          setModal(() => etaCtrl.text = '$y-$m-$d');
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Estimated delivery'.tr,
                        hintText: 'Select date'.tr,
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteCtrl,
                      decoration: InputDecoration(
                        labelText: 'Note'.tr,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Mark as shipped (Ongoing)'.tr),
                      value: markShipped,
                      activeThumbColor: ThemeProvider.golden,
                      onChanged: (v) => setModal(() => markShipped = v),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await submitTracking(
                            courier: courierCtrl.text,
                            trackingNumber: awbCtrl.text,
                            trackingUrl: urlCtrl.text,
                            estimatedDelivery: etaCtrl.text,
                            note: noteCtrl.text,
                            markShipped: markShipped,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeProvider.appColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Save Tracking'.tr,
                            style: const TextStyle(fontFamily: 'bold')),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> submitTracking({
    required String courier,
    required String trackingNumber,
    required String trackingUrl,
    required String estimatedDelivery,
    required String note,
    required bool markShipped,
  }) async {
    if (trackingNumber.trim().isEmpty && courier.trim().isEmpty) {
      showToast('Enter courier or tracking number');
      return;
    }
    Get.dialog(
      SimpleDialog(
        children: [
          Row(
            children: [
              const SizedBox(width: 30),
              const CircularProgressIndicator(color: ThemeProvider.appColor),
              const SizedBox(width: 30),
              Text('Please wait'.tr,
                  style: const TextStyle(fontFamily: 'bold')),
            ],
          )
        ],
      ),
      barrierDismissible: false,
    );
    final body = {
      "id": id,
      "order_id": id,
      "courier": courier.trim(),
      "tracking_number": trackingNumber.trim(),
      "awb": trackingNumber.trim(),
      "tracking_url": trackingUrl.trim(),
      if (estimatedDelivery.trim().isNotEmpty)
        "estimated_delivery": estimatedDelivery.trim(),
      "mark_shipped": markShipped,
      if (note.trim().isNotEmpty) "note": note.trim(),
    };
    final response = await parser.updateTracking(body);
    Get.back();
    if (response.statusCode == 200) {
      successToast('Tracking Updated'.tr);
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().getList();
      }
      await getAppointmentDetails();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> launchInBrowser(String urlInfo) async {
    var url = Uri.parse(urlInfo);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw '${'Could not launch'.tr} $url';
    }
  }

  void showBillSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PremiumBillSelectionDialog(
          customerBillUrl: invoiceURL,
          commissionBillUrl: invoiceURLCommission,
        );
      },
    );
  }

  Future<void> makePhoneCall(String phone) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    await launchUrl(launchUri);
  }

  Future<void> onMail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(launchUri);
  }

  void openHelpModal() {
    var context = Get.context as BuildContext;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Choose'.tr),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Text(
              'Chat'.tr,
              style: const TextStyle(
                  fontFamily: 'regular', color: ThemeProvider.appColor),
            ),
            onPressed: () {
              Navigator.pop(context);
              Get.delete<ChatController>(force: true);
              Get.toNamed(AppRouter.getChatRoute(), arguments: [
                parser.getAdminId().toString(),
                parser.getAdminName()
              ]);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              'Complaints'.tr,
              style: const TextStyle(
                  fontFamily: 'regular', color: ThemeProvider.appColor),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Get.delete<ComplaintsController>(force: true);
              Get.toNamed(AppRouter.getComplaintRoute());
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              'Cancel'.tr,
              style: const TextStyle(fontFamily: 'bold', color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void onContactInfo(String name, String phone, String email, String uid) {
    var context = Get.context as BuildContext;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Choose'.tr),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Text(
              'Chat'.tr,
              style: const TextStyle(
                  fontFamily: 'regular', color: ThemeProvider.appColor),
            ),
            onPressed: () {
              Navigator.pop(context);
              Get.delete<ChatController>(force: true);
              Get.toNamed(AppRouter.getChatRoute(), arguments: [uid, name]);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              'Call'.tr,
              style: const TextStyle(
                  fontFamily: 'regular', color: ThemeProvider.appColor),
            ),
            onPressed: () {
              Navigator.pop(context);
              makePhoneCall(phone);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              'Email'.tr,
              style: const TextStyle(
                  fontFamily: 'regular', color: ThemeProvider.appColor),
            ),
            onPressed: () {
              Navigator.pop(context);
              onMail(email);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              'Cancel'.tr,
              style: const TextStyle(fontFamily: 'bold', color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
