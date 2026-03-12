import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/loyalty/pages/scan_page.dart';
import 'package:laundry_firebase/features/pages/body/Loyalty/enterloyaltycode.dart';

class AppRouter {
  static Route generateRoute(RouteSettings settings) {
    final cleanUrl = Uri.base.toString().split('#').last;
    final uri = Uri.parse(cleanUrl);

    final contactNumber = uri.queryParameters['contactNumber'];

    if (contactNumber != null && contactNumber.isNotEmpty) {
      return MaterialPageRoute(
        builder: (_) => const ScanPage(),
      );
    }

    return MaterialPageRoute(
      builder: (_) => const EnterLoyaltyCode(),
    );
  }
}
