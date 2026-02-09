import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/jobsmodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/variables/variables.dart';

class JobsModelRepository {
  JobsModelRepository._();
  static final JobsModelRepository instance = JobsModelRepository._();

  /// Single job (nullable until set)
  JobsModel? jobsModel;

  Future<void> reset() async {
    jobsModel = JobsModel(
        docId: '',
        jobsId: 0,
        dateQ: timestamp1900,
        needOn: timestamp1900,
        dateO: timestamp1900,
        paidD: timestamp1900,
        dateD: timestamp1900,
        createdBy: '',
        currentEmpId: '',
        customerId: 0,
        customerName: '',
        forSorting: false,
        riderPickup: false,
        perKilo: false,
        perLoad: false,
        finalKilo: 0,
        finalLoad: 0,
        finalPrice: 0,
        promoCounter: 0,
        regular: false,
        sayosabon: false,
        addOn: false,
        fold: true,
        mix: true,
        basket: 0,
        ebag: 0,
        sako: 0,
        unpaid: true,
        paidCash: false,
        paidGCash: false,
        partialPaidCash: false,
        partialPaidGCash: false,
        partialPaidCashAmount: 0,
        partialPaidGCashAmount: 0,
        paidGCashverified: false,
        paymentReceivedBy: '',
        remarks: '',
        items: [OtherItemModel.makeEmpty()],
        processStep: '',
        forDisposal: false,
        disposed: false);
  }

  // JobsModel getJobsModel() => jobsModel;

  JobsModel? getJobsModel() {
    return jobsModel;
  }

  void setJobModel(JobsModel jobsModel) {
    jobsModel = jobsModel;
  }

  void setPackage(int selectedPackage) {
    setRegular = selectedPackage == regularPackage;
    setSayosabon = selectedPackage == sayoSabonPackage;
    setAddOn = selectedPackage == othersPackage;
  }

  // Add item
  void addItem(OtherItemModel item) {
    jobsModel!.items.add(item);
  }

  // Delete item by index
  void deleteItemAt(int index) {
    if (index >= 0 && index < jobsModel!.items.length) {
      jobsModel!.items.removeAt(index);
    }
  }

  // Delete item by matching condition
  void deleteItem(OtherItemModel item) {
    jobsModel!.items.remove(item);
  }

  // Clear all items
  void clearItems() {
    jobsModel!.items.clear();
  }

  void addFinalPrice(int value) {
    jobsModel!.finalPrice += value;
  }

  void subFinalPrice(int value) {
    jobsModel!.finalPrice -= value;
  }

  int getJobsId() {
    return jobsModel!.jobsId;
  }

  int getFinalPrice() {
    return jobsModel!.finalPrice;
  }

  int getCustomerId() {
    return jobsModel!.customerId;
  }

  bool getUnpaid() {
    return jobsModel!.unpaid;
  }

  bool getPaidCash() {
    return jobsModel!.paidCash;
  }

  bool getPaidGCash() {
    return jobsModel!.paidGCash;
  }

  bool getPartialPaidCash() {
    return jobsModel!.partialPaidCash;
  }

  bool getPartialPaidGCash() {
    return jobsModel!.partialPaidGCash;
  }

  int getPartialPaidCashAmount() {
    return jobsModel!.partialPaidCashAmount;
  }

  int getPartialPaidGCashAmount() {
    return jobsModel!.partialPaidCashAmount;
  }

  bool getGCashVerified() {
    return jobsModel!.paidGCashverified;
  }

  set setDocId(String value) => jobsModel!.docId = value;
  set setJobsId(int value) => jobsModel!.jobsId = value;
  set setDateQ(Timestamp value) => jobsModel!.dateQ = value;
  set setNeedOn(Timestamp value) => jobsModel!.needOn = value;
  set setDateO(Timestamp value) => jobsModel!.dateO = value;
  set setPaidD(Timestamp value) => jobsModel!.paidD = value;
  set setDateD(Timestamp value) => jobsModel!.dateD = value;
  set setCreatedBy(String value) => jobsModel!.createdBy = value;
  set setCurrentEmpId(String value) => jobsModel!.currentEmpId = value;
  void setCustomerId(int value) => jobsModel!.customerId = value;
  void setCustomerName(String value) => jobsModel!.customerName = value;
  set setForSorting(bool value) => jobsModel!.forSorting = value;
  set setRiderPickup(bool value) => jobsModel!.riderPickup = value;
  set setPerKilo(bool value) => jobsModel!.perKilo = value;
  set setPerLoad(bool value) => jobsModel!.perLoad = value;
  set setFinalKilo(double value) => jobsModel!.finalKilo = value;
  set setFinalLoad(int value) => jobsModel!.finalLoad = value;
  set setFinalPrice(int value) => jobsModel!.finalPrice = value;
  set setPromoCounter(int value) => jobsModel!.promoCounter = value;
  set setRegular(bool value) => jobsModel!.regular = value;
  set setSayosabon(bool value) => jobsModel!.sayosabon = value;
  set setAddOn(bool value) => jobsModel!.addOn = value;
  set setFold(bool value) => jobsModel!.fold = value;
  set setMix(bool value) => jobsModel!.mix = value;
  set setBasket(int value) => jobsModel!.basket = value;
  set setEbag(int value) => jobsModel!.ebag = value;
  set setSako(int value) => jobsModel!.sako = value;
  set setUnpaid(bool value) => jobsModel!.unpaid = value;
  set setPaidCash(bool value) => jobsModel!.paidCash = value;
  set setPaidGCash(bool value) => jobsModel!.paidGCash = value;
  set setPartialPaidCash(bool value) => jobsModel!.partialPaidCash = value;
  set setPartialPaidGCash(bool value) => jobsModel!.partialPaidGCash = value;
  set setPartialPaidCashAmount(int value) =>
      jobsModel!.partialPaidCashAmount = value;
  set setPartialPaidGCashAmount(int value) =>
      jobsModel!.partialPaidGCashAmount = value;
  set setPaidGCashVerified(bool value) => jobsModel!.paidGCashverified = value;
  set setPaymentReceivedBy(String value) =>
      jobsModel!.paymentReceivedBy = value;
  set setRemarks(String value) => jobsModel!.remarks = value;
  set setItems(List<OtherItemModel> value) => jobsModel!.items = value;
  set setProcessStep(String value) => jobsModel!.processStep = value;
  set setForDisposal(bool value) => jobsModel!.forDisposal = value;
  set setDisposed(bool value) => jobsModel!.disposed = value;
}
