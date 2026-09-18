import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/withdrawal_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/withdrawals_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_names_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class WithdrawalsController extends GetxController implements GetxService {
  final WithdrawalsParser parser;

  final TextEditingController nameTextEditor = TextEditingController();

  bool isLoading = true;

  TextEditingController textControllerTitle = TextEditingController();
  TextEditingController textControllerLink = TextEditingController();

  bool apiCalled = false;

  // int serviceId = 0;
  String action = 'new';

  num totalAmount = 0.0;
  num codCommission = 0.0;
  num codCommissionPercentage = 0.0;

  List<Withdrawal> _withdrawalRequests = <Withdrawal>[];
  List<Withdrawal> get withdrawalRequests => _withdrawalRequests;

  void addWithdrawalRequest(request) {
    _withdrawalRequests.add(request);
  }

  // void withdraw(num amount) {
  //   if (amount <= totalAmount) {
  //     totalAmount -= amount;
  //     addWithdrawalRequest(Withdrawal(
  //       id: int.parse((withdrawalRequests.length + 1).toString()),
  //       withdrawalDate: '2024-06-13',
  //       amount: amount,
  //       status: 'Pending',
  //       uid: int.parse(parser.getUID()),
  //     ));
  //     createWithdrawal(amount);
  //   }
  // }

  void withdraw(num amount) {
    // Total wallet balance = totalAmount + codCommission
    // Available for withdrawal = (totalAmount + codCommission) - codCommission = totalAmount
    num availableForWithdrawal = totalAmount; // This is what user can withdraw

    if (amount <= availableForWithdrawal) {
      // Deduct from totalAmount
      totalAmount -= amount;

      addWithdrawalRequest(Withdrawal(
        id: int.parse((withdrawalRequests.length + 1).toString()),
        withdrawalDate: '2025-07-15',
        amount: amount,
        status: 'Pending',
        uid: int.parse(parser.getUID()),
      ));
      createWithdrawal(amount);
    } else {
      // Show error message
      showToast(
          'Insufficient balance. Available: ${CurrencyHelper.format(availableForWithdrawal)}');
    }
  }

  WithdrawalsController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    getWithdrawalHistoryById();

    // if (Get.arguments[0] == 'edit') {
    //   action = 'edit';
    //   // serviceId = Get.arguments[1] as int;
    // } else {
    //   apiCalled = true;
    // }
  }

  // Future<void> createWithdrawal(int amount) async {
  //   var response = await parser
  //       .postCreateWithdrawals({"uid": parser.getUID(), "amount": amount});
  //   apiCalled = true;
  //   if (response.statusCode == 200) {
  //     bool success = response.body['success'];
  //     if (success) {
  //       successToast('Your Ad is succesfully updated !');
  //     }

  //     isLoading.value = false;
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   update();
  // }

  Future<void> createWithdrawal(num amount) async {
    if (parser.getUID == '' || amount == 0) {
      showToast('Please enter withdrawal amount');
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
      barrierDismissible: false,
    );

    var body = {
      "uid": parser.getUID(),
      "amount": amount,
    };
    apiCalled = true;

    var response = await parser.postCreateWithdrawals(body);
    if (response.statusCode == 200) {
      Get.back();

      debugPrint(response.bodyString);
      // Get.find<ServicesController>().getServices();
      successToast('Withdrawal request succesfully submitted !');
      getWithdrawalHistoryById();
      onBack();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getWithdrawalHistoryById() async {
    var response = await parser.getWithdrawalHistory({"uid": parser.getUID()});
    apiCalled = true;
    debugPrint(response.bodyString);

    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      WithdrawalResponse withdrawalResponse =
          WithdrawalResponse.fromJson(myMap);

      _withdrawalRequests.clear();
      _withdrawalRequests.addAll(withdrawalResponse.withdrawals);

      totalAmount = withdrawalResponse.totalAmount;
      codCommission = withdrawalResponse.codCommission;
      codCommissionPercentage = withdrawalResponse.codCommissionPercentage;

      // Debug the values
      debugPrint('API totalAmount: $totalAmount');
      debugPrint('API CODCommission: $codCommission');
      debugPrint('API CODCommissionPercentage: $codCommissionPercentage');
      debugPrint('Total Wallet Balance: ${totalAmount + codCommission}');
      debugPrint('Available for Withdrawal: $totalAmount');

      isLoading = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getWithdrawalHistoryByIdDate(
      String startDate, String endDate) async {
    var response = await parser.getWithdrawalHistoryDate(
        {"uid": parser.getUID(), "start_date": startDate, "end_date": endDate});
    apiCalled = true;

    debugPrint(response.bodyString);

    if (response.statusCode == 200) {
      // Directly use the response body as it is already a Map<String, dynamic>
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);

      WithdrawalResponse withdrawalResponse =
          WithdrawalResponse.fromJson(myMap);

      _withdrawalRequests.clear();

      _withdrawalRequests.addAll(withdrawalResponse.withdrawals);

      //totalAmount = withdrawalResponse.totalAmount;
      // codCommission = withdrawalResponse.codCommission;

      // Map each item in the list to a Withdrawal object and add to the list
      // body.forEach((data) {
      //   _withdrawalRequests.add(Withdrawal.fromJson(data));
      // });

      // Update the loading status
      isLoading = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  void onServiceCategories() {
    Get.delete<ServicesCategoriesController>(force: true);
    Get.toNamed(AppRouter.getServicesCategoriesRoute());
    update();
  }

  void onServiceNames(String catId) {
    Get.delete<ServicesNamesController>(force: true);
    Get.toNamed(AppRouter.getServicesNamesRoute(), arguments: catId);
    update();
  }
}
