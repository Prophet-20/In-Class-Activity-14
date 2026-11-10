import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  StreamSubscription<RemoteMessage>? _foreground;
  StreamSubscription<RemoteMessage>? _opened;
  StreamSubscription<String>? _tokenRefresh;

  bool _started = false;
  bool _disposed = false;

  Future<void> initialize({
    required void Function(RemoteMessage, String) onData,
    required void Function(String) onStatus,
  }) async {
    if (_started || _disposed) return;
    _started = true;

    void deliver(RemoteMessage message, String handler) {
      if (_disposed) return;

      debugPrint('$handler: ${message.messageId}');
      onData(message, handler);
    }

    // A message arrives while the app is visible.
    _foreground = FirebaseMessaging.onMessage.listen((message) {
      deliver(message, 'onMessage');
    });

    // A notification tap brings a backgrounded app forward.
    _opened = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      deliver(message, 'onMessageOpenedApp');
    });

    // A notification tap started a terminated app.
    final initialMessage = await _messaging.getInitialMessage();
    if (_disposed) return;

    if (initialMessage != null) {
      deliver(initialMessage, 'getInitialMessage');
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (_disposed) return;

    final permission = settings.authorizationStatus.name;
    onStatus('Permission: $permission');

    _tokenRefresh = _messaging.onTokenRefresh.listen((token) {
      if (_disposed) return;

      if (kDebugMode) {
        debugPrint('FCM token (development only): $token');
      }
      onStatus('Permission: $permission | Token refreshed');
    });

    final token = await _messaging.getToken();
    if (_disposed) return;

    if (kDebugMode) {
      debugPrint('FCM token (development only): $token');
    }

    onStatus(
      'Permission: $permission | '
      '${token == null ? "Token unavailable" : "Token ready"}',
    );
  }

  Future<void> dispose() async {
    _disposed = true;

    await _foreground?.cancel();
    await _opened?.cancel();
    await _tokenRefresh?.cancel();
  }
}