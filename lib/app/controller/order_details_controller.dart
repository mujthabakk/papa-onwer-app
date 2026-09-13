import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/appointments_details_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/payment_options_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/salon_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/stylist_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/order_details_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_loader.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/services/payment_socket_service.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/appointment_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/chat_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/complaints_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/previous_appointments_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsController extends GetxController implements GetxService {
  final OrderDetailsParser parser;
  int id = 0;
  AppointmentDetailsModel _appointmentInfo = AppointmentDetailsModel();
  AppointmentDetailsModel get appointmentInfo => _appointmentInfo;

  String currencySide = AppConstants.defaultCurrencySide;
  String currencySymbol = AppConstants.defaultCurrencySymbol;

  bool apiCalled = false;

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

  StylistModel _stylistInfo = StylistModel();
  StylistModel get stylistInfo => _stylistInfo;
  List<String> selectStatus = ['Ongoing'.tr, 'Completed'.tr, 'Delayed'.tr];
  String orderStatus = '';
  String savedStatus = 'Ongoing'.tr;

  String staffName = 'NA';
  String invoiceURL = '';
  String invoiceURLCommission = '';
  bool appointmentIsPaid = false;
  bool appointmentCanPayNow = false;
  bool appointmentShowPayNow = false;
  bool appointmentShowCod = false;
  String appointmentPaymentStatus = '';
  String appointmentPaymentMessage = '';
  PaymentOptionsModel? paymentOptions;
  OrderDetailsController({required this.parser});
  List<SalonModel> _salonList = <SalonModel>[];
  List<SalonModel> get salonList => _salonList;

  bool get showMarkCashPaid =>
      !appointmentIsPaid &&
      (appointmentShowCod || appointmentCanPayNow || appointmentShowPayNow) &&
      (_appointmentInfo.status == 4 ||
          _appointmentInfo.status == 0 ||
          _appointmentInfo.status == 1 ||
          _appointmentInfo.status == 3 ||
          _appointmentInfo.status == 8);

  @override
  void onInit() {
    super.onInit();
    getBySalonId();
    id = Get.arguments[0];
    currencySide = parser.getCurrencySide();
    currencySymbol = parser.getCurrencySymbol();
    debugPrint('appointment id --> $id');
    invoiceURL =
        '${parser.apiService.appBaseUrl}${AppConstants.getAppointmentInvoice}$id&token=${parser.getToken()}';

    invoiceURLCommission =
        '${parser.apiService.appBaseUrl}${AppConstants.getAppointmentInvoiceCommision}$id&token=${parser.getToken()}';
    getAppointmentDetails();
    _bindPaymentSocket();
    debugPrint(id.toString());
  }

  @override
  void onClose() {
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
    final bookId = payment.bookId != 0 ? payment.bookId : payment.appointmentId;
    if (bookId != id && payment.id != id) return;

    final partnerUid = parser.getUid();
    final salonId = _appointmentInfo.salonId?.toString();
    final freelancerId = _appointmentInfo.freelancerId?.toString();
    // Accept events for this booking; optionally owned by this partner salon.
    final ownedByPartner = partnerUid != null &&
        (salonId == partnerUid ||
            freelancerId == partnerUid ||
            payment.salonId.toString() == partnerUid ||
            payment.freelancerId.toString() == partnerUid);

    debugPrint(
        '💳 Payment completed for book #$bookId owned=$ownedByPartner type=${payment.paymentType}');
    _applyPaymentModel(payment);
    successToast(
      payment.paymentType == 'cash_at_shop'
          ? 'Cash payment received'.tr
          : 'Online payment received'.tr,
    );
    if (Get.isRegistered<AppointmentController>()) {
      Get.find<AppointmentController>().getList();
    }
    update();
  }

  Future<void> getAppointmentDetails() async {
    var response = await parser.getAppointmentDetails({"id": id});
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'];

      _appointmentInfo = AppointmentDetailsModel();
      AppointmentDetailsModel info = AppointmentDetailsModel.fromJson(body);
      _appointmentInfo = info;

      if (parser.getUserType()) {
        getStaffById(_appointmentInfo.specialistId!);
      }
      if (_appointmentInfo.status == 2) {
        orderStatus = 'Rejected'.tr;
      } else if (_appointmentInfo.status == 3) {
        orderStatus = 'Ongoing'.tr;
        savedStatus = 'Ongoing'.tr;
      } else if (_appointmentInfo.status == 4) {
        orderStatus = 'Completed'.tr;
      } else if (_appointmentInfo.status == 5) {
        orderStatus = 'Cancelled'.tr;
      } else if (_appointmentInfo.status == 6) {
        orderStatus = 'Refunded'.tr;
      } else if (_appointmentInfo.status == 7) {
        orderStatus = 'Delayed'.tr;
        savedStatus = 'Delayed'.tr;
      } else if (_appointmentInfo.status == 8) {
        orderStatus = 'Pending Payment'.tr;
      }
      await _refreshPaymentStatus();
      // update();
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future<void> _refreshPaymentStatus() async {
    final customerUid = _appointmentInfo.uid ?? 0;
    if (customerUid <= 0) {
      await _refreshAppointmentStatusFallback();
      return;
    }

    // Preferred: payments/getPaymentOptions {uid, book_id}
    final optionsResponse = await parser.getPaymentOptions(
      customerUid: customerUid,
      bookId: id,
    );
    if (optionsResponse.statusCode == 200 && optionsResponse.body is Map) {
      final body = Map<String, dynamic>.from(optionsResponse.body);
      final data = body['data'];
      if (data is Map) {
        _applyPaymentModel(
            PaymentOptionsModel.fromJson(Map<String, dynamic>.from(data)));
        return;
      }
    }

    // Fallback: payments/getStatus {uid, book_id}
    final payStatusResponse = await parser.getPaymentStatus(
      customerUid: customerUid,
      bookId: id,
    );
    if (payStatusResponse.statusCode == 200 && payStatusResponse.body is Map) {
      final body = Map<String, dynamic>.from(payStatusResponse.body);
      final data = body['data'];
      if (data is Map) {
        _applyPaymentModel(
            PaymentOptionsModel.fromJson(Map<String, dynamic>.from(data)));
        return;
      }
    }

    await _refreshAppointmentStatusFallback();
  }

  Future<void> _refreshAppointmentStatusFallback() async {
    final statusResponse = await parser.getAppointmentStatus({"id": id});
    if (statusResponse.statusCode == 200 && statusResponse.body is Map) {
      final body = Map<String, dynamic>.from(statusResponse.body);
      final data = body['data'];
      if (data is Map) {
        _applyPaymentModel(
            PaymentOptionsModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }
  }

  void _applyPaymentModel(PaymentOptionsModel model) {
    paymentOptions = model;
    appointmentIsPaid = model.isPaid;
    appointmentCanPayNow = model.canPayNow;
    appointmentShowPayNow = model.showPayNow;
    appointmentShowCod = model.showCod;
    appointmentPaymentStatus = model.paymentStatus.isNotEmpty
        ? model.paymentStatus
        : (model.isPaid ? 'paid' : 'unpaid');
    appointmentPaymentMessage = model.message;

    final paidField = _appointmentInfo.paid?.toString().toLowerCase() ?? '';
    if (!appointmentIsPaid &&
        (paidField == '1' || paidField == 'true' || paidField == 'paid')) {
      appointmentIsPaid = true;
      appointmentPaymentStatus = 'paid';
      appointmentShowPayNow = false;
      appointmentShowCod = false;
      appointmentCanPayNow = false;
    }
  }

  void _showLoadingDialog() {
    AppLoader.show();
  }

  void _hideLoadingDialog() {
    AppLoader.hide();
  }

  /// Empty / "null" text → API null
  String? _nullableText(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
    return trimmed;
  }

  void _goBackToHistory() {
    if (Get.isRegistered<AppointmentController>()) {
      final appointmentController = Get.find<AppointmentController>();
      appointmentController.getList();
      if (appointmentController.tabController.index != 1) {
        appointmentController.tabController.animateTo(1);
      }
    }
    onBack();
  }

  Future<void> onCompletionStatus(
    int status,
    int selectedEmployee,
    String selectedDate,
    String textRemarks,
    String textReminderDescription,
  ) async {
    _showLoadingDialog();
    try {
      // 1) Mark appointment Completed (status = 4)
      final updateBody = {"id": id, "status": status};
      final updateResponse = await parser.updateAppointments(updateBody);
      if (updateResponse.statusCode != 200) {
        _hideLoadingDialog();
        ApiChecker.checkApi(updateResponse);
        update();
        return;
      }

      // 2) Confirm status via getStatus
      bool isPaid = false;
      bool canPayNow = false;
      final statusResponse = await parser.getAppointmentStatus({"id": id});
      if (statusResponse.statusCode == 200 && statusResponse.body is Map) {
        final body = Map<String, dynamic>.from(statusResponse.body);
        final data = body['data'];
        if (data is Map) {
          final statusData = Map<String, dynamic>.from(data);
          final currentStatus =
              int.tryParse(statusData['status']?.toString() ?? '') ?? 0;
          _applyPaymentModel(PaymentOptionsModel.fromJson(statusData));
          isPaid = appointmentIsPaid;
          canPayNow = appointmentCanPayNow;
          if (currentStatus != 4) {
            debugPrint(
                'getStatus returned $currentStatus after update to Completed');
          }
        }
      } else {
        debugPrint('getStatus failed: ${statusResponse.statusCode}');
      }

      // Also refresh payment options for COD/Pay Now flags
      final customerUid = _appointmentInfo.uid ?? 0;
      if (customerUid > 0) {
        final optionsResponse = await parser.getPaymentOptions(
          customerUid: customerUid,
          bookId: id,
        );
        if (optionsResponse.statusCode == 200 && optionsResponse.body is Map) {
          final body = Map<String, dynamic>.from(optionsResponse.body);
          final data = body['data'];
          if (data is Map) {
            _applyPaymentModel(
                PaymentOptionsModel.fromJson(Map<String, dynamic>.from(data)));
            isPaid = appointmentIsPaid;
            canPayNow = appointmentCanPayNow;
          }
        }
      }

      // 3) Save completion record
      final completeBody = <String, dynamic>{
        "appointment_id": id,
        "remarks": _nullableText(textRemarks),
        "reminder_date": selectedDate,
        "reminder_description": _nullableText(textReminderDescription),
        "status": 1,
      };
      if (selectedEmployee > 0) {
        completeBody["employee_id"] = selectedEmployee;
      }

      final completeResponse = await parser.completionAppointments(completeBody);
      _hideLoadingDialog();

      if (completeResponse.statusCode == 200) {
        successToast('Appointment completed'.tr);
        if (!isPaid && canPayNow) {
          successToast(
              'Customer will receive Pay Now / COD payment options'.tr);
        }
        _goBackToHistory();
      } else {
        ApiChecker.checkApi(completeResponse);
      }
      update();
    } catch (e) {
      _hideLoadingDialog();
      debugPrint('onCompletionStatus error: $e');
      showToast('Something went wrong'.tr);
      update();
    }
  }

  Future<void> onMarkCashPaid({String remarks = 'Cash received'}) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Mark Cash Paid'.tr),
        content: Text(
          'Are you sure you want to mark this payment as cash received?'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeProvider.appColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Confirm'.tr),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    _showLoadingDialog();
    try {
      final response = await parser.markCashPaid(bookId: id, remarks: remarks);
      _hideLoadingDialog();
      if (response.statusCode == 200) {
        if (response.body is Map) {
          final body = Map<String, dynamic>.from(response.body);
          final data = body['data'];
          if (data is Map) {
            _applyPaymentModel(
                PaymentOptionsModel.fromJson(Map<String, dynamic>.from(data)));
          } else {
            appointmentIsPaid = true;
            appointmentCanPayNow = false;
            appointmentShowPayNow = false;
            appointmentShowCod = false;
            appointmentPaymentStatus = 'paid';
          }
        } else {
          appointmentIsPaid = true;
          appointmentCanPayNow = false;
          appointmentShowPayNow = false;
          appointmentShowCod = false;
          appointmentPaymentStatus = 'paid';
        }
        successToast(
            response.body is Map && response.body['message'] != null
                ? response.body['message'].toString()
                : 'Cash payment marked as received'.tr);
        _goBackToHistory();
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    } catch (e) {
      _hideLoadingDialog();
      debugPrint('onMarkCashPaid error: $e');
      showToast('Something went wrong'.tr);
      update();
    }
  }

  Future<void> getStaffById(int staffId) async {
    var response = await parser.getByID({"id": staffId});
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      _stylistInfo = StylistModel();
      var body = myMap['data'];
      StylistModel info = StylistModel.fromJson(body);
      _stylistInfo = info;
      staffName = "${_stylistInfo.firstName} ${_stylistInfo.lastName}";

      update();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> onUpdateAppointmentStatus(int status) async {
    _showLoadingDialog();
    try {
      var body = {"id": id, "status": status};
      Response response = await parser.updateAppointments(body);
      _hideLoadingDialog();
      if (response.statusCode == 200) {
        successToast('Status Updated'.tr);
        _goBackToHistory();
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    } catch (e) {
      _hideLoadingDialog();
      debugPrint('onUpdateAppointmentStatus error: $e');
      showToast('Something went wrong'.tr);
      update();
    }
  }

  Future<void> getBySalonId() async {
    var response = await parser
        .getBySalonId({"id": parser.sharedPreferencesManager.getString('uid')});
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['data'];
      _salonList = [];
      body.forEach((element) {
        SalonModel salon = SalonModel.fromJson(element);
        _salonList.add(salon);
        debugPrint(response.bodyString.toString());
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> onCompleteDialog(int status) async {
    final textRemarks = TextEditingController();
    final textReminderDescription = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    String selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    int selectedEmployeeId = 0;

    bool isSalonUser = parser.getUserType();
    List<Map<String, dynamic>> employees =
        _salonList.where((salon) => salon.status != 0).map((salon) {
      return {
        'id': salon.id,
        'name': '${salon.firstName} ${salon.lastName}',
      };
    }).toList();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDragHandle(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        if (isSalonUser) ...[
                          _buildSectionTitle('Select Employee'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: employees.map((employee) {
                              return ChoiceChip(
                                label: Text(
                                  employee['name'],
                                  style: TextStyle(
                                    color: selectedEmployeeId == employee['id']
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                selected: selectedEmployeeId == employee['id'],
                                selectedColor: Colors.blueAccent,
                                backgroundColor: Colors.grey[200],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onSelected: (bool selected) {
                                  setState(() {
                                    selectedEmployeeId =
                                        selected ? employee['id'] : 0;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                        _buildSectionTitle('Select Reminder Date'),
                        const SizedBox(height: 10),
                        _buildDatePicker(
                          context: context,
                          selectedDateStr: selectedDateStr,
                          onDatePicked: (pickedDate) {
                            setState(() {
                              selectedDateStr =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: textRemarks,
                          label: 'Remarks',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: textReminderDescription,
                          label: 'Reminder Description',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        _buildActionButtons(
                          isSalonUser: isSalonUser,
                          selectedEmployeeId: selectedEmployeeId,
                          status: status,
                          selectedDateStr: selectedDateStr,
                          textRemarks: textRemarks,
                          textReminderDescription: textReminderDescription,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      barrierColor: Colors.black54,
      isDismissible: true,
      enableDrag: true,
    );
  }

// Drag handle for bottom sheet
  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

// Header for bottom sheet
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Complete Appointment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

// Section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

// Date picker
  Widget _buildDatePicker({
    required BuildContext context,
    required String selectedDateStr,
    required Function(DateTime) onDatePicked,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.blueAccent,
                    onPrimary: Colors.white,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            onDatePicked(pickedDate);
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Date: $selectedDateStr',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

// Text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

// Action buttons
  Widget _buildActionButtons({
    required bool isSalonUser,
    required int selectedEmployeeId,
    required int status,
    required String selectedDateStr,
    required TextEditingController textRemarks,
    required TextEditingController textReminderDescription,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            if (isSalonUser && selectedEmployeeId == 0) {
              Fluttertoast.showToast(
                msg: "Please select an employee",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.redAccent,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return;
            }

            final remarks = textRemarks.text;
            final reminderDescription = textReminderDescription.text;
            final employeeId = selectedEmployeeId;
            final reminderDate = selectedDateStr;

            // Close bottom sheet first so it doesn't steal Get.back() from loading dialog
            Get.back();
            await onCompletionStatus(
              status,
              isSalonUser ? employeeId : 0,
              reminderDate,
              remarks,
              reminderDescription,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
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
    final isBookingDateToday = () {
      try {
        // Parse the appointmentInfo.saveDate (e.g., "June 15, 2025")
        final appointmentDate =
            DateFormat('MMMM d, yyyy').parse(appointmentInfo.saveDate!);
        final today = DateTime.now();

        // Compare only the date parts (ignore time)
        final appointmentDateOnly = DateTime(
            appointmentDate.year, appointmentDate.month, appointmentDate.day);
        final todayOnly = DateTime(today.year, today.month, today.day);

        // Return true if appointment date is today or in the past
        return appointmentDateOnly.isBefore(todayOnly) ||
            appointmentDateOnly.isAtSameMomentAs(todayOnly);
      } catch (e) {
        debugPrint('Error parsing appointment date: $e');
        return false;
      }
    }();

    debugPrint('*************');
    debugPrint(savedStatus);
    debugPrint('Appointment Date: ${appointmentInfo.saveDate}');
    debugPrint('Is booking date today or past: $isBookingDateToday');
    debugPrint('*************');

    int index = 0;
    if (savedStatus == 'Ongoing'.tr) {
      index = 3;
    } else if (savedStatus == 'Completed'.tr) {
      index = 4;
      if (isBookingDateToday) {
        onCompleteDialog(index);
      } else {
        showDateWarningDialog();
      }
    } else {
      index = 7;
    }

    debugPrint('----------');
    debugPrint(index.toString());
    debugPrint('----------');

    if (index != 4) {
      onUpdateAppointmentStatus(index);
    }
  }

  void showDateWarningDialog() {
    HapticFeedback.lightImpact();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Success Icon with Background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 187, 102, 137)!,
                      const Color.fromARGB(255, 160, 67, 67)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 175, 76, 117).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Success Title
              Text(
                'Warning!'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Success Message
              Text(
                'Appointment date has not reached'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),

              // Additional Info
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromARGB(255, 214, 165, 176)!,
                    width: 1,
                  ),
                ),
                child: Text(
                  'You can\'t complete this appointment until booking date is today'
                      .tr,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ThemeProvider.appColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              Row(
                children: [
                  // View Ads Button (Optional)

                  // OK Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 160, 67, 76),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: Colors.green.withOpacity(0.3),
                      ),
                      child: Text(
                        'Done'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
    );
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

  void onAppointmentHistory(int uid, int salonId, int freelancerId) {
    Get.delete<PreviousAppointmentController>(force: true);
    Get.toNamed(AppRouter.getPreviousAppointmentsRoute(),
        arguments: ['direct', uid, salonId, freelancerId]);
  }

  Future<void> makePhoneCall(String phone) async {
    debugPrint(phone);
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    await launchUrl(launchUri);
  }

  Future<void> onMail(String email) async {
    debugPrint(email);
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
              style: const TextStyle(color: ThemeProvider.appColor),
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
              style: const TextStyle(color: ThemeProvider.appColor),
            ),
            onPressed: () {
              Navigator.pop(context);
              Get.delete<ComplaintsController>(force: true);
              Get.toNamed(
                AppRouter.getComplaintRoute(),
                // arguments: [appointmentId, 'appointments']
              );
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
              style: const TextStyle(color: ThemeProvider.appColor),
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
              style: const TextStyle(color: ThemeProvider.appColor),
            ),
            onPressed: () {
              Navigator.pop(context);
              makePhoneCall(phone);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              'Email'.tr,
              style: const TextStyle(color: ThemeProvider.appColor),
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

class PremiumBillSelectionDialog extends StatefulWidget {
  final String customerBillUrl;
  final String commissionBillUrl;

  const PremiumBillSelectionDialog({
    Key? key,
    required this.customerBillUrl,
    required this.commissionBillUrl,
  }) : super(key: key);

  @override
  State<PremiumBillSelectionDialog> createState() =>
      _PremiumBillSelectionDialogState();
}

class _PremiumBillSelectionDialogState extends State<PremiumBillSelectionDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _hoverController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutQuad));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  Future<void> launchInBrowser(String urlInfo) async {
    var url = Uri.parse(urlInfo);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Dialog(
                backgroundColor: Color.fromARGB(255, 33, 32, 32),
                elevation: 0,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'View Bills',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Bill options
                          _buildBillOption(
                            context: context,
                            title: 'Customer Bill',
                            subtitle: 'View your detailed billing information',
                            icon: Icons.account_balance_wallet_rounded,
                            color: const Color(0xFF60A5FA),
                            delay: 100,
                            onTap: () async {
                              Navigator.of(context).pop();
                              try {
                                await launchInBrowser(widget.customerBillUrl);
                              } catch (e) {
                                _showErrorSnackBar(
                                    context, 'Failed to open customer bill');
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildBillOption(
                            context: context,
                            title: 'Commission Bill',
                            subtitle: 'Check your commision bill details',
                            icon: Icons.show_chart_rounded,
                            color: const Color(0xFFF472B6),
                            delay: 200,
                            onTap: () async {
                              Navigator.of(context).pop();
                              try {
                                await launchInBrowser(widget.commissionBillUrl);
                              } catch (e) {
                                _showErrorSnackBar(
                                    context, 'Failed to open commission bill');
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 15),
          child: Opacity(
            opacity: value,
            child: MouseRegion(
              onEnter: (_) => _hoverController.forward(),
              onExit: (_) => _hoverController.reverse(),
              child: GestureDetector(
                onTap: onTap,
                child: AnimatedBuilder(
                  animation: _hoverController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + _hoverController.value * 0.02,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color
                                  .withOpacity(0.2 * _hoverController.value),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                icon,
                                size: 22,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
                child: Text(message, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

void showPremiumBillSelectionDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.7),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const PremiumBillSelectionDialog(
        customerBillUrl: 'https://example.com/customer-bill',
        commissionBillUrl: 'https://example.com/commission-bill',
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutQuad),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutQuad),
          ),
          child: child,
        ),
      );
    },
  );
}
