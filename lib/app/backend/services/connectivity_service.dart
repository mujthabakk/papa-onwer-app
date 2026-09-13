import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';

/// Watches network status app-wide.
/// When clearly offline, shows Connection Failed only.
class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _offlineDebounce;
  bool _offline = false;
  bool _navigating = false;

  bool get isOffline => _offline;

  Future<ConnectivityService> init() async {
    final current = await _connectivity.checkConnectivity();
    // Only store state on boot — splash decides first navigation.
    _offline = _isDisconnected(current);
    _subscription = _connectivity.onConnectivityChanged
        .listen((results) => _apply(results));
    return this;
  }

  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    // Empty result is inconclusive on some devices — do not treat as offline.
    if (results.isEmpty) return true;
    final online = !_isDisconnected(results);
    _offline = !online;
    return online;
  }

  void _apply(List<ConnectivityResult> results) {
    // Ignore empty/inconclusive updates (common false positive).
    if (results.isEmpty) return;

    final offline = _isDisconnected(results);
    if (offline == _offline) return;
    _offline = offline;

    _offlineDebounce?.cancel();
    if (!offline) return;

    // Debounce so brief flaps don't kick users to /error after a good API call.
    _offlineDebounce = Timer(const Duration(milliseconds: 800), () {
      if (!_offline) return;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_offline) _goToErrorPage();
      });
    });
  }

  bool _isDisconnected(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.every((r) => r == ConnectivityResult.none);
  }

  void _goToErrorPage() {
    if (_navigating) return;
    if (Get.key.currentState == null) return;

    final route = Get.currentRoute;
    // Never interrupt splash while it is loading config / deciding route.
    if (route == AppRouter.errorRoutes ||
        route == AppRouter.splash ||
        route.isEmpty) {
      return;
    }

    _navigating = true;
    try {
      if (Get.isSnackbarOpen == true) {
        Get.closeAllSnackbars();
      }
      Get.offAllNamed(AppRouter.errorRoutes);
    } finally {
      _navigating = false;
    }
  }

  /// Used by Error screen RETRY — reopen splash only if network is back.
  Future<bool> retryIfOnline() async {
    final online = await hasConnection();
    if (!online) {
      _offline = true;
      return false;
    }
    _offline = false;
    Get.offAllNamed(AppRouter.splash);
    return true;
  }

  @override
  void onClose() {
    _offlineDebounce?.cancel();
    _subscription?.cancel();
    super.onClose();
  }
}
