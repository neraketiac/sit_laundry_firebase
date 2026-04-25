import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/utils/firestore_timeout.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/core/services/database_loyalty.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/promo_day_checker.dart';

/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
/// 🔹 COLLECTION REFERENCES
/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
const String JOBS_QUEUE_REF = "Jobs_queue";
const String JOBS_ONGOING_REF = "Jobs_ongoing";
const String JOBS_DONE_REF = "Jobs_done";
const String JOBS_COMPLETED_REF =
    "Jobs_completed"; //paidcash or paidgcash + verified , clothes delivered or pickedup done.
const String SYNC_DELETE_QUEUE_REF = "sync_delete_queue";
const String SYNC_TO_DB2_FIELD = "Z00_IsSyncToDB2";

Map<String, dynamic> withPendingDb2Sync(Map<String, dynamic> data) {
  return {
    ...data,
    SYNC_TO_DB2_FIELD: false,
  };
}

String syncDeleteQueueDocId(String sourceCollection, String docId) {
  return "${sourceCollection}__$docId";
}

Map<String, dynamic> buildSyncDeleteQueuePayload({
  required String sourceCollection,
  required String docId,
  required String reason,
}) {
  return {
    'sourceCollection': sourceCollection,
    'docId': docId,
    'reason': reason,
    'createdAt': Timestamp.now(),
  };
}

/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
/// 🔹 DATABASE : JOBS QUEUE
/// (Waiting / Sorting)
/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
class DatabaseJobsQueue {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _ref =
      _firestore.collection(JOBS_QUEUE_REF);

  /// ➕ Add job to queue
  Future<bool> add(JobModel job) async {
    bool bSuccess = false;
    final docRef = _ref.doc(); // auto-generate ID
    job.docId = docRef.id; // store the ID in your model
    await docRef
        .set(job.toJson())
        .then((value) => {
              print("Jobs On Queue insert done."),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed insert Jobs On Queue : $error ${job.customerName}"),
              bSuccess = false,
            });
    return bSuccess;
  }

  /// 📥 Get single job
  Future<JobModel?> get(String docId) async {
    final doc = await _ref.doc(docId).get().withFsTimeout();
    if (!doc.exists || doc.data() == null) return null;
    return JobModel.fromJson(doc.data()!);
  }

  /// 🔄 Stream all queued jobs
  Stream<List<JobModel>> streamAll() {
    return _ref.orderBy('A00_JobId').snapshots().map(
          (s) => s.docs.map((d) => JobModel.fromJson(d.data())).toList(),
        );
  }

  // Stream<QuerySnapshot> getAllJobsOnQueue() {
  //   return _ref.orderBy('A01_DateQ', descending: false).snapshots();
  // }

  /// ❌ Delete job
  Future<void> delete(String docId) async {
    await _ref.doc(docId).delete().withFsTimeout();
  }

  Future<void> updateJobId(String docId, int jobId) async {
    await _ref.doc(docId).update({'A00_JobId': jobId}).withFsTimeout();
  }

  Future<void> updatePaidUnpaid(JobModel jM) async {
    await _ref.doc(jM.docId).update(jM.toJson()).withFsTimeout();
  }

  Future<void> update(JobModel jM) async {
    await _ref.doc(jM.docId).update(jM.toJson()).withFsTimeout();
  }
}

/// 🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨
/// 🔹 DATABASE : JOBS ONGOING
/// (Washing / Drying / Folding)
/// 🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨
class DatabaseJobsOngoing {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _ref =
      _firestore.collection(JOBS_ONGOING_REF);

  /// 🔄 Stream all ongoing jobs
  Stream<List<JobModel>> streamAll() {
    return _ref.orderBy('A00_JobId').snapshots().map(
          (s) => s.docs.map((d) => JobModel.fromJson(d.data())).toList(),
        );
  }

  /// 🔁 Update process step
  /// Values: 'washing' | 'drying' | 'folding'
  Future<void> updateStep(String docId, String step) async {
    await _ref.doc(docId).update({'O00_ProcessStep': step}).withFsTimeout();
  }

  Future<void> updateJobId(String docId, int jobId) async {
    await _ref.doc(docId).update({'A00_JobId': jobId}).withFsTimeout();
  }

  Future<void> update(JobModel jM) async {
    await _ref.doc(jM.docId).update(jM.toJson()).withFsTimeout();
  }

  // Future<void> swapOrInsert({
  //   required String movingDocId,
  //   required int oldJobId,
  //   required int newJobId,
  // }) async {
  //   final firestore = FirebaseFirestore.instance;
  //   final colRef = firestore.collection(JOBS_ONGOING_REF);

