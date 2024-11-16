import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/jobsonqueue.dart';
import 'package:laundry_firebase/services/navigator_key.dart';

const String JOBS_ON_QUEUE_REF = "JobsOnQueue";
const Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

class JobsOnQueueDataService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _jobsOnQueueRef;

  JobsOnQueueDataService() {
    _jobsOnQueueRef =
        _firestore.collection(JOBS_ON_QUEUE_REF).withConverter<JobsOnQueue>(
            fromFirestore: (snapshots, _) => JobsOnQueue.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (jobsOnQueue, _) => jobsOnQueue.toJson());
  }

  Stream<QuerySnapshot> getJobsOnQueue() {
    return _jobsOnQueueRef.snapshots();
  }

  void addJobsOnQueue(JobsOnQueue jobsOnQueue) async {
    _jobsOnQueueRef
        .add(jobsOnQueue)
        .then((value) => {
              messageResult("Insert Done.${jobsOnQueue.customer}"),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => messageResult("Failed : $error"));
  }

  void updateJobsOnQueue(String jobsOnQueueId, JobsOnQueue jobsOnQueue) {
    _jobsOnQueueRef.doc(jobsOnQueueId).update(jobsOnQueue.toJson());
  }

  void messageResult(String sMsg) {
    showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) => AlertDialog(
              content: Text(sMsg),
              actions: [
                MaterialButton(
                  onPressed: () => Navigator.pop(context),
                  color: _gcButtons,
                  child: const Text("Ok"),
                ),
              ],
            ));
  }
}
