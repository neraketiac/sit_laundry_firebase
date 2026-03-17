import 'package:flutter/material.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.initialize();
  
  // Initialize notifications in background without blocking app startup
  NotificationService.initialize();

  runApp(const MyApp());
}
