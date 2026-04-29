import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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

  /// Loads loyalty customers with three-level caching:
  /// 1. If in-memory already loaded → done (0 reads)
  /// 2. If localStorage exists → load from it, then async-check version in background
  /// 3. If localStorage missing/stale → fetch from Firestore → save to localStorage
  Future<void> loadOnce() async {
    // 1. Already in memory — done
    if (_loaded && customers.isNotEmpty) return;

    // 2. Try localStorage first — no Firestore read needed
    final localVersionStr = web.window.localStorage.getItem(_versionKey);
    final localVersion =
        localVersionStr != null ? int.tryParse(localVersionStr) ?? -1 : -1;
    final cached = web.window.localStorage.getItem(_storageKey);

    if (localVersion != -1 && cached != null && cached.isNotEmpty) {
      try {
        final list = jsonDecode(cached) as List<dynamic>;
        customers
          ..clear()
          ..addAll(list.map((e) => _fromCache(e as Map<String, dynamic>)));
        _cachedVersion = localVersion;
        _loaded = true;
        FsUsageTracker.instance.track('loyaltyFromLocalStorage', 0);

        // Background version check — refresh if stale, no await
        _checkVersionInBackground(localVersion);
        return;
      } catch (_) {
        // Corrupted cache — fall through to full fetch
      }
    }

    // 3. No localStorage — full Firestore fetch
    await _fetchFromFirestore();
  }

  /// Checks version in background and refreshes cache if stale.
  void _checkVersionInBackground(int localVersion) {
    FirebaseFirestore.instance
        .collection('loyalty_updated')
        .doc('counter')
        .get()
        .then((doc) async {
      final remoteVersion = (doc.data()?['version'] as num?)?.toInt() ?? 0;
      FsUsageTracker.instance.track('loyaltyVersionCheck', 1);
      if (remoteVersion != localVersion) {
        // Stale — refresh silently
        await _fetchFromFirestore();
      }
    }).catchError((_) {});
  }

  Future<void> _fetchFromFirestore() async {
    try {
      // Fetch version from main Firestore
      int remoteVersion = 0;
      try {
        final versionDoc = await FirebaseFirestore.instance
            .collection('loyalty_updated')
            .doc('counter')
            .get();
        remoteVersion = (versionDoc.data()?['version'] as num?)?.toInt() ?? 0;
        FsUsageTracker.instance.track('loyaltyVersionCheck', 1);
      } catch (_) {}

      // Fetch loyalty data from loyaltyCardDb
      final loyaltyFirestore = FirebaseFirestore.instanceFor(
        app: Firebase.apps.firstWhere(
          (app) => app.name == 'loyaltyCardDb',
          orElse: () => Firebase.app(),
        ),
      );
      final snapshot = await loyaltyFirestore.collection('loyalty').get();

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

      FsUsageTracker.instance
          .track('loyaltyAutocomplete', snapshot.docs.length);

      // Save to localStorage
      try {
        final encoded = jsonEncode(loaded.map(_toCache).toList());
        web.window.localStorage.setItem(_storageKey, encoded);
        web.window.localStorage.setItem(_versionKey, remoteVersion.toString());
      } catch (_) {}

      _cachedVersion = remoteVersion;
      _loaded = true;
    } catch (_) {}
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
