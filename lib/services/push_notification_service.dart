import 'dart:async';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  Stream<String> get onTokenRefresh => Stream.empty();

  Future<void> initialize() async {
    if (kDebugMode) {
      print('ℹ️ PushNotificationService initialized (Mock Mode - No Firebase)');
    }
    // No-op
  }

  Future<String?> getToken() async {
    if (kDebugMode) {
      print('ℹ️ getToken called (Mock Mode - returns null)');
    }
    return null;
  }
}

/// Background message handler (Dummy)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(dynamic message) async {
  if (kDebugMode) {
    print('🌙 Handling background message (Mock Mode)');
  }
}

