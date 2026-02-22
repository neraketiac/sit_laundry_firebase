import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';

/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
/// 🔹 COLLECTION REFERENCES
/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
const String JOBS_QUEUE_REF = "Jobs_queue";
const String JOBS_ONGOING_REF = "Jobs_ongoing";
const String JOBS_DONE_REF = "Jobs_done";

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
    final doc = await _ref.doc(docId).get();
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
    await _ref.doc(docId).delete();
  }

  Future<void> updateJobId(String docId, int jobId) async {
    await _ref.doc(docId).update({
      'A00_JobId': jobId,
    });
  }

  Future<void> updatePaidUnpaid(JobModel jM) async {
    await _ref.doc(jM.docId).update(jM.toJson());
  }

  Future<bool> update(JobModel jM) async {
    bool bSuccess = false;
    await _ref
        .doc(jM.docId)
        .update(jM.toJson())
        .then((value) => {
              print("Update Done"),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed Update Jobs On Queue : $error ${jM.customerName}"),
              bSuccess = false,
            });
    ;
    return bSuccess;
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
    await _ref.doc(docId).update({
      'O00_ProcessStep': step,
    });
  }

  Future<void> updateJobId(String docId, int jobId) async {
    await _ref.doc(docId).update({
      'A00_JobId': jobId + 1,
    });
  }

  Future<bool> update(JobModel jM) async {
    bool bSuccess = false;
    await _ref
        .doc(jM.docId)
        .update(jM.toJson())
        .then((value) => {
              print("Update Done"),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed Update Jobs On-Going : $error ${jM.customerName}"),
              bSuccess = false,
            });
    ;
    return bSuccess;
  }
}

/// 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩
/// 🔹 DATABASE : JOBS DONE
/// (Completed / Archived)
/// 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩
class DatabaseJobsDone {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _ref =
      _firestore.collection(JOBS_DONE_REF);

  /// 🔄 Stream completed jobs
  Stream<List<JobModel>> streamAll() {
    return _ref.snapshots().map(
          (s) => s.docs.map((d) => JobModel.fromJson(d.data())).toList(),
        );
  }

  Future<bool> update(JobModel jM) async {
    bool bSuccess = false;
    await _ref
        .doc(jM.docId)
        .update(jM.toJson())
        .then((value) => {
              print("Update Done"),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed Update Jobs Done : $error ${jM.customerName}"),
              bSuccess = false,
            });
    ;
    return bSuccess;
  }
}

/// 🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥
/// 🔥 JOB MOVEMENT (TRANSACTIONS)
/// 🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥

Future<int> getMaxJobId() async {
  final snapshot = await FirebaseFirestore.instance
      .collection(JOBS_ONGOING_REF)
      .orderBy('A00_JobId', descending: true)
      .limit(1)
      .get();

  final maxNumber =
      snapshot.docs.isNotEmpty ? snapshot.docs.first.get('A00_JobId') : 0;

  return (maxNumber + 1);
}

Future<int> getNextJobId() async {
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

/// ▶ Queue → Ongoing (start washing)
Future<void> moveQueueToOngoing(String docId, int nextJobId) async {
  final firestore = FirebaseFirestore.instance;

  await firestore.runTransaction((tx) async {
    final queueRef = firestore.collection(JOBS_QUEUE_REF).doc(docId);
    final ongoingRef = firestore.collection(JOBS_ONGOING_REF).doc(docId);

    final snapshot = await tx.get(queueRef);
    if (!snapshot.exists) return;

    tx.set(ongoingRef, {
      ...snapshot.data()!,
      'A00_JobId': nextJobId,
      'O00_ProcessStep': 'waiting', // 👈 initial step
      'A04_DateO': Timestamp.now(),
    });
    tx.delete(queueRef);
  });
}

/// ▶ Ongoing → Done
Future<void> moveOngoingToDone(String docId) async {
  final firestore = FirebaseFirestore.instance;

  await firestore.runTransaction((tx) async {
    final ongoingRef = firestore.collection(JOBS_ONGOING_REF).doc(docId);
    final doneRef = firestore.collection(JOBS_DONE_REF).doc(docId);

    final snapshot = await tx.get(ongoingRef);
    if (!snapshot.exists) return;

    tx.set(doneRef, {
      ...snapshot.data()!,
      'O00_ProcessStep': 'done', // 👈 initial step
      'A05_DateD': Timestamp.now(),
    });
    tx.delete(ongoingRef);
  });
}