  //   await firestore.runTransaction((tx) async {
  //     final movingRef = colRef.doc(movingDocId);

  //     final query =
  //         await colRef.where('A00_JobId', isEqualTo: newJobId).limit(1).get();

  //     if (query.docs.isNotEmpty) {
  //       final targetDoc = query.docs.first;
  //       final targetRef = colRef.doc(targetDoc.id);

  //       tx.update(movingRef, {'A00_JobId': newJobId});
  //       tx.update(targetRef, {'A00_JobId': oldJobId});
  //     } else {
  //       tx.update(movingRef, {'A00_JobId': newJobId});
  //     }
  //   });
  // }

  Future<void> swapOrInsert({
    required String movingDocId,
    required int oldJobId,
    required int newJobId,
  }) async {
    await _firestore.runTransaction((tx) async {
      final movingRef = _ref.doc(movingDocId);

      final query =
          await _ref.where('A00_JobId', isEqualTo: newJobId).limit(1).get();

      if (query.docs.isNotEmpty) {
        final targetDoc = query.docs.first;
        final targetRef = _ref.doc(targetDoc.id);

        tx.update(movingRef, {'A00_JobId': newJobId});
        tx.update(targetRef, {'A00_JobId': oldJobId});
      } else {
        tx.update(movingRef, {'A00_JobId': newJobId});
      }
    });
  }

  Future<void> cascade(List<JobModel> affectedJobs) async {
    final batch = _firestore.batch();

    for (final job in affectedJobs) {
      final docRef = _ref.doc(job.docId);

      batch.update(docRef, {
        'A00_JobId': job.jobId + 1,
      });
    }

    await batch.commit();
  }

  Future<void> cascadeUp(List<JobModel> affectedJobs) async {
    final batch = _firestore.batch();

    for (final job in affectedJobs) {
      final docRef = _ref.doc(job.docId);

      batch.update(docRef, {
        'A00_JobId': job.jobId - 1,
      });
    }

    await batch.commit();
  }
}

/// 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩
/// 🔹 DATABASE : JOBS DONE
/// (Completed / Archived)
/// 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩
class DatabaseJobsDone {
  final FirebaseFirestore _firestore = FirebaseService.jobsDoneFirestore;
  late final CollectionReference<Map<String, dynamic>> _ref =
      _firestore.collection(JOBS_DONE_REF);

  /// 🔄 Stream completed jobs
  Stream<List<JobModel>> streamAll() {
    return _ref.orderBy('A05_DateD', descending: true).snapshots().map(
          (s) => s.docs.map((d) => JobModel.fromJson(d.data())).toList(),
        );
  }

  Future<void> update(JobModel jM) async {
    jM.isSyncToDB2 = false;
    await _ref
        .doc(jM.docId)
        .update(withPendingDb2Sync(jM.toJson()))
        .withFsTimeout();
  }
}

/// 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩
/// 🔹 DATABASE : JOBS COMPLETED
/// (Completed / Archived)
/// 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩
class DatabaseJobsCompleted {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _ref =
      _firestore.collection(JOBS_COMPLETED_REF);

  /// 🔄 Stream completed jobs
  Stream<List<JobModel>> streamAll() {
    return _ref.orderBy('A05_DateD', descending: true).snapshots().map(
          (s) => s.docs.map((d) => JobModel.fromJson(d.data())).toList(),
        );
  }

  //admin only
  Future<void> update(JobModel jM) async {
    jM.isSyncToDB2 = false;
    await _ref
        .doc(jM.docId)
        .update(withPendingDb2Sync(jM.toJson()))
        .withFsTimeout();
  }

