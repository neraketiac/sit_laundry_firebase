import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/services/database_other_items.dart';
import 'package:laundry_firebase/services/navigator_key.dart';

const String JOBS_ON_QUEUE_REF = "JobsOnQueue";
const Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

class DatabaseJobsOnQueue {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _jobsOnQueueRef;

  DatabaseJobsOnQueue() {
    _jobsOnQueueRef = _firestore
        .collection(JOBS_ON_QUEUE_REF)
        .withConverter<JobsOnQueueModel>(
            fromFirestore: (snapshots, _) => JobsOnQueueModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (jobsOnQueueModel1, _) => jobsOnQueueModel1.toJson());
  }

  Stream<QuerySnapshot> getJobsOnQueue() {
    return _jobsOnQueueRef.snapshots();
  }

  void addJobsOnQueue(JobsOnQueueModel jobsOnQueueModel3,
      List<OtherItemModel> thisListAddOnItems) async {
    //String addJobsOnQueue(JobsOnQueueModel jobsOnQueue) {

    DatabaseOtherItems databaseOtherItems;

    _jobsOnQueueRef
        .add(jobsOnQueueModel3)
        .then((value) => {
              print("Insert Done.${jobsOnQueueModel3.customer}"),
              databaseOtherItems = DatabaseOtherItems(value.id),
              thisListAddOnItems.forEach((listOtherItemModel) {
                databaseOtherItems.addOtherItems(listOtherItemModel);
              }),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError(
          (error) => print("Failed : $error ${jobsOnQueueModel3.customer}"),
        );
  }

  void updateJobsOnQueue(
      String jobsOnQueueId, JobsOnQueueModel jobsOnQueueModel4) {
    _jobsOnQueueRef.doc(jobsOnQueueId).update(jobsOnQueueModel4.toJson());
  }
}
