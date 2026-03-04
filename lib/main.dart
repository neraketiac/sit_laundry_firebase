import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/enterloyaltycode.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

late FirebaseApp secondaryApp;
late FirebaseFirestore secondaryFirestore;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase

  // 🔹 MAIN project
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 SECONDARY project (web only in your case)
  secondaryApp = await Firebase.initializeApp(
    name: 'secondary',
    options: DefaultFirebaseOptions.secondaryWeb,
  );

  secondaryFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);

  print("Both Firebase projects initialized properly");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // testSecondary();
  }

  // Future<void> testSecondary() async {
  //   await secondaryFirestore.collection('test').add({
  //     'message': 'Hello secondary',
  //     'timestamp': DateTime.now(),
  //   });

  //   debugPrint("Secondary write success");
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        final cleanUrl = Uri.base.toString().split('#').last;
        final uri = Uri.parse(cleanUrl);

        final contactNumber = uri.queryParameters['contactNumber'];

        if (contactNumber != null && contactNumber.isNotEmpty) {
          return MaterialPageRoute(
            builder: (_) => ScanPage(),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const EnterLoyaltyCode(),
        );
      },
    );
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? contactNumber;
  String? destinationName;

  @override
  void initState() {
    super.initState();

    // ✅ SAFELY PARSE URL (handles #/scan)
    final cleanUrl = Uri.base.toString().split('#').last;
    final uri = Uri.parse(cleanUrl);

    contactNumber = uri.queryParameters['contactNumber'];
    destinationName = uri.queryParameters['destinationName'];

    debugPrint('EMP ID = $contactNumber');
  }

  @override
  Widget build(BuildContext context) {
    //how to test
    //https://wash-ko-lang-sit.web.app/#/scan?contactNumber=ABC001&destinationName=juandelacruz
    // SuppliesHistRepository.instance.reset();
    // SuppliesHistRepository.instance
    //     .setItemName(getItemNameOnly(menuOthCashInOutFunds, selectedFundCode!));
    // SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
    // SuppliesHistRepository.instance.setItemUniqueId(selectedFundCode!);
    // SuppliesHistRepository.instance.setRemarks(remarksSuppliesVar.text);
    // SuppliesHistRepository.instance.setCurrentCounter(
    //     int.parse(customerAmountVar.text.replaceAll(',', '')));

    // Future<void> insertRepositorytoFB() async {
    //   await insertToFB(context);
    // }

    // insertRepositorytoFB();

    return Scaffold(
      body: Center(
        child: Text(
          contactNumber == null
              ? '❌ No contactNumber from QR'
              : '✅ QR GCash Done: $contactNumber $destinationName',
          style: const TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
