import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/oldmodels/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';
import 'package:laundry_firebase/services/oldservices/database_other_items.dart';
import 'package:laundry_firebase/services/oldservices/navigator_key.dart';
import 'package:laundry_firebase/variables/oldvariables/vairables_jobsonqueue.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

const String JOBS_ON_GOING_REF = "JobsOnGoing";
const Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

class DatabaseJobsOnGoing {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _jobsOnGoingRef;

  DatabaseJobsOnGoing() {
    _jobsOnGoingRef = _firestore
        .collection(JOBS_ON_GOING_REF)
        .withConverter<JobsOnQueueModel>(
            fromFirestore: (snapshots, _) => JobsOnQueueModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (jOQM, _) => jOQM.toJson());
  }

  Stream<QuerySnapshot> getJobsOnGoing() {
    return _jobsOnGoingRef.orderBy('D30_JobsId', descending: false).snapshots();
  }

  void addJobsOnGoing(JobsOnQueueModel jOQM, List<OtherItemModel> lAOI) async {
    //String addJobsOnQueue(JobsOnQueueModel jobsOnQueue) {

    DatabaseOtherItems databaseOtherItems;

    _jobsOnGoingRef
        .add(jOQM)
        .then((value) => {
              print(
                  "addJobsOnGoing Insert Done.${jOQM.customerId} ${jOQM.jobsId}"),
              deleteJOQVar(jOQM.docId, lAOI),
              updateDocId(JobsOnQueueModel(
                  docId: value.id,
                  dateQ: jOQM.dateO,
                  createdBy: jOQM.createdBy,
                  currentEmpId: jOQM.currentEmpId,
                  customerId: jOQM.customerId,
                  customerName: jOQM.customerName,
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
                  paymentLaundryGenerated: jOQM.paymentLaundryGenerated,
                  dateO: jOQM.dateO,
                  paidD: jOQM.paidD,
                  forSorting: jOQM.forSorting,
                  riderPickup: jOQM.riderPickup,
                  initTagForDeliveryWhenDone: jOQM.initTagForDeliveryWhenDone,
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
              databaseOtherItems = DatabaseOtherItems("JobsOnGoing", value.id),
              lAOI.forEach((addOnItem) {
                databaseOtherItems.addOtherItems(addOnItem);
              }),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError(
          (error) => print("Failed : $error ${jOQM.customerId}"),
        );
  }

  void updateDocId(JobsOnQueueModel jOQM) async {
    _jobsOnGoingRef
        .doc(jOQM.docId)
        .update(jOQM.toJson())
        .then((value) => {
              print("Update Done."),
            })
        .catchError(
          (error) => print("Update Failed : $error"),
        );
  }

  void updateJobsOnGoing(String docId, JobsOnQueueModel jobsOnQueueModel,
      List<OtherItemModel> lAOI) async {
    _jobsOnGoingRef.doc(docId).update(jobsOnQueueModel.toJson());
    DatabaseOtherItems databaseOtherItems =
        DatabaseOtherItems("JobsOnGoing", docId);
    lAOI.forEach((aOI) {
      //if (databaseOtherItems.checkIfDocExists(aOI)) {
      if (aOI.docId != "") {
        //databaseOtherItems.udpateOtherItems(aOI.docId, aOI);
      } else {
        databaseOtherItems.addOtherItems(aOI);
      }
    });
  }

  void deleteJobsOnGoing(String docId) async {
    _jobsOnGoingRef
        .doc(docId)
        .delete()
        .then((value) => {
              print("Delete JobsOnGoing Done."),
            })
        .catchError(
          (error) => print("Delete Failed : $error"),
        );
  }
}
