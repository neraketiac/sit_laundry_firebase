import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/services/database_other_items.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_jobsongoing.dart';

const String JOBS_DONE_REF = "JobsDone";
const Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

class DatabaseJobsDone {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _jobsDoneRef;

  DatabaseJobsDone() {
    _jobsDoneRef =
        _firestore.collection(JOBS_DONE_REF).withConverter<JobsOnQueueModel>(
            fromFirestore: (snapshots, _) => JobsOnQueueModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (jOQM, _) => jOQM.toJson());
  }

  Stream<QuerySnapshot> getJobsDone() {
    return _jobsDoneRef.orderBy("D7_DateD", descending: false).snapshots();
  }

  Stream<QuerySnapshot> getJobsDoneFilter(String columnTrue) {
    return _jobsDoneRef
        .where(columnTrue, isEqualTo: true)
        .orderBy('D7_DateD', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getJobsDoneForCustomerPickup() {
    return _jobsDoneRef
        .where('D8_WaitCustomerPickup', isEqualTo: true)
        .orderBy('D7_DateD', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getJobsDoneWaitRiderDelivery() {
    return _jobsDoneRef
        .where('D9_WaitRiderDelivery', isEqualTo: true)
        .orderBy('D7_DateD', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getJobsDoneNasaCustomerNa() {
    return _jobsDoneRef
        .where('E1_NasaCustomerNa', isEqualTo: true)
        .orderBy('D7_DateD', descending: false)
        .snapshots();
  }

  void addJobsDone(JobsOnQueueModel jOQM, List<OtherItemModel> lAOI) async {
    //String addJobsOnQueue(JobsOnQueueModel jobsOnQueue) {

    DatabaseOtherItems databaseOtherItems;

    _jobsDoneRef
        .add(jOQM)
        .then((value) => {
              print("Insert Done.${jOQM.customerId}"),
              deleteJOGVar(jOQM.docId, lAOI),
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
              databaseOtherItems = DatabaseOtherItems("JobsDone", value.id),
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
    _jobsDoneRef
        .doc(jOQM.docId)
        .update(jOQM.toJson())
        .then((value) => {
              print("Update Done."),
            })
        .catchError(
          (error) => print("Update Failed : $error"),
        );
  }

  void updateJobsDone(String docId, JobsOnQueueModel jobsOnQueueModel,
      List<OtherItemModel> lAOI) async {
    _jobsDoneRef.doc(docId).update(jobsOnQueueModel.toJson());
    // DatabaseOtherItemsOnGoing databaseOtherItemsOnGoing;
    // databaseOtherItemsOnGoing = DatabaseOtherItemsOnGoing(docId);
    DatabaseOtherItems databaseOtherItems =
        DatabaseOtherItems("JobsDone", docId);
    lAOI.forEach((aOI) {
      //if (databaseOtherItems.checkIfDocExists(aOI)) {
      if (aOI.docId != "") {
        //databaseOtherItems.udpateOtherItems(aOI.docId, aOI);
      } else {
        databaseOtherItems.addOtherItems(aOI);
      }
    });
  }
}
