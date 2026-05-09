import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/project_version_manager.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch unhandled async errors (e.g. Firestore timeouts thrown outside FsHandler)
  FlutterError.onError = (details) {
    // Suppress timeout errors — they're already handled by FsHandler where possible
    final exception = details.exception;
    if (exception is FirebaseException && exception.code == 'timeout') return;
    FlutterError.presentError(details);
  };

  // Catch errors from async zones (Futures not wrapped in try/catch)
  PlatformDispatcher.instance.onError = (error, stack) {
    if (error is FirebaseException && error.code == 'timeout') return true;
    return false; // let other errors propagate normally
  };

  await FirebaseService.initialize();

  // Initialize session version (captures app version at startup)
  ProjectVersionManager.initializeSessionVersion();

  // Initialize notifications in background without blocking app startup
  NotificationService.initialize();

  runApp(MyApp(key: myAppKey));
}
