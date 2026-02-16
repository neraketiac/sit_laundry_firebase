import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';
import 'package:laundry_firebase/variables/newvariables/jobselected_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

class JobModelRepository {
  // JobModelRepository._();
  // static final JobModelRepository instance = JobModelRepository._();

  // /// Single job (nullable until set)
  // JobModel? jobsModel;

  late JobModel jobModel;
  late JobselectedRepository jobselectedRepository = JobselectedRepository();

  JobModelRepository() {
    reset();
  }

  Future<void> reset() async {
    jobModel = JobModel(
        docId: '',
        jobId: 0,
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
        pricingSetup: '',
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

  JobModel? getJobsModel() {
    return jobModel;
  }

  /////////////////////////////////////////////////////////////
  //                          ITEMS                          //
  /////////////////////////////////////////////////////////////

  // Add item
  void addItem(OtherItemModel value) {
    jobModel.items.add(value);
  }

  // Delete item by index
  void deleteItemAt(int value) {
    if (value >= 0 && value < jobModel.items.length) {
      jobModel.items.removeAt(value);
    }
  }

  // Delete item by matching condition
  void deleteItem(OtherItemModel value) {
    jobModel.items.remove(value);
  }

  // Clear all items
  void clearItems() {
    jobModel.items.clear();
  }

  void addFinalPrice(int value) {
    jobModel.finalPrice += value;
  }

/////////////////////////////////////////////////////////////
//                          GETTER                         //
//                          JOBMODEL                       //
/////////////////////////////////////////////////////////////

  JobModel get jobModelData => jobModel;

  String get docId => jobModel.docId;
  int get jobsId => jobModel.jobId;
  Timestamp get dateQ => jobModel.dateQ;
  Timestamp get needOn => jobModel.needOn;
  Timestamp get dateO => jobModel.dateO;
  Timestamp get paidD => jobModel.paidD;
  Timestamp get dateD => jobModel.dateD;
  String get createdBy => jobModel.createdBy;
  String get currentEmpId => jobModel.currentEmpId;
  int get customerId => jobModel.customerId;
  String get customerName => jobModel.customerName;
  bool get forSorting => jobModel.forSorting;
  bool get riderPickup => jobModel.riderPickup;
  bool get perKilo => jobModel.perKilo;
  bool get perLoad => jobModel.perLoad;
  double get finalKilo => jobModel.finalKilo;
  int get finalLoad => jobModel.finalLoad;
  int get finalPrice => jobModel.finalPrice;
  int get promoCounter => jobModel.promoCounter;
  String get pricingSetup => jobModel.pricingSetup;
  bool get regular => jobModel.regular;
  bool get sayosabon => jobModel.sayosabon;
  bool get addOn => jobModel.addOn;
  bool get fold => jobModel.fold;
  bool get mix => jobModel.mix;
  int get basket => jobModel.basket;
  int get ebag => jobModel.ebag;
  int get sako => jobModel.sako;
  bool get unpaid => jobModel.unpaid;
  bool get paidCash => jobModel.paidCash;
  bool get paidGCash => jobModel.paidGCash;
  bool get partialPaidCash => jobModel.partialPaidCash;
  bool get partialPaidGCash => jobModel.partialPaidGCash;
  int get partialPaidCashAmount => jobModel.partialPaidCashAmount;
  int get partialPaidGCashAmount => jobModel.partialPaidGCashAmount;
  bool get paidGCashVerified => jobModel.paidGCashverified;
  String get paymentReceivedBy => jobModel.paymentReceivedBy;
  String get remarks => jobModel.remarks;
  List<OtherItemModel> get items => jobModel.items;
  String get processStep => jobModel.processStep;
  bool get forDisposal => jobModel.forDisposal;
  bool get disposed => jobModel.disposed;

  /////////////////////////////////////////////////////////////
  //                          SETTER                         //
  //                          JOBMODEL                       //
  /////////////////////////////////////////////////////////////

  void setJobModel(JobModel value) {
    jobModel = value;
  }

  void setPackage(int value) {
    regular = value == regularPackage;
    sayosabon = value == sayoSabonPackage;
    addOn = value == othersPackage;
  }

  set jobModelData(JobModel value) => jobModel = value;
  set docId(String value) => jobModel.docId = value;
  set jobsId(int value) => jobModel.jobId = value;
  set dateQ(Timestamp value) => jobModel.dateQ = value;
  set needOn(Timestamp value) => jobModel.needOn = value;
  set dateO(Timestamp value) => jobModel.dateO = value;
  set paidD(Timestamp value) => jobModel.paidD = value;
  set dateD(Timestamp value) => jobModel.dateD = value;
  set createdBy(String value) => jobModel.createdBy = value;
  set currentEmpId(String value) => jobModel.currentEmpId = value;
  set customerId(int value) => jobModel.customerId = value;
  set customerName(String value) => jobModel.customerName = value;
  set forSorting(bool value) => jobModel.forSorting = value;
  set riderPickup(bool value) => jobModel.riderPickup = value;
  set perKilo(bool value) => jobModel.perKilo = value;
  set perLoad(bool value) => jobModel.perLoad = value;
  set finalKilo(double value) => jobModel.finalKilo = value;
  set finalLoad(int value) => jobModel.finalLoad = value;
  set finalPrice(int value) => jobModel.finalPrice = value;
  set promoCounter(int value) => jobModel.promoCounter = value;
  set pricingSetup(String value) => jobModel.pricingSetup = value;
  set regular(bool value) => jobModel.regular = value;
  set sayosabon(bool value) => jobModel.sayosabon = value;
  set addOn(bool value) => jobModel.addOn = value;
  set fold(bool value) => jobModel.fold = value;
  set mix(bool value) => jobModel.mix = value;
  set basket(int value) => jobModel.basket = value;
  set ebag(int value) => jobModel.ebag = value;
  set sako(int value) => jobModel.sako = value;
  set unpaid(bool value) => jobModel.unpaid = value;
  set paidCash(bool value) => jobModel.paidCash = value;
  set paidGCash(bool value) => jobModel.paidGCash = value;
  set partialPaidCash(bool value) => jobModel.partialPaidCash = value;
  set partialPaidGCash(bool value) => jobModel.partialPaidGCash = value;
  set partialPaidCashAmount(int value) =>
      jobModel.partialPaidCashAmount = value;
  set partialPaidGCashAmount(int value) =>
      jobModel.partialPaidGCashAmount = value;
  set paidGCashVerified(bool value) => jobModel.paidGCashverified = value;
  set paymentReceivedBy(String value) => jobModel.paymentReceivedBy = value;
  set remarks(String value) => jobModel.remarks = value;
  set items(List<OtherItemModel> value) => jobModel.items = value;
  set processStep(String value) => jobModel.processStep = value;
  set forDisposal(bool value) => jobModel.forDisposal = value;
  set disposed(bool value) => jobModel.disposed = value;

  /////////////////////////////////////////////////////////////
  //                          ITEMS                          //
  //                          LISTSELECTED                   //
  /////////////////////////////////////////////////////////////

  // Add item
  void addListSelectedItemModel(OtherItemModel value) {
    jobselectedRepository.listSelectedItemModel.add(value);
  }

  // Delete item by index
  void delListSelectedItemModel(int value) {
    if (value >= 0 &&
        value < jobselectedRepository.listSelectedItemModel.length) {
      jobselectedRepository.listSelectedItemModel.removeAt(value);
    }
  }

  // Delete item by matching condition
  void delItemListSelectedItemModel(OtherItemModel value) {
    jobselectedRepository.listSelectedItemModel.remove(value);
  }

  // Clear all items
  void clearListSelectedItemModel() {
    jobselectedRepository.listSelectedItemModel.clear();
  }

  /////////////////////////////////////////////////////////////
  //                          SETTER                         //
  //                          JOBSELECTED                    //
  /////////////////////////////////////////////////////////////
  set selectedRiderPickup(int value) =>
      jobselectedRepository.selectedRiderPickup = value;
  set selectedPackage(int value) =>
      jobselectedRepository.selectedPackage = value;
  set selectedPackagePrev(int value) =>
      jobselectedRepository.selectedPackagePrev = value;
  set selectedOthers(int value) => jobselectedRepository.selectedOthers = value;
  set isPerKg(bool value) => jobselectedRepository.isPerKg = value;
  set quantityKg(double value) => jobselectedRepository.quantityKg = value;
  set quantityLoad(int value) => jobselectedRepository.quantityLoad = value;
  set totalPriceRegSS(int value) =>
      jobselectedRepository.totalPriceRegSS = value;
  set totalPriceShortCutRegSS(int value) =>
      jobselectedRepository.totalPriceShortCutRegSS = value;
  set totalPriceOthers(int value) =>
      jobselectedRepository.totalPriceOthers = value;
  set pricePerSet(int value) => jobselectedRepository.pricePerSet = value;
  set maxPartial(int value) => jobselectedRepository.maxPartial = value;
  set selectedItemModel(OtherItemModel value) =>
      jobselectedRepository.selectedItemModel = value;
  set selectedOthersShortCut(int value) =>
      jobselectedRepository.selectedOthersShortCut = value;
  // set selectedPaidUnpaid(int value) =>
  //     jobselectedRepository.selectedPaidUnpaid = value;
  set selectedPaidPartialCash(bool value) =>
      jobselectedRepository.selectedPaidPartialCash = value;
  set selectedPaidPartialGCash(bool value) =>
      jobselectedRepository.selectedPaidPartialGCash = value;
  set selectedPaidGCashVerified(bool value) =>
      jobselectedRepository.selectedPaidGCashVerified = value;
  set selectedFold(bool value) => jobselectedRepository.selectedFold = value;
  set selectedMix(bool value) => jobselectedRepository.selectedMix = value;
  set basketCount(int value) => jobselectedRepository.basketCount = value;
  set ecoBagCount(int value) => jobselectedRepository.ecoBagCount = value;
  set sakoCount(int value) => jobselectedRepository.sakoCount = value;
  set addFabCount(int value) => jobselectedRepository.addFabCount = value;
  set addExtraDryCount(int value) =>
      jobselectedRepository.addExtraDryCount = value;
  set addExtraWashCount(int value) =>
      jobselectedRepository.addExtraWashCount = value;
  set addExtraSpinCount(int value) =>
      jobselectedRepository.addExtraSpinCount = value;
  set listSelectedItemModel(List<OtherItemModel> value) =>
      jobselectedRepository.listSelectedItemModel = value;

  /////////////////////////////////////////////////////////////
  //                          GETTER                         //
  //                        JOBSELECTED                      //
  /////////////////////////////////////////////////////////////

  ///expose controller
  TextEditingController get customerAmountVar =>
      jobselectedRepository.customerAmountVar;
  TextEditingController get customerNameVar =>
      jobselectedRepository.customerNameVar;
  TextEditingController get partialCashAmountVar =>
      jobselectedRepository.partialCashAmountVar;
  TextEditingController get partialGCashAmountVar =>
      jobselectedRepository.partialGCashAmountVar;
  TextEditingController get remarksVar => jobselectedRepository.remarksVar;

  // String get customerAmountVar => jobselectedRepository.customerAmountVar.text;
  // String get customerNameVar => jobselectedRepository.customerNameVar.text;
  // String get partialCashAmountVar =>
  //     jobselectedRepository.partialCashAmountVar.text;
  // String get partialGCashAmountVar =>
  //     jobselectedRepository.partialGCashAmountVar.text;
  // String get remarksVar => jobselectedRepository.remarksVar.text;

  int get selectedRiderPickup => jobselectedRepository.selectedRiderPickup;
  int get selectedPackage => jobselectedRepository.selectedPackage;
  int get selectedPackagePrev => jobselectedRepository.selectedPackagePrev;
  int get selectedOthers => jobselectedRepository.selectedOthers;
  bool get isPerKg => jobselectedRepository.isPerKg;
  double get quantityKg => jobselectedRepository.quantityKg;
  int get quantityLoad => jobselectedRepository.quantityLoad;
  int get totalPriceRegSS => jobselectedRepository.totalPriceRegSS;
  int get totalPriceShortCutRegSS =>
      jobselectedRepository.totalPriceShortCutRegSS;
  int get totalPriceOthers => jobselectedRepository.totalPriceOthers;
  int get pricePerSet => jobselectedRepository.pricePerSet;
  int get maxPartial => jobselectedRepository.maxPartial;
  OtherItemModel get selectedItemModel =>
      jobselectedRepository.selectedItemModel;
  int get selectedOthersShortCut =>
      jobselectedRepository.selectedOthersShortCut;
  //int get selectedPaidUnpaid => jobselectedRepository.selectedPaidUnpaid;
  bool get selectedPaidPartialCash =>
      jobselectedRepository.selectedPaidPartialCash;
  bool get selectedPaidPartialGCash =>
      jobselectedRepository.selectedPaidPartialGCash;
  bool get selectedPaidGCashVerified =>
      jobselectedRepository.selectedPaidGCashVerified;
  bool get selectedFold => jobselectedRepository.selectedFold;
  bool get selectedMix => jobselectedRepository.selectedMix;
  int get basketCount => jobselectedRepository.basketCount;
  int get ecoBagCount => jobselectedRepository.ecoBagCount;
  int get sakoCount => jobselectedRepository.sakoCount;
  int get addFabCount => jobselectedRepository.addFabCount;
  int get addExtraDryCount => jobselectedRepository.addExtraDryCount;
  int get addExtraWashCount => jobselectedRepository.addExtraWashCount;
  int get addExtraSpinCount => jobselectedRepository.addExtraSpinCount;
  List<OtherItemModel> get listSelectedItemModel =>
      jobselectedRepository.listSelectedItemModel;
}
