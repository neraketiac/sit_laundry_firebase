import 'package:flutter/material.dart';

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

    final cleanUrl = Uri.base.toString().split('#').last;
    final uri = Uri.parse(cleanUrl);

    contactNumber = uri.queryParameters['contactNumber'];
    destinationName = uri.queryParameters['destinationName'];

    debugPrint('EMP ID = $contactNumber');
  }

  @override
  Widget build(BuildContext context) {
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
