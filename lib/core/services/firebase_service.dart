import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static late FirebaseApp secondaryApp;
  static late FirebaseFirestore secondaryFirestore;

  static late FirebaseApp forthApp;
  static late FirebaseFirestore forthFirestore;

  static FirebaseFirestore get primaryFirestore => FirebaseFirestore.instance;

  static Future<void> initialize() async {
    // PRIMARY Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // SECONDARY Firebase
    secondaryApp = await Firebase.initializeApp(
      name: 'secondary',
      options: DefaultFirebaseOptions.riderDb,
    );
    secondaryFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);

    // FORTH Firebase
    forthApp = await Firebase.initializeApp(
      name: 'forth',
      options: DefaultFirebaseOptions.loyaltyCardDb,
    );
    forthFirestore = FirebaseFirestore.instanceFor(app: forthApp);

    print("Firebase projects initialized");
  }
}
