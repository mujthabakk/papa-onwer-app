import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/language_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/settings_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/support_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/splash_parse.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SplashController extends GetxController implements GetxService {
  final SplashParser parser;

  late LanguageModel _defaultLanguage;
  LanguageModel get defaultLanguage => _defaultLanguage;
  late SettingsModel _settingsModel;
  SettingsModel get settinsModel => _settingsModel;

  late SupportModel _supportModel;
  SupportModel get supportModel => _supportModel;
  SplashController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    _initFirebaseMessaging();
  }

  Future<void> _initFirebaseMessaging() async {
    try {
      for (var i = 0; i < 25 && Firebase.apps.isEmpty; i++) {
        await Future.delayed(const Duration(milliseconds: 80));
      }
      if (Firebase.apps.isEmpty) {
        debugPrint('FCM skipped — Firebase not ready yet');
        return;
      }

      final messaging = FirebaseMessaging.instance;

      // iOS requires notification permission before APNS token is issued.
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('FCM permission: ${settings.authorizationStatus}');

      if (Platform.isIOS) {
        String? apnsToken;
        for (var attempt = 0; attempt < 8; attempt++) {
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null && apnsToken.isNotEmpty) {
            break;
          }
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }

        if (apnsToken == null || apnsToken.isEmpty) {
          debugPrint(
              'APNS token not ready yet — skipping FCM getToken for now');
          // Retry later without blocking splash/login.
          Future.delayed(const Duration(seconds: 5), () async {
            try {
              final laterApns = await messaging.getAPNSToken();
              if (laterApns == null || laterApns.isEmpty) return;
              final token = await messaging.getToken();
              if (token != null && token.isNotEmpty) {
                parser.saveDeviceToken(token);
                debugPrint('FCM token saved after delayed APNS: $token');
              }
            } catch (e) {
              debugPrint('Delayed FCM token fetch failed: $e');
            }
          });
          return;
        }
        debugPrint('APNS token ready');
      }

      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('FCM token: $token');
        parser.saveDeviceToken(token);
      }
    } catch (e) {
      // Never crash app startup because of push token.
      debugPrint('Firebase messaging init failed: $e');
    }
  }

  Future<bool> initSharedData() {
    return parser.initAppSettings();
  }

  Future<bool> getConfigData() async {
    final lang = Get.isRegistered<LocaleController>()
        ? Get.find<LocaleController>().languageCode
        : parser.getLanguagesCode();
    Response response = await parser.getAppSettings(lang: lang);
    print(response.body);
    bool isSuccess = false;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      if (myMap['data'] != null) {
        dynamic body = myMap["data"];
        // Settings alone are enough — support may be missing from API.
        if (body['settings'] != null) {
          SettingsModel appSettingsInfo =
              SettingsModel.fromJson(body['settings']);

          _settingsModel = appSettingsInfo;

          SupportModel supportModelInfo = body['support'] != null
              ? SupportModel.fromJson(body['support'])
              : SupportModel(id: 0, firstName: 'Support', lastName: '');
          _supportModel = supportModelInfo;
          parser.saveBasicInfo(
              appSettingsInfo.currencyCode,
              appSettingsInfo.currencySide,
              appSettingsInfo.currencySymbol,
              appSettingsInfo.smsName,
              appSettingsInfo.userVerifyWith,
              appSettingsInfo.freelancerLogin,
              appSettingsInfo.email,
              appSettingsInfo.name,
              // appSettingsInfo.deliveryType,
              1,
              appSettingsInfo.deliveryCharge,
              appSettingsInfo.tax,
              appSettingsInfo.logo,
              '${supportModelInfo.firstName ?? ''} ${supportModelInfo.lastName ?? ''}'
                  .trim(),
              supportModelInfo.id,
              appSettingsInfo.mobile.toString(),
              appSettingsInfo.allowDistance,
              appSettingsInfo.commissionPercentage);
          isSuccess = true;
        } else {
          isSuccess = false;
        }
      }
    } else {
      print(response.body);
      ApiChecker.checkApi(response);
      isSuccess = false;
    }
    update();
    return isSuccess;
  }

  String getLanguageCode() {
    return parser.getLanguagesCode();
  }
}
