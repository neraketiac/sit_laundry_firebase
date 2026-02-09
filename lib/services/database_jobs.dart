import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/jobsmodel.dart';

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
  Future<bool> add(JobsModel job) async {
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
  Future<JobsModel?> get(String docId) async {
    final doc = await _ref.doc(docId).get();
    if (!doc.exists || doc.data() == null) return null;
    return JobsModel.fromJson(doc.data()!);
  }

  /// 🔄 Stream all queued jobs
  Stream<List<JobsModel>> streamAll() {
    return _ref.orderBy('A00_JobsId').snapshots().map(
          (s) => s.docs.map((d) => JobsModel.fromJson(d.data())).toList(),
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
      'A00_JobsId': jobId,
    });
  }

  Future<void> updatePaidUnpaid(JobsModel jM) async {
    await _ref.doc(jM.docId).update(jM.toJson());
  }

  Future<bool> update(JobsModel jM) async {
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
  Stream<List<JobsModel>> streamAll() {
    return _ref.snapshots().map(
          (s) => s.docs.map((d) => JobsModel.fromJson(d.data())).toList(),
        );
  }

  /// 🔁 Update process step
  /// Values: 'washing' | 'drying' | 'folding'
  Future<void> updateStep(String docId, String step) async {
    await _ref.doc(docId).update({
      'processStep': step,
    });
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
  Stream<List<JobsModel>> streamAll() {
    return _ref.snapshots().map(
          (s) => s.docs.map((d) => JobsModel.fromJson(d.data())).toList(),
        );
  }
}

/// 🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥
/// 🔥 JOB MOVEMENT (TRANSACTIONS)
/// 🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥

/// ▶ Queue → Ongoing (start washing)
Future<void> moveQueueToOngoing(String docId) async {
  final firestore = FirebaseFirestore.instance;

  await firestore.runTransaction((tx) async {
    final queueRef = firestore.collection(JOBS_QUEUE_REF).doc(docId);
    final ongoingRef = firestore.collection(JOBS_ONGOING_REF).doc(docId);

    final snapshot = await tx.get(queueRef);
    if (!snapshot.exists) return;

    tx.set(ongoingRef, {
      ...snapshot.data()!,
      'processStep': 'washing', // 👈 initial step
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

    tx.set(doneRef, snapshot.data()!);
    tx.delete(ongoingRef);
  });
}
