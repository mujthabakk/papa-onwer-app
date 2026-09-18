import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/login_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/analytics_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/appointment_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/calendar_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/product_history_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/profile_menu_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/signup_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/tabs_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/locale_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class LoginController extends GetxController implements GetxService {
  final LoginParser parser;

  String title = 'signin';
  final emailTextEditor = TextEditingController();
  final passwordTextEditor = TextEditingController();
  final mobileNo = TextEditingController();
  RxBool passwordVisible = false.obs;

  int loginVersion = AppConstants.userLogin;
  String smsName = AppConstants.defaultSMSGateway;

  int smsId = 1;
  String otpCode = '';
  String countryCode = '+91';
  LoginController({required this.parser});

  @override
  void onInit() {
    debugPrint('login api call');
    super.onInit();
    smsName = parser.smsName();
    loginVersion = parser.userLogin();
    // Restore saved email/password so user does not retype every time.
    if (parser.rememberLogin()) {
      emailTextEditor.text = parser.getSavedEmail();
      passwordTextEditor.text = parser.getSavedPassword();
    } else {
      emailTextEditor.text = '';
      passwordTextEditor.text = '';
    }
  }

  void saveLanguage(String code) {
    parser.saveLanguage(code);
    if (Get.isRegistered<LocaleController>()) {
      Get.find<LocaleController>().changeLanguage(code, saveRemote: false);
    } else {
      Get.updateLocale(LocaleHelper.toFlutterLocale(code));
    }
  }

  String _apiErrorMessage(Map<String, dynamic> myMap) {
    final error = myMap['error'] ?? myMap['message'];
    if (error != null && error.toString().isNotEmpty) {
      return error.toString();
    }
    return 'Something went wrong'.tr;
  }

  bool _isValidPartnerLogin(Map<String, dynamic> myMap) {
    final user = myMap['user'];
    final token = myMap['token'];
    if (user == null || token == null || token.toString().isEmpty) {
      return false;
    }
    if (user is! Map) {
      return false;
    }
    final type = user['type']?.toString();
    return type != null && type.isNotEmpty && type != 'user';
  }

  double _parseRating(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _completeLogin(Map<String, dynamic> myMap) async {
    final user = Map<String, dynamic>.from(myMap['user'] as Map);
    parser.saveToken(myMap['token'].toString());
    parser.saveInfo(
      user['id'].toString(),
      user['first_name'].toString(),
      user['last_name'].toString(),
      user['cover'].toString(),
      user['email'].toString(),
      user['mobile'].toString(),
      user['type'].toString(),
    );

    // Cache credentials for next open.
    if (emailTextEditor.text.trim().isNotEmpty &&
        passwordTextEditor.text.isNotEmpty) {
      parser.saveCredentials(
        emailTextEditor.text.trim(),
        passwordTextEditor.text,
      );
    } else if (mobileNo.text.trim().isNotEmpty &&
        passwordTextEditor.text.isNotEmpty) {
      parser.saveCredentials(
        mobileNo.text.trim(),
        passwordTextEditor.text,
      );
    }

    if (user['type'].toString() == 'individual') {
      final individualRaw = myMap['individual'];
      final individual = individualRaw is Map
          ? Map<String, dynamic>.from(individualRaw)
          : <String, dynamic>{};
      parser.saveOtherInfo(
        '${user['first_name']} ${user['last_name']}',
        user['cover'].toString(),
        'NA',
        _parseRating(individual['rating']),
        individual['total_rating']?.toString() ?? '0',
      );
    } else {
      final salonRaw = myMap['salon'];
      final salon = salonRaw is Map
          ? Map<String, dynamic>.from(salonRaw)
          : <String, dynamic>{};
      parser.saveOtherInfo(
        salon['name']?.toString() ?? user['first_name'].toString(),
        salon['cover']?.toString() ?? user['cover'].toString(),
        'NA',
        _parseRating(salon['rating']),
        salon['total_rating']?.toString() ?? '0',
      );
    }

    await parser.updateProfile({
      'id': user['id'].toString(),
      'fcm_token': parser.getFcmToken(),
    }, myMap['token'].toString());

    // Use server preferred_country + currencyCode after login (no local country pick).
    if (Get.isRegistered<LocaleController>()) {
      final preferredLang = user['preferred_language']?.toString() ??
          myMap['preferred_language']?.toString() ??
          '';
      final preferredCountry = user['preferred_country']?.toString() ??
          user['country']?.toString() ??
          myMap['preferred_country']?.toString() ??
          '';
      await Get.find<LocaleController>().applyPreferredFromServer(
        language: preferredLang.isNotEmpty ? preferredLang : null,
        country: preferredCountry,
        responseBody: myMap,
      );
    }

    await onNavigate();
  }

  void _closeLoaderIfOpen() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  @override
  void onClose() {
    emailTextEditor.dispose();
    passwordTextEditor.dispose();
    mobileNo.dispose();
    super.onClose();
  }

  void togglePassword() {
    passwordVisible.value = !passwordVisible.value;
    update();
  }

  void onForgot() {
    Get.toNamed(AppRouter.getVerifyRoute());
  }

  void onSignUp() {
    Get.delete<SignUpController>(force: true);
    Get.toNamed(AppRouter.getSignUpRoute());
  }

  void showValidationDialog(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: ThemeProvider.whiteColor,
        title: const Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              'Fields Required',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: ThemeProvider.appColor,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            style: TextButton.styleFrom(
              backgroundColor: ThemeProvider.appColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(color: ThemeProvider.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onLogin() async {
    // if (emailTextEditor.text == '' ||
    //     emailTextEditor.text.isEmpty ||
    //     passwordTextEditor.text == '' ||
    //     passwordTextEditor.text.isEmpty) {
    //   showToast('All fields are required!');
    //   return;
    // }
    // if (!GetUtils.isEmail(emailTextEditor.text)) {
    //   showToast('Email is not valid');
    //   return;
    // }
    if (emailTextEditor.text.isEmpty) {
      showValidationDialog('Email is required'.tr);
      return;
    }
    // Check for valid email format
    if (!GetUtils.isEmail(emailTextEditor.text)) {
      showValidationDialog('Email is not valid'.tr);
      return;
    }

    // Check for password field
    if (passwordTextEditor.text.isEmpty) {
      showValidationDialog('Password is required'.tr);
      return;
    }

    var body = {
      "email": emailTextEditor.text,
      "password": passwordTextEditor.text,
      "type": "partner"
    };

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

    try {
      var response = await parser.onLogin(body);
      _closeLoaderIfOpen();
      if (response.statusCode == 200) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        if (_isValidPartnerLogin(myMap)) {
          await _completeLogin(myMap);
        } else {
          showToast('Access denied'.tr);
        }
      } else if (response.statusCode == 401 || response.statusCode == 500) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        showToast(_apiErrorMessage(myMap));
        update();
      } else {
        ApiChecker.checkApi(response);
        update();
      }
    } catch (e) {
      _closeLoaderIfOpen();
      showToast('Something went wrong'.tr);
      debugPrint('onLogin error: $e');
    }
  }

  Future<void> loginWithPhonePassword() async {
    if (mobileNo.text == '' || passwordTextEditor.text == '') {
      showToast('All fields are required'.tr);
      return;
    }
    update();
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
        barrierDismissible: false);

    var param = {
      'country_code': countryCode,
      'mobile': mobileNo.text,
      'password': passwordTextEditor.text
    };
    Response response = await parser.loginWithPhonePasswordPost(param);
    _closeLoaderIfOpen();
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      if (_isValidPartnerLogin(myMap)) {
        await _completeLogin(myMap);
      } else {
        showToast('Access denied'.tr);
      }
    } else if (response.statusCode == 401 || response.statusCode == 500) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      showToast(_apiErrorMessage(myMap));
      update();
    } else {
      ApiChecker.checkApi(response);
      update();
    }
    update();
  }

  void updateCountryCode(String code) {
    countryCode = code;
    update();
  }

  Future<void> loginWithPhoneOTP() async {
    if (mobileNo.text == '') {
      showToast('Phone Number is required'.tr);
      return;
    }

    if (smsName == '2') {
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
          barrierDismissible: false);

      var param = {'country_code': countryCode, 'mobile': mobileNo.text};

      Response response = await parser.verifyPhoneWithFirebase(param);
      _closeLoaderIfOpen();
      if (response.statusCode == 200) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        if (myMap['data'] == true) {
          FocusManager.instance.primaryFocus?.unfocus();
          Get.toNamed(AppRouter.getFirebaseAuthRoutes(),
              arguments: [countryCode, mobileNo.text, 'login']);
        } else {
          showToast(_apiErrorMessage(myMap));
        }
        update();
      } else if (response.statusCode == 401 || response.statusCode == 500) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        showToast(_apiErrorMessage(myMap));
        update();
      } else {
        ApiChecker.checkApi(response);
        update();
      }
      update();
    } else {
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
          barrierDismissible: false);

      var param = {'country_code': countryCode, 'mobile': mobileNo.text};
      Response response = await parser.verifyPhone(param);
      _closeLoaderIfOpen();
      if (response.statusCode == 200) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        if (myMap['data'] == true) {
          smsId = myMap['otp_id'] ?? smsId;
          FocusManager.instance.primaryFocus?.unfocus();
          openOTPModal(countryCode + mobileNo.text);
        } else {
          showToast(_apiErrorMessage(myMap));
        }
        update();
      } else if (response.statusCode == 401 || response.statusCode == 500) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        showToast(_apiErrorMessage(myMap));
        update();
      } else {
        ApiChecker.checkApi(response);
        update();
      }
      update();
    }
  }

  void openOTPModal(String text) {
    Get.dialog(
      AlertDialog(
        insetPadding: const EdgeInsets.all(0.0),
        title: Text(
          "Verification".tr,
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: Get.width,
          child: Center(
            child: Column(
              children: [
                Text(
                  'We have sent verification code on'.tr,
                  style: const TextStyle(fontSize: 12, fontFamily: 'medium'),
                ),
                Text(
                  text,
                  style: const TextStyle(fontSize: 12, fontFamily: 'medium'),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fieldWidth =
                        ((constraints.maxWidth - 24) / 6).clamp(28.0, 42.0);
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: OtpTextField(
                        numberOfFields: 6,
                        fieldWidth: fieldWidth,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        disabledBorderColor: Colors.grey,
                        enabledBorderColor: Colors.black,
                        borderColor: Colors.black,
                        keyboardType: TextInputType.number,
                        focusedBorderColor: ThemeProvider.appColor,
                        showFieldAsBox: true,
                        onCodeChanged: (String code) {},
                        onSubmit: (String verificationCode) {
                          otpCode = verificationCode;
                          onOtpSubmit();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            height: 45,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 20, bottom: 20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color: Colors.white,
            ),
            child: ElevatedButton(
              onPressed: () {
                if (otpCode.isNotEmpty && otpCode.length >= 6) {
                  onOtpSubmit();
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: ThemeProvider.whiteColor,
                backgroundColor: ThemeProvider.appColor,
                elevation: 0,
              ),
              child: Text(
                'Verify'.tr,
                style: const TextStyle(fontFamily: 'regular', fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onOtpSubmit() async {
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
        barrierDismissible: false);
    var param = {'id': smsId, 'otp': otpCode, 'mobile': mobileNo.text};
    debugPrint('param $param');
    Response response = await parser.verifyOTP(param);
    _closeLoaderIfOpen();
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      if (myMap['success'] == true) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        await loginWithPhoneToken();
      } else {
        showToast(_apiErrorMessage(myMap));
      }
      update();
    } else if (response.statusCode == 401 || response.statusCode == 500) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      showToast(_apiErrorMessage(myMap));
      update();
    } else {
      ApiChecker.checkApi(response);
      update();
    }
  }

  Future<void> loginWithPhoneToken() async {
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
        barrierDismissible: false);
    var param = {'country_code': countryCode, 'mobile': mobileNo.text};
    Response response = await parser.loginWithPhoneToken(param);
    _closeLoaderIfOpen();
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      if (_isValidPartnerLogin(myMap)) {
        await _completeLogin(myMap);
      } else {
        showToast('Access denied'.tr);
      }
    } else if (response.statusCode == 401 || response.statusCode == 500) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      showToast(_apiErrorMessage(myMap));
      update();
    } else {
      ApiChecker.checkApi(response);
      update();
    }
  }

  Future<void> onNavigate() async {
    Get.delete<TabsController>(force: true);
    Get.delete<AppointmentController>(force: true);
    Get.delete<HistoryController>(force: true);
    Get.delete<AnalyticsController>(force: true);
    Get.delete<CalendarsController>(force: true);
    Get.delete<ProfileController>(force: true);
    Get.offNamed(AppRouter.getTabRoute());
  }
}
