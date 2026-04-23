import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

/// Returns true if promo is ENABLED for the given date.
/// Promo is enabled by default — only explicitly disabled days return false.
///
/// Pass the job's DateD to check:
///   final enabled = await isPromoEnabled(job.dateD.toDate());
///   final promoCounter = enabled ? computePromo(...) : 0;
///
/// If DateD is timestamp1900 (year == 1900), today's date is used instead.
Future<bool> isPromoEnabled(DateTime date) async {
  // timestamp1900 sentinel → fall back to today
  final effectiveDate = date.year <= 1900 ? DateTime.now() : date;
  final id = DateFormat('yyyy-MM-dd').format(effectiveDate);
  try {
    final doc = await FirebaseService.primaryFirestore
        .collection('promo_days')
        .doc(id)
        .get();
    if (!doc.exists) return true; // no record = enabled
    return !(doc.data()?['disabled'] as bool? ?? false);
  } catch (_) {
    return true; // fail-safe: treat as enabled
  }
}
