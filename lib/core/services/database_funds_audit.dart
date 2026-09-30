import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:laundry_firebase/core/utils/firestore_timeout.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

const String fundsAuditRef = "SuppliesHist_Audit";

class DatabaseFundsAudit {
  late final CollectionReference _auditRefPrimary;
  late final CollectionReference _auditRefJobsDone;
  late final CollectionReference _auditRefGCash;

  DatabaseFundsAudit() {
    _auditRefPrimary = FirebaseFirestore.instance.collection(fundsAuditRef);
    _auditRefJobsDone =
        FirebaseService.jobsDoneFirestore.collection(fundsAuditRef);
    _auditRefGCash =
        FirebaseService.gcashPendingDoneFirestore.collection(fundsAuditRef);
  }

  Future<List<SuppliesModelHist>> getAuditHistoryPaginated(
      {int pageSize = 50}) async {
    final allItems = <SuppliesModelHist>[];

    try {
      debugPrint(
          '🔍 Querying Primary DB (FirebaseFirestore.instance) - SuppliesHist_Audit');
      final docs1 =
          await _auditRefPrimary.limit(pageSize * 3).get().withFsTimeout();
      debugPrint('✅ Primary DB returned: ${docs1.docs.length} records');
      for (var doc in docs1.docs) {
        final data = doc.data() as Map<String, dynamic>;
        allItems.add(SuppliesModelHist.fromJson(data));
      }
    } catch (e) {
      debugPrint('❌ Primary DB error: $e');
    }

    try {
      debugPrint(
          '🔍 Querying JobsDone DB (jobsDoneFirestore) - SuppliesHist_Audit');
      final docs2 =
          await _auditRefJobsDone.limit(pageSize * 3).get().withFsTimeout();
      debugPrint('✅ JobsDone DB returned: ${docs2.docs.length} records');
      for (var doc in docs2.docs) {
        final data = doc.data() as Map<String, dynamic>;
        allItems.add(SuppliesModelHist.fromJson(data));
      }
    } catch (e) {
      debugPrint('❌ JobsDone DB error: $e');
    }

    try {
      debugPrint(
          '🔍 Querying GCash DB (gcashPendingDoneFirestore) - SuppliesHist_Audit');
      final docs3 =
          await _auditRefGCash.limit(pageSize * 3).get().withFsTimeout();
      debugPrint('✅ GCash DB returned: ${docs3.docs.length} records');
      for (var doc in docs3.docs) {
        final data = doc.data() as Map<String, dynamic>;
        allItems.add(SuppliesModelHist.fromJson(data));
      }
    } catch (e) {
      debugPrint('❌ GCash DB error: $e');
    }

    allItems.sort((a, b) => b.logDate.compareTo(a.logDate));
    debugPrint('📊 Total audit records from all 3 DBs: ${allItems.length}');
    return allItems.take(pageSize).toList();
  }

  /// Stream all audit records from all 3 databases, sorted by date descending
  Stream<List<SuppliesModelHist>> streamAuditHistory() {
    return Stream.multi((controller) async {
      // Listen to all 3 databases
      final subscription1 = _auditRefPrimary
          .orderBy('LogDate', descending: true)
          .limit(50)
          .snapshots()
          .listen((snapshot) {
        _emitCombinedStream(controller);
      });

      final subscription2 = _auditRefJobsDone
          .orderBy('LogDate', descending: true)
          .limit(50)
          .snapshots()
          .listen((snapshot) {
        _emitCombinedStream(controller);
      });

      final subscription3 = _auditRefGCash
          .orderBy('LogDate', descending: true)
          .limit(50)
          .snapshots()
          .listen((snapshot) {
        _emitCombinedStream(controller);
      });

      controller.onCancel = () {
        subscription1.cancel();
        subscription2.cancel();
        subscription3.cancel();
      };
    });
  }

  Future<void> _emitCombinedStream(
      StreamController<List<SuppliesModelHist>> controller) async {
    try {
      final allItems = <SuppliesModelHist>[];

      // Fetch from all 3 databases
      try {
        final docs1 = await _auditRefPrimary
            .orderBy('LogDate', descending: true)
            .limit(50)
            .get()
            .withFsTimeout();
        for (var doc in docs1.docs) {
          final data = doc.data() as Map<String, dynamic>;
          allItems.add(SuppliesModelHist.fromJson(data));
        }
      } catch (e) {
        debugPrint('❌ Primary DB stream error: $e');
      }

      try {
        final docs2 = await _auditRefJobsDone
            .orderBy('LogDate', descending: true)
            .limit(50)
            .get()
            .withFsTimeout();
        for (var doc in docs2.docs) {
          final data = doc.data() as Map<String, dynamic>;
          allItems.add(SuppliesModelHist.fromJson(data));
        }
      } catch (e) {
        debugPrint('❌ JobsDone DB stream error: $e');
      }

      try {
        final docs3 = await _auditRefGCash
            .orderBy('LogDate', descending: true)
            .limit(50)
            .get()
            .withFsTimeout();
        for (var doc in docs3.docs) {
          final data = doc.data() as Map<String, dynamic>;
          allItems.add(SuppliesModelHist.fromJson(data));
        }
      } catch (e) {
        debugPrint('❌ GCash DB stream error: $e');
      }

      // Sort all items by date descending
      allItems.sort((a, b) => b.logDate.compareTo(a.logDate));

      if (!controller.isClosed) {
        controller.add(allItems);
      }
    } catch (e) {
      debugPrint('❌ Error emitting combined stream: $e');
    }
  }
}
