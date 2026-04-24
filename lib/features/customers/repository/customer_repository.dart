import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/utils/fs_usage_tracker.dart';
import 'package:laundry_firebase/features/customers/models/customermodel.dart';
import 'package:web/web.dart' as web;

class CustomerRepository {
  CustomerRepository._();
  static final CustomerRepository instance = CustomerRepository._();

  final List<CustomerModel> customers = [];
  bool _loaded = false;
  int _cachedVersion = -1;

  static const String _storageKey = 'loyalty_cache';
  static const String _versionKey = 'loyalty_cache_version';

  /// Loads loyalty customers with two-level caching:
  /// 1. Check Firestore version counter (1 read)
  /// 2. If version matches localStorage → load from localStorage (0 reads)
  /// 3. If version changed → fetch all from Firestore → save to localStorage
  Future<void> loadOnce() async {
    // 1. Fetch version counter (always 1 read)
    int remoteVersion = -1;
    try {
      final versionDoc = await FirebaseFirestore.instance
          .collection('loyalty_updated')
          .doc('counter')
          .get();
      remoteVersion = (versionDoc.data()?['version'] as num?)?.toInt() ?? 0;
      FsUsageTracker.instance.track('loyaltyVersionCheck', 1);
    } catch (_) {
      remoteVersion = -1;
    }

    // 2. Check localStorage version
    final localVersionStr = web.window.localStorage.getItem(_versionKey);
    final localVersion =
        localVersionStr != null ? int.tryParse(localVersionStr) ?? -1 : -1;

    // 3. If in-memory already matches → done
    if (_loaded && remoteVersion != -1 && remoteVersion == _cachedVersion) {
      return;
    }

    // 4. If localStorage version matches remote → load from localStorage
    if (remoteVersion != -1 && remoteVersion == localVersion) {
      final cached = web.window.localStorage.getItem(_storageKey);
      if (cached != null && cached.isNotEmpty) {
        try {
          final list = jsonDecode(cached) as List<dynamic>;
          customers
            ..clear()
            ..addAll(list.map((e) => _fromCache(e as Map<String, dynamic>)));
          _cachedVersion = remoteVersion;
          _loaded = true;
          FsUsageTracker.instance.track('loyaltyFromLocalStorage', 0);
          return;
        } catch (_) {
          // Corrupted cache — fall through to full fetch
        }
      }
    }

    // 5. Full Firestore fetch needed
    final snapshot =
        await FirebaseFirestore.instance.collection('loyalty').get();

    final loaded = snapshot.docs
        .map((doc) => CustomerModel(
              customerId: int.parse(doc.id),
              name: doc['Name'],
              address: doc['Address'],
              contact: doc['Name'],
              remarks: doc['Name'],
              loyaltyCount: doc['Count'],
            ))
        .toList();

    customers
      ..clear()
      ..addAll(loaded);

    FsUsageTracker.instance.track('loyaltyAutocomplete', snapshot.docs.length);

    // 6. Save to localStorage
    try {
      final encoded = jsonEncode(loaded.map(_toCache).toList());
      web.window.localStorage.setItem(_storageKey, encoded);
      web.window.localStorage.setItem(_versionKey, remoteVersion.toString());
    } catch (_) {
      // localStorage full or unavailable — ignore
    }

    _cachedVersion = remoteVersion;
    _loaded = true;
  }

  /// Force a reload on next call (e.g. after local add)
  void invalidate() {
    _cachedVersion = -1;
    web.window.localStorage.removeItem(_storageKey);
    web.window.localStorage.removeItem(_versionKey);
  }

  Map<String, dynamic> _toCache(CustomerModel c) => {
        'id': c.customerId,
        'n': c.name,
        'a': c.address,
        'lc': c.loyaltyCount,
      };

  CustomerModel _fromCache(Map<String, dynamic> m) => CustomerModel(
        customerId: m['id'] as int,
        name: m['n'] as String,
        address: m['a'] as String,
        contact: m['n'] as String,
        remarks: '',
        loyaltyCount: m['lc'] as int,
      );
}
