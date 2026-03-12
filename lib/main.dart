import 'package:flutter/material.dart';
import 'core/services/firebase_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.initialize();

  runApp(const MyApp());
}
