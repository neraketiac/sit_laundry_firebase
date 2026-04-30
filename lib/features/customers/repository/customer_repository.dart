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

  static const String _storageKey = 'loyalty_cache';
  static const String _versionKey = 'loyalty_cache_version';

  /// Loads loyalty customers with three-level caching:
  /// 1. Check remote version first (always)
  /// 2. If version matches cached version → load from localStorage (fast)
  /// 3. If version differs or no cache → fetch from Firestore (fresh data)
  Future<void> loadOnce() async {
    try {
      // 1. Always check remote version first
      int remoteVersion = 0;
      try {
        final versionDoc = await FirebaseFirestore.instance
            .collection('loyalty_updated')
            .doc('counter')
            .get();
        remoteVersion = (versionDoc.data()?['version'] as num?)?.toInt() ?? 0;
        FsUsageTracker.instance.track('loyaltyVersionCheck', 1);
      } catch (_) {}

      // 2. Get cached version from localStorage
      final localVersionStr = web.window.localStorage.getItem(_versionKey);
      final localVersion =
          localVersionStr != null ? int.tryParse(localVersionStr) ?? -1 : -1;
      final cached = web.window.localStorage.getItem(_storageKey);

      // 3. If versions match and cache exists → use cache (fast path)
      if (remoteVersion == localVersion &&
          localVersion != -1 &&
          cached != null &&
          cached.isNotEmpty) {
        try {
          final list = jsonDecode(cached) as List<dynamic>;
          customers
            ..clear()
            ..addAll(list.map((e) => _fromCache(e as Map<String, dynamic>)));
          FsUsageTracker.instance.track('loyaltyFromLocalStorage', 0);
          return;
        } catch (_) {
          // Corrupted cache — fall through to full fetch
        }
      }

      // 4. Version mismatch or no cache → fetch fresh data from Firestore
      await _fetchFromFirestore();
    } catch (_) {}
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
    } catch (_) {}
  }

  /// Force a reload on next call (e.g. after local add)
  void invalidate() {
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
