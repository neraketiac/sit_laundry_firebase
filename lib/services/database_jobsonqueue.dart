import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/services/database_other_items_onqueue.dart';
import 'package:laundry_firebase/variables/variables.dart';

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

  void addJobsOnQueue(JobsOnQueueModel jOQM, List<OtherItemModel> lAOI) async {
    //String addJobsOnQueue(JobsOnQueueModel jobsOnQueue) {

    DatabaseOtherItemsOnQueue databaseOtherItemsOnQueue;
    print("lAOI size= ${lAOI.length}");
    await _jobsOnQueueRef
        .add(jOQM)
        .then((value) => {
              print("Insert Done.${jOQM.customerId}"),
              updateDocId(JobsOnQueueModel(
                  docId: value.id,
                  dateQ: jOQM.dateO,
                  createdBy: jOQM.createdBy,
                  currentEmpId: jOQM.currentEmpId,
                  customerId: jOQM.customerId,
                  perKilo: jOQM.perKilo,
                  initialKilo: jOQM.initialKilo,
                  initialLoad: jOQM.initialLoad,
                  initialPrice: jOQM.initialPrice,
                  initialOthersPrice: jOQM.initialOthersPrice,
                  finalKilo: jOQM.finalKilo,
                  finalLoad: jOQM.finalLoad,
                  finalPrice: jOQM.finalPrice,
                  finalOthersPrice: jOQM.finalOthersPrice,
                  regular: jOQM.regular,
                  sayosabon: jOQM.sayosabon,
                  others: jOQM.others,
                  addOns: jOQM.addOns,
                  needOn: jOQM.needOn,
                  fold: jOQM.fold,
                  mix: jOQM.mix,
                  basket: jOQM.basket,
                  bag: jOQM.bag,
                  remarks: jOQM.remarks,
                  unpaid: jOQM.unpaid,
                  paidcash: jOQM.paidcash,
                  paidgcash: jOQM.paidgcash,
                  paidgcashverified: jOQM.paidgcashverified,
                  paymentReceivedBy: jOQM.paymentReceivedBy,
                  dateO: jOQM.dateO,
                  paidD: jOQM.paidD,
                  forSorting: jOQM.forSorting,
                  riderPickup: jOQM.riderPickup,
                  jobsId: jOQM.jobsId,
                  waiting: jOQM.waiting,
                  washing: jOQM.washing,
                  drying: jOQM.drying,
                  folding: jOQM.folding,
                  dateD: jOQM.dateD,
                  waitCustomerPickup: jOQM.waitCustomerPickup,
                  waitRiderDelivery: jOQM.waitRiderDelivery,
                  nasaCustomerNa: jOQM.nasaCustomerNa,
                  waitingOneWeek: jOQM.waitingOneWeek,
                  waitingTwoWeeks: jOQM.waitingTwoWeeks,
                  forDisposal: jOQM.forDisposal,
                  disposed: jOQM.disposed)),
              databaseOtherItemsOnQueue = DatabaseOtherItemsOnQueue(value.id),
              print("lAOI size before loop= ${lAOI.length}"),
              lAOI.forEach((addOnItem) async {
                databaseOtherItemsOnQueue.addOtherItems(addOnItem);
              }),
              resetAddOnVar(),
              resetJOQMGlobalVar(),
              resetAddOnsGlobalVar(),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError(
          (error) => print("Failed : $error ${jOQM.customerId}"),
        );
  }

  void updateDocId(JobsOnQueueModel jOQM) async {
    _jobsOnQueueRef
        .doc(jOQM.docId)
        .update(jOQM.toJson())
        .then((value) => {
              print("Update Done updateDocId"),
            })
        .catchError(
          (error) => print("Update Failed : $error"),
        );
  }

  void updateJobsOnQueue(String docId, JobsOnQueueModel jobsOnQueueModel,
      List<OtherItemModel> lAOI) async {
    _jobsOnQueueRef.doc(docId).update(jobsOnQueueModel.toJson());
    DatabaseOtherItemsOnQueue databaseOtherItemsOnQueue;
    databaseOtherItemsOnQueue = DatabaseOtherItemsOnQueue(docId);
    lAOI.forEach((aOI) {
      //if (databaseOtherItems.checkIfDocExists(aOI)) {
      if (aOI.docId != "") {
        //databaseOtherItems.udpateOtherItems(aOI.docId, aOI);
      } else {
        databaseOtherItemsOnQueue.addOtherItems(aOI);
      }
    });
  }

  void deleteJOQ(String docId, List<OtherItemModel> lOIM) {
    DatabaseOtherItemsOnQueue databaseOtherItemsOnQueue =
        DatabaseOtherItemsOnQueue(docId);

    lOIM.forEach((aOIG) {
      print("delete for ongoing docid=${aOIG.docId}");
      if (aOIG.docId != "") {
        databaseOtherItemsOnQueue.deleteOtheritems(aOIG.docId);
        // bDelAddOnsVar = true;
      } else {
        //need to relogin to delete
        // bDelAddOnsVar = false;
      }
    });

    deleteJobsOnQueue(docId);
  }

  void deleteJobsOnQueue(String docId) async {
    _jobsOnQueueRef
        .doc(docId)
        .delete()
        .then((value) => {
              print("Delete JobsOnQueue Done."),
            })
        .catchError(
          (error) => print("Delete Failed : $error"),
        );
  }
}
