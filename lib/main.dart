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

      // Works with Flutter Web hash routing
      onGenerateRoute: (settings) {
        // Clean the URL (handles #/scan)
        final cleanUrl = Uri.base.toString().split('#').last;
        final uri = Uri.parse(cleanUrl);

        final contactNumber = uri.queryParameters['contactNumber'];

        // ✅ IF contactNumber EXISTS → show contactNumber page
        if (contactNumber != null && contactNumber.isNotEmpty) {
          return MaterialPageRoute(
            builder: (_) => ScanPage(),
          );
        }

        // ❌ IF NO contactNumber → show EnterLoyaltyCode
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
