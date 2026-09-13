import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/payment_options_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/payment_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';

typedef PaymentCompletedCallback = void Function(PaymentOptionsModel payment);

class PaymentSocketService extends GetxService {
  final PaymentParser parser;
  final SharedPreferencesManager prefs;

  PaymentSocketService({required this.parser, required this.prefs});

  PusherChannelsFlutter? _pusher;
  bool _connecting = false;
  bool _connected = false;
  String _channel = 'payment-status';
  String _event = 'payment-completed';
  final List<PaymentCompletedCallback> _listeners = [];

  bool get isConnected => _connected;

  void addListener(PaymentCompletedCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(PaymentCompletedCallback listener) {
    _listeners.remove(listener);
  }

  Future<void> ensureConnected() async {
    if (!prefs.hasOwnerSession()) return;
    if (_connected || _connecting) return;
    _connecting = true;
    try {
      String apiKey = 'papabear_pay_key';
      String cluster = 'mt1';
      bool forceTls = true;

      final response = await parser.getSocketConfig();
      if (response.statusCode == 200 && response.body is Map) {
        final body = Map<String, dynamic>.from(response.body);
        final data = body['data'];
        if (data is Map) {
          final cfg = Map<String, dynamic>.from(data);
          apiKey = cfg['key']?.toString() ?? apiKey;
          cluster = cfg['cluster']?.toString() ?? cluster;
          forceTls = cfg['force_tls'] != false;
          _channel = cfg['channel']?.toString() ?? _channel;
          _event = cfg['event']?.toString() ?? _event;
          debugPrint(
              '💳 Socket config host=${cfg['ws_host']} channel=$_channel');
        }
      }

      _pusher = PusherChannelsFlutter.getInstance();
      await _pusher!.init(
        apiKey: apiKey,
        cluster: cluster,
        useTLS: forceTls,
        onEvent: _onEvent,
        onConnectionStateChange: (current, previous) {
          debugPrint('💳 Payment socket: $previous -> $current');
          _connected = current.toUpperCase().contains('CONNECTED');
        },
        onError: (message, code, exception) {
          debugPrint('💳 Payment socket error: $message ($code) $exception');
        },
      );

      await _pusher!.subscribe(channelName: _channel);
      await _pusher!.connect();
      _connected = true;
      debugPrint('💳 Payment socket subscribed to $_channel / $_event');
    } catch (e) {
      debugPrint('💳 Payment socket connect failed: $e');
      _connected = false;
    } finally {
      _connecting = false;
    }
  }

  void _onEvent(PusherEvent event) {
    debugPrint('💳 Socket event: ${event.eventName} => ${event.data}');
    final name = event.eventName;
    if (name != _event &&
        name != 'payment-completed' &&
        name != 'payment_completed') {
      return;
    }
    if (event.data == null) return;

    try {
      final raw = event.data;
      final dynamic decoded = raw is String ? jsonDecode(raw) : raw;
      Map<String, dynamic>? payload;
      if (decoded is Map) {
        payload = Map<String, dynamic>.from(decoded);
        if (decoded['data'] is Map) {
          payload = Map<String, dynamic>.from(decoded['data']);
        }
      }
      if (payload == null) return;

      final payment = PaymentOptionsModel.fromJson(payload);
      for (final listener in List<PaymentCompletedCallback>.from(_listeners)) {
        listener(payment);
      }
    } catch (e) {
      debugPrint('💳 Failed to parse payment-completed: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await _pusher?.unsubscribe(channelName: _channel);
      await _pusher?.disconnect();
    } catch (_) {}
    _connected = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
