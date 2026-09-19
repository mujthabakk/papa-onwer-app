import 'dart:async';
import 'dart:io';

import 'package:adapty_flutter/adapty_flutter.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/init.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_translations.dart';
import 'package:ultimate_salon_owner_flutter/app/util/locale_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

bool _isAdaptyActivated = false;
final adapty = Adapty();

Future<void> initializeAdapty() async {
  try {
    debugPrint('#Adapty initialize');

    if (!_isAdaptyActivated) {
      final config = AdaptyConfiguration(
        apiKey: 'public_live_zDiy07Tf.MPqSaEeJcI0reeErb5Nf',
      );

      await adapty.setLogLevel(
          kDebugMode ? AdaptyLogLevel.verbose : AdaptyLogLevel.info);

      await adapty.activate(configuration: config);

      _isAdaptyActivated = true;

      debugPrint('Adapty activated successfully');
    } else {
      debugPrint('Adapty already activated, skipping activation');
    }
  } catch (e) {
    debugPrint('#Adapty initialize error: $e');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppStarter());
}

class AppStarter extends StatefulWidget {
  const AppStarter({Key? key}) : super(key: key);

  @override
  State<AppStarter> createState() => _AppStarterState();
}

class _AppStarterState extends State<AppStarter> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      await MainBinding().dependencies();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      unawaited(_initBackground());
    } catch (e) {
      debugPrint('Initialization failed: $e');
    }
  }

  Future<void> _initBackground() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
          name: 'papabear-partner-app',
        );
      }
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }
    unawaited(initializeAdapty());
    unawaited(requestTrackingPermission());
  }

  Future<void> requestTrackingPermission() async {
    if (!Platform.isIOS) {
      return;
    }

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        final newStatus =
            await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('ATT Permission Status: $newStatus');
      } else {
        debugPrint('ATT Permission already determined: $status');
      }
    } catch (e) {
      debugPrint('Error requesting tracking permission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: ThemeProvider.appColor,
          body: SizedBox.expand(
            child: Image(
              image: AssetImage('assets/images/splash.png'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
      );
    }
    return const MyApp();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = Get.isRegistered<LocaleController>()
        ? Get.find<LocaleController>().languageCode
        : 'en';
    return GetMaterialApp(
      title: AppConstants.appName,
      color: ThemeProvider.appColor,
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      initialRoute: AppRouter.splash,
      getPages: AppRouter.routes,
      translations: AppTranslations(),
      fallbackLocale: const Locale('en', 'US'),
      locale: LocaleHelper.toFlutterLocale(lang),
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 220),
      smartManagement: SmartManagement.onlyBuilder,
      routingCallback: (routing) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      },
      builder: EasyLoading.init(),
    );
  }
}
