import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/utils/fs_usage_tracker.dart';
import 'package:laundry_firebase/features/customers/models/customermodel.dart';

class CustomerRepository {
  CustomerRepository._();
  static final CustomerRepository instance = CustomerRepository._();

  final List<CustomerModel> customers = [];
  bool _loaded = false;
  int _cachedVersion = -1; // -1 = never loaded

  /// Loads loyalty customers, using a version counter to skip re-fetch
  /// when data hasn't changed since last load.
  ///
  /// `loyalty_updated/counter` holds { version: N }.
  /// If N matches _cachedVersion, skip the full loyalty fetch.
  Future<void> loadOnce() async {
    // 1. Fetch the version counter (1 read always)
    int remoteVersion = -1;
    try {
      final versionDoc = await FirebaseFirestore.instance
          .collection('loyalty_updated')
          .doc('counter')
          .get();
      remoteVersion = (versionDoc.data()?['version'] as num?)?.toInt() ?? 0;
      FsUsageTracker.instance.track('loyaltyVersionCheck', 1);
    } catch (_) {
      // If version check fails, force a full reload
      remoteVersion = -1;
    }

    // 2. If version matches and already loaded, skip full fetch
    if (_loaded && remoteVersion == _cachedVersion) {
      return;
    }

    // 3. Full fetch needed
    final snapshot =
        await FirebaseFirestore.instance.collection('loyalty').get();

    customers
      ..clear()
      ..addAll(
        snapshot.docs.map((doc) => CustomerModel(
              customerId: int.parse(doc.id),
              name: doc['Name'],
              address: doc['Address'],
              contact: doc['Name'],
              remarks: doc['Name'],
              loyaltyCount: doc['Count'],
            )),
      );

    FsUsageTracker.instance.track('loyaltyAutocomplete', snapshot.docs.length);
    _cachedVersion = remoteVersion;
    _loaded = true;
  }

  /// Force a reload on next call (e.g. after local add)
  void invalidate() {
    _cachedVersion = -1;
  }
}
