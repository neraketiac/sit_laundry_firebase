import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static late FirebaseApp secondaryApp;
  static late FirebaseFirestore secondaryFirestore;

  static late FirebaseApp forthApp;
  static late FirebaseFirestore forthFirestore;

  static late FirebaseApp jobsDoneApp;
  static late FirebaseFirestore jobsDoneFirestore;

  static late FirebaseApp gcashPendingDoneApp;
  static late FirebaseFirestore gcashPendingDoneFirestore;

  static late FirebaseApp employeeApp;
  static late FirebaseFirestore employeeFirestore;

  static late FirebaseApp suppliesApp;
  static late FirebaseFirestore suppliesFirestore;

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

    // FORTH Firebase (Loyalty Card DB)
    forthApp = await Firebase.initializeApp(
      name: 'forth',
      options: DefaultFirebaseOptions.loyaltyCardDb,
    );
    forthFirestore = FirebaseFirestore.instanceFor(app: forthApp);

    // JOBS DONE Firebase
    jobsDoneApp = await Firebase.initializeApp(
      name: 'jobsDone',
      options: DefaultFirebaseOptions.jobsDoneDb,
    );
    jobsDoneFirestore = FirebaseFirestore.instanceFor(app: jobsDoneApp);

    // GCASH PENDING DONE Firebase
    gcashPendingDoneApp = await Firebase.initializeApp(
      name: 'gcashPendingDone',
      options: DefaultFirebaseOptions.gcashPendingDoneDB,
    );
    gcashPendingDoneFirestore =
        FirebaseFirestore.instanceFor(app: gcashPendingDoneApp);

    // EMPLOYEE Firebase
    employeeApp = await Firebase.initializeApp(
      name: 'employee',
      options: DefaultFirebaseOptions.employeeDB,
    );
    employeeFirestore = FirebaseFirestore.instanceFor(app: employeeApp);

    // SUPPLIES Firebase
    suppliesApp = await Firebase.initializeApp(
      name: 'supplies',
      options: DefaultFirebaseOptions.suppliesDB,
    );
    suppliesFirestore = FirebaseFirestore.instanceFor(app: suppliesApp);

    print("Firebase projects initialized");
  }
}
