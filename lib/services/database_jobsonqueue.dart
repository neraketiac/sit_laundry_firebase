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
            toFirestore: (jOQM, _) => jOQM.toJson());
  }

  Stream<QuerySnapshot> getJobsOnQueue() {
    return _jobsOnQueueRef.orderBy('A1_DateQ', descending: false).snapshots();
  }

  void addJobsOnQueue(
      JobsOnQueueModel jOQM, List<OtherItemModel> listAddOnItems) async {
    //String addJobsOnQueue(JobsOnQueueModel jobsOnQueue) {

    DatabaseOtherItems databaseOtherItems;

    _jobsOnQueueRef
        .add(jOQM)
        .then((value) => {
              print("Insert Done.${jOQM.customerId}"),
              databaseOtherItems = DatabaseOtherItems(value.id),
              listAddOnItems.forEach((addOnItem) {
                databaseOtherItems.addOtherItems(addOnItem);
              }),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError(
          (error) => print("Failed : $error ${jOQM.customerId}"),
        );
  }

  void updateJobsOnQueue(String docId, JobsOnQueueModel jobsOnQueueModel) {
    _jobsOnQueueRef.doc(docId).update(jobsOnQueueModel.toJson());
  }
}
