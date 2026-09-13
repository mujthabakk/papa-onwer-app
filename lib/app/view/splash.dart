import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/services/connectivity_service.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/splash_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/env.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/view/widgets/locale_picker.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<SplashController>().initSharedData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _routing();
    });
  }

  Future<void> _routing() async {
    if (Get.isRegistered<ConnectivityService>()) {
      final online = await Get.find<ConnectivityService>().hasConnection();
      if (!online) {
        Get.offAllNamed(AppRouter.getErrorRoutes());
        return;
      }
    }

    final splash = Get.find<SplashController>();
    final locale = Get.isRegistered<LocaleController>()
        ? Get.find<LocaleController>()
        : null;

    final results = await Future.wait<bool>([
      splash.getConfigData(),
      () async {
        if (locale == null) return true;
        await locale.bootstrap(applyLocale: false);
        return true;
      }(),
    ]);
    if (!mounted) return;

    final isSuccess = results.first;
    locale?.reapplyPickerCurrency();

    final loggedIn = splash.parser.haveLoggedIn();

    // Config API worked → never send user to Connection Failed.
    if (isSuccess) {
      if (loggedIn) {
        Get.offNamed(AppRouter.getTabRoute());
      } else {
        Get.offNamed(AppRouter.getInitialRoute());
      }
      return;
    }

    // Config failed: only show Connection Failed when truly offline.
    if (Get.isRegistered<ConnectivityService>()) {
      final online = await Get.find<ConnectivityService>().hasConnection();
      if (!online) {
        Get.offAllNamed(AppRouter.getErrorRoutes());
        return;
      }
    }

    if (loggedIn) {
      Get.offNamed(AppRouter.getTabRoute());
      return;
    }

    Get.offNamed(AppRouter.getInitialRoute());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (value) {
      return Scaffold(
        body: Stack(alignment: AlignmentDirectional.center, children: [
          const Image(
            image: AssetImage('assets/images/splash.png'),
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          const Positioned(
            top: 180,
            child: Center(
              child: Text(
                Environments.appName,
                style: TextStyle(
                    color: ThemeProvider.whiteColor, fontFamily: 'bold'),
              ),
            ),
          ),
          const Positioned(
            top: 48,
            right: 12,
            child: SafeArea(
              child: LocalePickerBar(
                foregroundColor: Colors.white,
                compact: true,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            child: Center(
              child: Text(
                'Developed By '.tr + Environments.companyName,
                style: const TextStyle(
                    color: ThemeProvider.whiteColor, fontFamily: 'bold'),
              ),
            ),
          ),
        ]),
      );
    });
  }
}