  Future<QuerySnapshot> fetchCompletedJobs({
    DocumentSnapshot? lastDoc,
    int limit = 20,
    int? customerId,
    DateTime? parameterDate,
  }) async {
    Query query = _ref;

    /// customer filter
    if (customerId != null && customerId != 0) {
      query = query.where('C00_CustomerId', isEqualTo: customerId);
    }

    /// date filter
    if (parameterDate != null) {
      DateTime start =
          DateTime(parameterDate.year, parameterDate.month, parameterDate.day);

      DateTime end = start.add(const Duration(days: 1));

      query = query
          .where("A05_DateD", isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where("A05_DateD", isLessThan: Timestamp.fromDate(end));
    }

    query = query.orderBy("A05_DateD", descending: true).limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return await query.get();
  }
}

/// 🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥
/// 🔥 JOB MOVEMENT (TRANSACTIONS)
/// 🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥

/// ▶ Queue → Ongoing (start washing)
Future<void> moveQueueToOngoing(String docId) async {
  final firestore = FirebaseFirestore.instance;
  final counterRef = firestore.collection('counters').doc('jobQueue');

  await firestore.runTransaction((tx) async {
    final queueRef = firestore.collection(JOBS_QUEUE_REF).doc(docId);
    final ongoingCollection = firestore.collection(JOBS_ONGOING_REF);
    final ongoingRef = ongoingCollection.doc(docId);

    final queueSnap = await tx.get(queueRef);
    if (!queueSnap.exists) return;

    // 1️⃣ Get nextavailable
    final counterSnap = await tx.get(counterRef);

    int nextAvailable = 1;

    if (!counterSnap.exists) {
      tx.set(counterRef, {'nextavailable': 1});
    } else {
      nextAvailable = counterSnap.get('nextavailable') ?? 1;
    }

    // 2️⃣ Check ongoing
    final ongoingCheck = await ongoingCollection.limit(1).get();

    int finalId = nextAvailable;

    if (ongoingCheck.docs.isNotEmpty) {
      final allOngoing = await ongoingCollection.get();
      final usedIds = allOngoing.docs
          .map((doc) => doc.get('A00_JobId') as int?)
          .whereType<int>()
          .toSet();

      if (usedIds.length >= 25) return;

      if (usedIds.contains(finalId)) {
        for (int i = 0; i < 25; i++) {
          finalId = finalId >= 25 ? 1 : finalId + 1;

          if (!usedIds.contains(finalId)) {
            break;
          }
        }
      }
    }

    // 3️⃣ Advance pointer AFTER assigning
    int newNextAvailable = finalId >= 25 ? 1 : finalId + 1;

    tx.set(counterRef, {'nextavailable': newNextAvailable});

    // 4️⃣ Move document
    tx.set(ongoingRef, {
      ...queueSnap.data()!,
      'Q00_ForSorting': true,
      'A00_JobId': finalId,
      'O00_ProcessStep': 'waiting',
      'O01_AllStatus': 0.3,
      'A04_DateO': Timestamp.now(),
    });

    tx.delete(queueRef);
  });
}

/// ▶ Ongoing → Done
Future<void> moveOngoingToDone(
    String docId, bool forDelivery, int customerId, int promoCounter) async {
  final primaryFirestore = FirebaseFirestore.instance;
  final jobsDoneFirestore = FirebaseService.jobsDoneFirestore;

  // Resolve the actual DateD that will be written.
  final resolvedDateD =
      useAdminTimestampDateD ? adminTimestampDateD.toDate() : DateTime.now();
  final promoEnabled = await isPromoEnabled(resolvedDateD);
  final effectivePromoCounter = promoEnabled ? promoCounter : 0;

  try {
    // Step 1: Read from Jobs_ongoing (primary database)
    final ongoingRef = primaryFirestore.collection(JOBS_ONGOING_REF).doc(docId);
    final snapshot = await ongoingRef.get();

    if (!snapshot.exists) {
      print("❌ Job not found in Jobs_ongoing: $docId");
      return;
    }

    if (!useAdminTimestampDateD) {
      adminTimestampDateD = Timestamp.now();
    }

    final jobData = withPendingDb2Sync({
      ...snapshot.data()!,
      if (forDelivery) ...{
        'Q00_ForSorting': false,
        'Q01_RiderPickup': true,
      },
      'O00_ProcessStep': 'done',
      'O01_AllStatus': 0.7,
      'A05_DateD': adminTimestampDateD,
      'Q06_PromoCounter': effectivePromoCounter,
    });

    // Step 2: Write to Jobs_done in jobsDoneDb FIRST
    print("📝 Writing to Jobs_done in jobsDoneDb...");
    await jobsDoneFirestore.collection(JOBS_DONE_REF).doc(docId).set(jobData);
    print("✅ Successfully wrote to Jobs_done");

    // Step 3: Delete from Jobs_ongoing in primary database
    print("🗑️ Deleting from Jobs_ongoing in primary database...");
    await ongoingRef.delete();
    print("✅ Successfully deleted from Jobs_ongoing");

    // Step 4: Update loyalty counter
    print("📊 Updating loyalty counter...");
    DatabaseLoyalty loyalty = DatabaseLoyalty();
    loyalty.addCountByCardNumber(customerId, effectivePromoCounter);
    print("✅ Loyalty counter updated");

    print("✅ Job $docId successfully moved to Jobs_done!");
  } catch (e) {
    print("❌ Error moving job to Jobs_done: $e");
    rethrow;
  }
}

/// ▶ Done → Completed
Future<void> moveAllDoneToCompleted() async {
  final firestore = FirebaseFirestore.instance;

  final doneCollection = firestore.collection(JOBS_DONE_REF);
  final completedCollection = firestore.collection(JOBS_COMPLETED_REF);

  // 🔥 Only get PAID jobs
  final snapshot = await doneCollection
      .where('O01_AllStatus', isEqualTo: 1)
      .get()
      .withFsTimeout();

  if (snapshot.docs.isEmpty) {
    print("No paid documents to move.");
    return;
  }

  final batch = firestore.batch();
  final deleteQueue = firestore.collection(SYNC_DELETE_QUEUE_REF);

  for (final doc in snapshot.docs) {
    final completedRef = completedCollection.doc(doc.id);
    final deleteQueueRef =
        deleteQueue.doc(syncDeleteQueueDocId(JOBS_DONE_REF, doc.id));

    batch.set(
      completedRef,
      withPendingDb2Sync({
        ...doc.data(),
        'O00_ProcessStep': 'completed',
        'A06_DateC': Timestamp.now(),
      }),
    );
    batch.set(
      deleteQueueRef,
      buildSyncDeleteQueuePayload(
        sourceCollection: JOBS_DONE_REF,
        docId: doc.id,
        reason: 'moved_to_jobs_completed',
      ),
    );

    batch.delete(doc.reference);
  }

  await batch.commit();

  print("Paid documents moved successfully.");
}

/// 🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥
/// 🔥 JOB ONGOING JOBID
/// 🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥

Future<int> getMaxJobId() async {
  final snapshot = await FirebaseFirestore.instance
      .collection(JOBS_ONGOING_REF)
      .orderBy('A00_JobId', descending: true)
      .limit(1)
      .get()
      .withFsTimeout();

  final maxNumber =
      snapshot.docs.isNotEmpty ? snapshot.docs.first.get('A00_JobId') : 0;

  return (maxNumber + 1);
}

Future<int> getNextJobIdCounterUp() async {
  final firestore = FirebaseFirestore.instance;
  final counterRef = firestore.collection('counters').doc('jobQueue');

  return firestore.runTransaction<int>((transaction) async {
    // 1️⃣ Get counter
    final counterSnap = await transaction.get(counterRef);

    int current = 0;

    if (!counterSnap.exists) {
      transaction.set(counterRef, {'current': 0});
    } else {
      current = counterSnap.get('current') ?? 0;
    }

    // 2️⃣ Get used JobIds (1–25 only)
    final snapshot = await firestore
        .collection(JOBS_ONGOING_REF)
        .where('A00_JobId', isGreaterThanOrEqualTo: 1)
        .where('A00_JobId', isLessThanOrEqualTo: 25)
        .get();

    final usedIds =
        snapshot.docs.map((doc) => doc.get('A00_JobId') as int).toSet();

    // 🚨 If already full
    if (usedIds.length >= 25) {
      return 0;
    }

    // 3️⃣ Try up to 25 slots
    for (int i = 0; i < 25; i++) {
      int next = current >= 25 ? 1 : current + 1;

      if (!usedIds.contains(next)) {
        transaction.update(counterRef, {'current': next});
        return next;
      }

      current = next;
    }

    // Safety fallback
    return 0;
  });
}

//

Future<int> getNextJobId() async {
  final firestore = FirebaseFirestore.instance;
  final counterRef = firestore.collection('counters').doc('jobQueue');
  final ongoingCollection = firestore.collection(JOBS_ONGOING_REF);

  return firestore.runTransaction<int>((tx) async {
    final counterSnap = await tx.get(counterRef);

    int nextAvailable = 1;

    if (counterSnap.exists) {
      nextAvailable = counterSnap.get('nextavailable') ?? 1;
    }

    // 1️⃣ Check if ongoing is empty
    final ongoingCheck = await ongoingCollection.limit(1).get();

    // 🟢 If empty → just return nextAvailable
    if (ongoingCheck.docs.isEmpty) {
      return nextAvailable;
    }

    // 2️⃣ Collect used IDs
    final ongoingSnapshot = await ongoingCollection.get();

    final usedIds = ongoingSnapshot.docs
        .map((doc) => doc.data()['A00_JobId'] as int?)
        .whereType<int>()
        .toSet();

    if (usedIds.length >= 25) {
      return 0;
    }

    int candidate = nextAvailable;

    // 3️⃣ If candidate not used → return it
    if (!usedIds.contains(candidate)) {
      return candidate;
    }

    // 4️⃣ Otherwise keep incrementing cyclic
    for (int i = 0; i < 25; i++) {
      candidate = candidate >= 25 ? 1 : candidate + 1;

      if (!usedIds.contains(candidate)) {
        return candidate;
      }
    }

    return 0;
  });
}
