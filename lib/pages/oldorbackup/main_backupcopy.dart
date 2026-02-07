import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/enterloyaltycode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase

  await Firebase.initializeApp(
    // Replace with your actual values
    options: const FirebaseOptions(
        apiKey: "AIzaSyASvVM-bX6W7-r1-O_u8fbrn5CaFnxVzWQ",
        authDomain: "wash-ko-lang-sit.firebaseapp.com",
        projectId: "wash-ko-lang-sit",
        storageBucket: "wash-ko-lang-sit.appspot.com",
        messagingSenderId: "248306194923",
        appId: "1:248306194923:web:4484ca74bbc01546b7a1ae"),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        if (settings.name == '/scan') {
          return MaterialPageRoute(
            builder: (_) => const EnterLoyaltyCode(),
          );
        }

        // fallback
        return MaterialPageRoute(
          builder: (_) => const EnterLoyaltyCode(),
        );
      },
    );
  }
}
