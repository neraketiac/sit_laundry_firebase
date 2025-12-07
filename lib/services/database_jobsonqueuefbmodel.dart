import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/jobsonqueuemodelfbmodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/services/database_other_items_onqueue.dart';
import 'package:laundry_firebase/variables/variables.dart';

const String _jobOnQueueFbModelRef = "JobsOnQueueFBModel";
const Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

class DatabaseJobsOnQueueFBModel {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _jobsOnQueueFBModelRef;

  DatabaseJobsOnQueueFBModel() {
    _jobsOnQueueFBModelRef = _firestore
        .collection(_jobOnQueueFbModelRef)
        .withConverter<JobsOnQueueFBModel>(
            fromFirestore: (snapshots, _) => JobsOnQueueFBModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (jOQM, _) => jOQM.toJson());
  }

  Stream<QuerySnapshot> getJobsOnQueueFBM() {
    return _jobsOnQueueFBModelRef.snapshots();
  }

  void addJobsOnQueueFBM(JobsOnQueueFBModel jOQFBM) async {
    
    await _jobsOnQueueFBModelRef
        .add(jOQFBM)
        .then((value) => {
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError(
          (error) => print("Failed : $error ${jOQFBM.docId}"),
        );
  }

  void updateDocId(JobsOnQueueFBModel jOQFBM) async {
    _jobsOnQueueFBModelRef
        .doc(jOQFBM.docId)
        .update(jOQFBM.toJson())
        .then((value) => {
              print("Update Done updateDocId"),
            })
        .catchError(
          (error) => print("Update Failed : $error"),
        );
  }

  void updateJobsOnQueueFBM(String docId, JobsOnQueueFBModel jobsOnQueueFBModel) async {
    _jobsOnQueueFBModelRef.doc(docId).update(jobsOnQueueFBModel.toJson());
  }

  void deleteJOQ(String docId) {
    deleteJobsOnQueueFBM(docId);
  }

  void deleteJobsOnQueueFBM(String docId) async {
    _jobsOnQueueFBModelRef
        .doc(docId)
        .delete()
        .then((value) => {
              print("Delete JobsOnQueueFBM Done."),
            })
        .catchError(
          (error) => print("Delete Failed : $error"),
        );
  }
}
