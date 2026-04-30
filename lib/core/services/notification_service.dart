import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message: ${message.notification?.title}');
  }
  _playNotificationSound(message.data['sound'] ?? 'default');
}

void _playNotificationSound(String soundName) {
  try {
    final audioElement = html.AudioElement('/sounds/$soundName.mp3');
    audioElement.play();
  } catch (e) {
    if (kDebugMode) {
      print('Error playing sound: $e');
    }
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }

      // Get FCM token
      String? token = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Foreground message: ${message.notification?.title}');
        }
        // Play custom sound for foreground notifications
        _playNotificationSound(message.data['sound'] ?? 'default');
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Notification opened: ${message.notification?.title}');
        }
      });
    }
  }
}
