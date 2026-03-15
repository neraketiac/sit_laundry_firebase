import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/jobs/repository/jobselected_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';

class JobModelRepository {
  // JobModelRepository._();
  // static final JobModelRepository instance = JobModelRepository._();

  // /// Single job (nullable until set)
  // JobModel? jobsModel;

  late JobModel jobModel;
  late JobselectedRepository jobselectedRepository = JobselectedRepository();

  Future<void> reset() async {
    jobModel = JobModel(
      docId: '',
      jobId: 0,
      dateQ: timestamp1900,
      needOn: timestamp1900,
      dateO: timestamp1900,
      paidD: timestamp1900,
      dateD: timestamp1900,
      dateC: timestamp1900,
      customerPickupDate: timestamp1900,
      riderDeliveryDate: timestamp1900,
      createdBy: '',
      currentEmpId: '',
      customerId: 0,
      customerName: '',
      address: '',
      forSorting: false,
      riderPickup: false,
      isCustomerPickedUp: false,
      isDeliveredToCustomer: false,
      perKilo: false,
      perLoad: true,
      finalKilo: 0,
      finalLoad: 0,
      finalPrice: 0,
      promoCounter: 0,
      pricingSetup: '',
      regular: true,
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
      paidGCashverified: false,
      paidCashAmount: 0,
      paidGCashAmount: 0,
      paymentReceivedBy: '',
      remarks: '',
      items: [],
      processStep: '',
      allStatus: 0,
      forDisposal: false,
      disposed: false,
      isSyncToDB2: false,
      promoErrorCode: 99,
    );

    jobselectedRepository.reset();
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
  int get jobId => jobModel.jobId;
  Timestamp get dateQ => jobModel.dateQ;
  Timestamp get needOn => jobModel.needOn;
  Timestamp get dateO => jobModel.dateO;
  Timestamp get paidD => jobModel.paidD;
  Timestamp get dateD => jobModel.dateD;
  Timestamp get dateC => jobModel.dateC;
  Timestamp get customerPickupDate => jobModel.customerPickupDate;
  Timestamp get riderDeliveryDate => jobModel.riderDeliveryDate;
  String get createdBy => jobModel.createdBy;
  String get currentEmpId => jobModel.currentEmpId;
  int get customerId => jobModel.customerId;
  String get customerName => jobModel.customerName;
  String get address => jobModel.address;
  bool get forSorting => jobModel.forSorting;
  bool get riderPickup => jobModel.riderPickup;
  bool get isCustomerPickedUp => jobModel.isCustomerPickedUp;
  bool get isDeliveredToCustomer => jobModel.isDeliveredToCustomer;
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
  bool get paidGCashVerified => jobModel.paidGCashverified;
  int get paidCashAmount => jobModel.paidCashAmount;
  int get paidGCashAmount => jobModel.paidGCashAmount;
  String get paymentReceivedBy => jobModel.paymentReceivedBy;
  String get remarks => jobModel.remarks;
  List<OtherItemModel> get items => jobModel.items;
  String get processStep => jobModel.processStep;
  double get allStatus => jobModel.allStatus;
  bool get forDisposal => jobModel.forDisposal;
  bool get disposed => jobModel.disposed;
  bool get isSyncToDB2 => jobModel.isSyncToDB2;
  int get promoErrorCode => jobModel.promoErrorCode;

  /////////////////////////////////////////////////////////////
  //                          SETTER                         //
  //                          JOBMODEL                       //
  /////////////////////////////////////////////////////////////

  void setJobModel(JobModel value) {
    jobModel = value;
  }

  set jobModelData(JobModel value) => jobModel = value;
  set docId(String value) => jobModel.docId = value;
  set jobId(int value) => jobModel.jobId = value;
  set dateQ(Timestamp value) => jobModel.dateQ = value;
  set needOn(Timestamp value) => jobModel.needOn = value;
  set dateO(Timestamp value) => jobModel.dateO = value;
  set paidD(Timestamp value) => jobModel.paidD = value;
  set dateD(Timestamp value) => jobModel.dateD = value;
  set dateC(Timestamp value) => jobModel.dateC = value;
  set customerPickupDate(Timestamp value) =>
      jobModel.customerPickupDate = value;
  set riderDeliveryDate(Timestamp value) => jobModel.riderDeliveryDate = value;
  set createdBy(String value) => jobModel.createdBy = value;
  set currentEmpId(String value) => jobModel.currentEmpId = value;
  set customerId(int value) => jobModel.customerId = value;
  set customerName(String value) => jobModel.customerName = value;
  set address(String value) => jobModel.address = value;
  set forSorting(bool value) => jobModel.forSorting = value;
  set riderPickup(bool value) => jobModel.riderPickup = value;
  set isCustomerPickedUp(bool value) => jobModel.isCustomerPickedUp = value;
  set isDeliveredToCustomer(bool value) =>
      jobModel.isDeliveredToCustomer = value;
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
  set paidGCashVerified(bool value) => jobModel.paidGCashverified = value;
  set paidCashAmount(int value) => jobModel.paidCashAmount = value;
  set paidGCashAmount(int value) => jobModel.paidGCashAmount = value;
  set paymentReceivedBy(String value) => jobModel.paymentReceivedBy = value;
  set remarks(String value) => jobModel.remarks = value;
  set items(List<OtherItemModel> value) => jobModel.items = value;
  set processStep(String value) => jobModel.processStep = value;
  set allStatus(double value) => jobModel.allStatus = value;
  set forDisposal(bool value) => jobModel.forDisposal = value;
  set disposed(bool value) => jobModel.disposed = value;
  set isSyncToDB2(bool value) => jobModel.isSyncToDB2 = value;
  set promoErrorCode(int value) => jobModel.promoErrorCode = value;

  /////////////////////////////////////////////////////////////
  //                          ITEMS                          //
  //                          LISTSELECTED                   //
  /////////////////////////////////////////////////////////////

  // Add item
  void addListSelectedItemModel(OtherItemModel value) {
    jobselectedRepository.selectedItems.add(value);
  }

  // Delete item by index
  void delListSelectedItemModel(int value) {
    if (value >= 0 && value < jobselectedRepository.selectedItems.length) {
      jobselectedRepository.selectedItems.removeAt(value);
    }
  }

  // Delete item by matching condition
  void delItemListSelectedItemModel(OtherItemModel value) {
    jobselectedRepository.selectedItems.remove(value);
  }

  // Clear all items
  void clearListSelectedItemModel() {
    jobselectedRepository.selectedItems.clear();
  }

  /////////////////////////////////////////////////////////////
  //                    GETTER SETTER                         //
  //                          JOBSELECTED                    //
  /////////////////////////////////////////////////////////////

  // ================= SELECTED =================

  int get selectedJobId => jobselectedRepository.selectedJobId;
  set selectedJobId(int value) => jobselectedRepository.selectedJobId = value;

  int get selectedCustomerId => jobselectedRepository.selectedCustomerId;
  set selectedCustomerId(int value) =>
      jobselectedRepository.selectedCustomerId = value;

  bool get selectedIsCustomerPickedUp =>
      jobselectedRepository.selectedIsCustomerPickedUp;
  set selectedIsCustomerPickedUp(bool value) =>
      jobselectedRepository.selectedIsCustomerPickedUp = value;

  bool get selectedIsDeliveredToCustomer =>
      jobselectedRepository.selectedIsDeliveredToCustomer;
  set selectedIsDeliveredToCustomer(bool value) =>
      jobselectedRepository.selectedIsDeliveredToCustomer = value;

  bool get selectedPerKilo => jobselectedRepository.selectedPerKilo;
  set selectedPerKilo(bool value) =>
      jobselectedRepository.selectedPerKilo = value;

  bool get selectedPerLoad => jobselectedRepository.selectedPerLoad;
  set selectedPerLoad(bool value) =>
      jobselectedRepository.selectedPerLoad = value;

  double get selectedFinalKilo => jobselectedRepository.selectedFinalKilo;
  set selectedFinalKilo(double value) =>
      jobselectedRepository.selectedFinalKilo = value;

  int get selectedFinalLoad => jobselectedRepository.selectedFinalLoad;
  set selectedFinalLoad(int value) =>
      jobselectedRepository.selectedFinalLoad = value;

  int get selectedFinalPrice => jobselectedRepository.selectedFinalPrice;
  set selectedFinalPrice(int value) =>
      jobselectedRepository.selectedFinalPrice = value;

  int get selectedPromoCounter => jobselectedRepository.selectedPromoCounter;
  set selectedPromoCounter(int value) =>
      jobselectedRepository.selectedPromoCounter = value;

  int get selectedPackage => jobselectedRepository.selectedPackage;
  set selectedPackage(int value) =>
      jobselectedRepository.selectedPackage = value;

  int get selectedPackagePrev => jobselectedRepository.selectedPackagePrev;
  set selectedPackagePrev(int value) =>
      jobselectedRepository.selectedPackagePrev = value;

  int get selectedOthers => jobselectedRepository.selectedOthers;
  set selectedOthers(int value) => jobselectedRepository.selectedOthers = value;

  bool get selectedFold => jobselectedRepository.selectedFold;
  set selectedFold(bool value) => jobselectedRepository.selectedFold = value;

  bool get selectedMix => jobselectedRepository.selectedMix;
  set selectedMix(bool value) => jobselectedRepository.selectedMix = value;

  int get selectedBasket => jobselectedRepository.selectedBasket;
  set selectedBasket(int value) => jobselectedRepository.selectedBasket = value;

  int get selectedEbag => jobselectedRepository.selectedEbag;
  set selectedEbag(int value) => jobselectedRepository.selectedEbag = value;

  int get selectedSako => jobselectedRepository.selectedSako;
  set selectedSako(int value) => jobselectedRepository.selectedSako = value;

  bool get selectedUnpaid => jobselectedRepository.selectedUnpaid;
  set selectedUnpaid(bool value) =>
      jobselectedRepository.selectedUnpaid = value;

  bool get selectedPaidCash => jobselectedRepository.selectedPaidCash;
  set selectedPaidCash(bool value) =>
      jobselectedRepository.selectedPaidCash = value;

  bool get selectedPaidGCash => jobselectedRepository.selectedPaidGCash;
  set selectedPaidGCash(bool value) =>
      jobselectedRepository.selectedPaidGCash = value;

  bool get selectedPaidGCashVerified =>
      jobselectedRepository.selectedPaidGCashVerified;
  set selectedPaidGCashVerified(bool value) =>
      jobselectedRepository.selectedPaidGCashVerified = value;

  int get selectedPaidCashAmount =>
      jobselectedRepository.selectedPaidCashAmount;
  set selectedPaidCashAmount(int value) =>
      jobselectedRepository.selectedPaidCashAmount = value;

  int get selectedPaidGCashAmount =>
      jobselectedRepository.selectedPaidGCashAmount;
  set selectedPaidGCashAmount(int value) =>
      jobselectedRepository.selectedPaidGCashAmount = value;

  String get selectedPaymentReceivedBy =>
      jobselectedRepository.selectedPaymentReceivedBy;
  set selectedPaymentReceivedBy(String value) =>
      jobselectedRepository.selectedPaymentReceivedBy = value;

  TextEditingController get selectedRemarksVar =>
      jobselectedRepository.selectedRemarksVar;
  set selectedRemarksVar(TextEditingController value) =>
      jobselectedRepository.selectedRemarksVar = value;

  List<OtherItemModel> get selectedItems => jobselectedRepository.selectedItems;
  set selectedItems(List<OtherItemModel> value) =>
      jobselectedRepository.selectedItems = value;

  String get selectedProcessStep => jobselectedRepository.selectedProcessStep;
  set selectedProcessStep(String value) =>
      jobselectedRepository.selectedProcessStep = value;

  double get selectedAllStatus => jobselectedRepository.selectedAllStatus;
  set selectedAllStatus(double value) =>
      jobselectedRepository.selectedAllStatus = value;

  bool get selectedForDisposal => jobselectedRepository.selectedForDisposal;
  set selectedForDisposal(bool value) =>
      jobselectedRepository.selectedForDisposal = value;

  bool get selectedDisposed => jobselectedRepository.selectedDisposed;
  set selectedDisposed(bool value) =>
      jobselectedRepository.selectedDisposed = value;
  int get selectedPromoErrorCode =>
      jobselectedRepository.selectedPromoErrorCode;
  set selectedPromoErrorCode(int value) =>
      jobselectedRepository.selectedPromoErrorCode = value;
// ================= REPO VAR =================

  TextEditingController get selectedCustomerNameVar =>
      jobselectedRepository.selectedCustomerNameVar;
  set selectedCustomerNameVar(TextEditingController value) =>
      jobselectedRepository.selectedCustomerNameVar = value;

  TextEditingController get repoVarCashAmountVar =>
      jobselectedRepository.repoVarCashAmountVar;
  set repoVarCashAmountVar(TextEditingController value) =>
      jobselectedRepository.repoVarCashAmountVar = value;

  TextEditingController get repoVarGCashAmountVar =>
      jobselectedRepository.repoVarGCashAmountVar;
  set repoVarGCashAmountVar(TextEditingController value) =>
      jobselectedRepository.repoVarGCashAmountVar = value;

  int get repoVarSelectedIntRiderPickup =>
      jobselectedRepository.repoVarSelectedIntRiderPickup;
  set repoVarSelectedIntRiderPickup(int value) =>
      jobselectedRepository.repoVarSelectedIntRiderPickup = value;

  int get repoVarBasePriceAmount =>
      jobselectedRepository.repoVarBasePriceAmount;
  set repoVarBasePriceAmount(int value) =>
      jobselectedRepository.repoVarBasePriceAmount = value;

  int get repoVarTotalPriceRegSS =>
      jobselectedRepository.repoVarTotalPriceRegSS;
  set repoVarTotalPriceRegSS(int value) =>
      jobselectedRepository.repoVarTotalPriceRegSS = value;

  int get repoVarTotalPriceShortCutRegSS =>
      jobselectedRepository.repoVarTotalPriceShortCutRegSS;
  set repoVarTotalPriceShortCutRegSS(int value) =>
      jobselectedRepository.repoVarTotalPriceShortCutRegSS = value;

  int get repoVarTotalPriceOthers =>
      jobselectedRepository.repoVarTotalPriceOthers;
  set repoVarTotalPriceOthers(int value) =>
      jobselectedRepository.repoVarTotalPriceOthers = value;

  OtherItemModel get repoVarSelectedItem =>
      jobselectedRepository.repoVarSelectedItem;
  set repoVarSelectedItem(OtherItemModel value) =>
      jobselectedRepository.repoVarSelectedItem = value;

  int get repoVarAddFabCount => jobselectedRepository.repoVarAddFabCount;
  set repoVarAddFabCount(int value) =>
      jobselectedRepository.repoVarAddFabCount = value;

  int get repoVarAddBleCount => jobselectedRepository.repoVarAddBleCount;
  set repoVarAddBleCount(int value) =>
      jobselectedRepository.repoVarAddBleCount = value;

  int get repoVarAddExtraDryCount =>
      jobselectedRepository.repoVarAddExtraDryCount;
  set repoVarAddExtraDryCount(int value) =>
      jobselectedRepository.repoVarAddExtraDryCount = value;

  int get repoVarAddExtraWashCount =>
      jobselectedRepository.repoVarAddExtraWashCount;
  set repoVarAddExtraWashCount(int value) =>
      jobselectedRepository.repoVarAddExtraWashCount = value;

  int get repoVarAddExtraSpinCount =>
      jobselectedRepository.repoVarAddExtraSpinCount;
  set repoVarAddExtraSpinCount(int value) =>
      jobselectedRepository.repoVarAddExtraSpinCount = value;

  int get maxPartial => jobselectedRepository.maxPartial;
  set maxPartial(int value) => jobselectedRepository.maxPartial = value;

  int get selectedOthersShortCut =>
      jobselectedRepository.selectedOthersShortCut;
  set selectedOthersShortCut(int value) =>
      jobselectedRepository.selectedOthersShortCut = value;

  bool get thisJobHasPromo => jobselectedRepository.thisJobHasPromo;
  set thisJobHasPromo(bool value) =>
      jobselectedRepository.thisJobHasPromo = value;

  /////////////////////////////////////////////////////////////
  //                    GETTER SETTER                         //
  //                          LOYALTY                         //
  /////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////
  //                         SYNC TO                         //
  //                     JOBMODEL TO SELECTED                //
  /////////////////////////////////////////////////////////////
  void syncRepoToSelectedAll(JobModelRepository jobRepo) {
    int computePromoCounter = 0;
    int computeLoadForKg(double kg) {
      double remainder = kg % 8;
      int wholeEight = kg ~/ 8;
      int lastCounter = 0;
      if (remainder < 1) {
        lastCounter = 0;
      } else {
        lastCounter = 1;
      }
      if (remainder >= 3) {
        computePromoCounter = wholeEight + 1;
      } else {
        computePromoCounter = wholeEight;
      }

      return wholeEight + lastCounter;
    }
    // String docId;

    selectedJobId = jobRepo.jobId;

    /// 🟣 Dates
    // selectedDateQ = jobRepo.dateQ;
    // selectedNeedOn = jobRepo.needOn;
    // selectedDateO = jobRepo.dateO;
    // selectedPaidD = jobRepo.paidD;
    // selectedDateD = jobRepo.dateD;
    // selectedDateC = jobRepo.dateC;
    // selectedCustomerPickupDate = jobRepo.customerPickupDate;
    // selectedRiderDeliveryDate = jobRepo.riderDeliveryDate;

    /// 🟠 Employee

    /// 🟡 Customer
    selectedCustomerId = jobRepo.customerId;
    selectedCustomerNameVar.text = jobRepo.customerName;
    //in case both true, set last to sorting
    if (jobRepo.riderPickup) {
      repoVarSelectedIntRiderPickup = intRiderPickup;
    }
    if (jobRepo.forSorting) repoVarSelectedIntRiderPickup = intForSorting;

    //once true, always true, use for deliver when done

    selectedIsCustomerPickedUp = jobRepo.isCustomerPickedUp;
    selectedIsDeliveredToCustomer = jobRepo.isDeliveredToCustomer;

    /// 🟤 Pricing
    selectedPerKilo = jobRepo.perKilo;
    selectedPerLoad = jobRepo.perLoad;
    selectedFinalKilo = jobRepo.finalKilo;
    selectedFinalLoad = jobRepo.finalLoad;
    // debugPrint(
    //     'jobSyncRepoToSelectAll jobRepo.addOn=${jobRepo.addOn} repoVarTotalPriceOthers=$repoVarTotalPriceOthers');
    if (jobRepo.addOn) {
      repoVarTotalPriceOthers = jobRepo.finalPrice;
    } else {
      repoVarTotalPriceRegSS = jobRepo.finalPrice;
    }
    selectedFinalPrice = jobRepo.finalPrice;
    selectedPromoCounter = jobRepo.promoCounter;
    //selectedPricingSetup = jobRepo.pricingSetup;

    //weight status to repo not needed

    /// 🟢 Options
    // selectedRegular = jobRepo.regular;
    if (jobRepo.regular) selectedPackage = intRegularPackage;
    // selectedSayosabon = jobRepo.sayosabon;
    if (jobRepo.sayosabon) selectedPackage = intSayoSabonPackage;
    // selectedAddOn = jobRepo.addOn;
    if (jobRepo.addOn) selectedPackage = intOthersPackage;
    selectedFold = jobRepo.fold;
    selectedMix = jobRepo.mix;

    /// 🔴 Containers
    selectedBasket = jobRepo.basket;
    selectedEbag = jobRepo.ebag;
    selectedSako = jobRepo.sako;

    /// 🔵 Payment
    selectedUnpaid = jobRepo.unpaid;
    selectedPaidCash = jobRepo.paidCash;
    selectedPaidGCash = jobRepo.paidGCash;
    selectedPaidGCashVerified = jobRepo.paidGCashVerified;
    selectedPaidCashAmount = jobRepo.paidCashAmount;
    repoVarCashAmountVar.text = selectedPaidCashAmount.toString();
    selectedPaidGCashAmount = jobRepo.paidGCashAmount;
    repoVarGCashAmountVar.text = selectedPaidGCashAmount.toString();
    selectedPaymentReceivedBy = jobRepo.paymentReceivedBy;

    /// 🟣 Remarks
    selectedRemarksVar.text = jobRepo.remarks;

    /// 🟢 Items
    selectedItems = jobRepo.items;

    /// 🟠 Workflow Step
    selectedProcessStep = jobRepo.processStep;
    selectedAllStatus = jobRepo.allStatus;

    /// 🔴 Disposal
    selectedForDisposal = jobRepo.forDisposal;
    selectedDisposed = jobRepo.disposed;
    selectedPromoErrorCode = jobRepo.promoErrorCode;

    thisJobHasPromo = false;
    if (jobRepo.items.any((e) => e.itemUniqueId == promoFree.itemUniqueId)) {
      thisJobHasPromo = true;
    }
  }

  void syncRepoToSelectedMin(JobModelRepository jobRepo) {
    //only values to be updated when showPaidUnpaid, isCustomerPickedUp
    // String docId;

    selectedJobId = jobRepo.jobId;

    /// 🟣 Dates
    // selectedDateQ = jobRepo.dateQ;
    // selectedNeedOn = jobRepo.needOn;
    // selectedDateO = jobRepo.dateO;
    // selectedPaidD = jobRepo.paidD;
    // selectedDateD = jobRepo.dateD;
    // selectedCustomerPickupDate = jobRepo.customerPickupDate;
    // selectedRiderDeliveryDate = jobRepo.riderDeliveryDate;

    /// 🟠 Employee
    //selectedCreatedBy = jobRepo.createdBy;
    //selectedCurrentEmpId = jobRepo.currentEmpId;

    /// 🟡 Customer
    selectedCustomerId = jobRepo.customerId;
    selectedCustomerNameVar.text = jobRepo.customerName;
    //in case both true, set last to sorting
    if (jobRepo.riderPickup) {
      repoVarSelectedIntRiderPickup = intRiderPickup;
    }
    if (jobRepo.forSorting) repoVarSelectedIntRiderPickup = intForSorting;
    selectedIsCustomerPickedUp = jobRepo.isCustomerPickedUp;
    selectedIsDeliveredToCustomer = jobRepo.isDeliveredToCustomer;

    /// 🟤 Pricing
    //selectedPerKilo = jobRepo.perKilo;
    //selectedPerLoad = jobRepo.perLoad;
    //selectedFinalKilo = jobRepo.finalKilo;
    selectedFinalLoad = jobRepo.finalLoad;
    if (selectedPackage == intOthersPackage) {
      selectedFinalPrice = repoVarTotalPriceOthers;
    } else {
      selectedFinalPrice = repoVarTotalPriceRegSS;
    }
    selectedFinalPrice = jobRepo.finalPrice;
    //selectedPromoCounter = jobRepo.promoCounter;
    // selectedPricingSetup = jobRepo.pricingSetup;

    /// 🟢 Options
    // selectedRegular = jobRepo.regular;
    //if (jobRepo.regular) selectedPackage = regularPackage;
    // selectedSayosabon = jobRepo.sayosabon;
    //if (jobRepo.sayosabon) selectedPackage = sayoSabonPackage;
    // selectedAddOn = jobRepo.addOn;
    //if (jobRepo.addOn) selectedPackage = othersPackage;
    //selectedFold = jobRepo.fold;
    //selectedMix = jobRepo.mix;

    /// 🔴 Containers
    //selectedBasket = jobRepo.basket;
    //selectedEbag = jobRepo.ebag;
    //selectedSako = jobRepo.sako;

    /// 🔵 Payment
    selectedUnpaid = jobRepo.unpaid;
    selectedPaidCash = jobRepo.paidCash;
    selectedPaidGCash = jobRepo.paidGCash;
    selectedPaidGCashVerified = jobRepo.paidGCashVerified;
    selectedPaidCashAmount = jobRepo.paidCashAmount;
    repoVarCashAmountVar.text = selectedPaidCashAmount.toString();
    selectedPaidGCashAmount = jobRepo.paidGCashAmount;
    repoVarGCashAmountVar.text = selectedPaidGCashAmount.toString();
    selectedPaymentReceivedBy = jobRepo.paymentReceivedBy;

    /// 🟣 Remarks
    selectedRemarksVar.text = jobRepo.remarks;

    /// 🟢 Items
    //selectedItems = jobRepo.items;

    /// 🟠 Workflow Step
    selectedProcessStep = jobRepo.processStep;
    selectedAllStatus = jobRepo.allStatus;

    /// 🔴 Disposal
    //selectedForDisposal = jobRepo.forDisposal;
    //selectedDisposed = jobRepo.disposed;
  }

  /////////////////////////////////////////////////////////////
  //                         SYNC TO                         //
  //                     SELECTED TO JOBMODEL                //
  /////////////////////////////////////////////////////////////
  void syncSelectedToRepoAll(JobModelRepository jobRepo) {
    int computePromoCounter = 0;
    int computeLoadForKg(double kg) {
      double remainder = kg % 8;
      int wholeEight = kg ~/ 8;
      int lastCounter = 0;
      if (remainder < 1) {
        lastCounter = 0;
      } else {
        lastCounter = 1;
      }
      if (remainder >= 3) {
        computePromoCounter = wholeEight + 1;
      } else {
        computePromoCounter = wholeEight;
      }

      return wholeEight + lastCounter;
    }

    //String docId;

    jobRepo.jobId = selectedJobId;

    /// 🟣 Dates
    // jobRepo.dateQ = ?;
    // jobRepo.needOn = ?;
    // jobRepo.dateO = ?;
    // jobRepo.paidD = ?;
    // jobRepo.dateD = ?;
    // jobRepo.customerPickupDate = ?;
    // jobRepo.riderDeliveryDate = ?;

    /// 🟠 Employee
    //jobRepo.createdBy = ?;

    /// 🟡 Customer
    jobRepo.customerId = selectedCustomerId;
    jobRepo.customerName = selectedCustomerNameVar.text;
    jobRepo.forSorting = repoVarSelectedIntRiderPickup == intForSorting;
    //once true, always true, used when done auto delivery
    if (jobRepo.riderPickup ||
        intRiderPickup == repoVarSelectedIntRiderPickup) {
      jobRepo.riderPickup = intRiderPickup == repoVarSelectedIntRiderPickup;
    }
    jobRepo.isCustomerPickedUp = selectedIsCustomerPickedUp;
    jobRepo.isDeliveredToCustomer = selectedIsDeliveredToCustomer;

    /// 🟤 Pricing
    jobRepo.perKilo = selectedPerKilo;
    jobRepo.perLoad = selectedPerLoad;
    jobRepo.finalKilo = selectedFinalKilo;
    if (selectedPackage == intOthersPackage) {
      selectedFinalPrice = repoVarTotalPriceOthers;
    } else {
      selectedFinalPrice = repoVarTotalPriceRegSS;
    }
    jobRepo.finalPrice = selectedFinalPrice;

    //7 weight status
    if (selectedPackage == intRegularPackage) {
      if (selectedPerKilo) {
        jobRepo.finalLoad = computeLoadForKg(selectedFinalKilo);
        debugPrint('jobRepo.promoCounter=${jobRepo.promoCounter}');
        jobRepo.promoCounter = computePromoCounter;
        debugPrint('after jobRepo.promoCounter=${jobRepo.promoCounter}');
        jobRepo.pricingSetup = showHowMany155or125Set(
            computeTotalPrice(selectedFinalKilo, jobRepo), false, jobRepo);
      } else {
        jobRepo.finalLoad = selectedFinalLoad;
        jobRepo.promoCounter = selectedFinalLoad;
        jobRepo.pricingSetup = 'Load(s): $selectedFinalLoad';
      }
    }
    if (selectedPackage == intOthersPackage) {
      final onlyPromo =
          (selectedItems.where((v) => v.itemId == menuOth155).length) +
              (selectedFinalLoad =
                  selectedItems.where((v) => v.itemId == menuOth195).length);

      jobRepo.finalLoad = onlyPromo +
          (selectedItems.where((v) => v.itemId == menuOth125).length);
      jobRepo.promoCounter = onlyPromo;
    }

    //even paying is 0, promocounter still added
    final promoFreeCount =
        jobRepo.items.where((item) => item.itemId == menuOthFree).length;

    //if (promoFreeCount > 0) jobRepo.promoCounter += promoFreeCount;
    //check if finalprice is 0 or 1 load remaining to pay or more

    //add promoCounter for every otheritemmodel 155 promo

    /// 🟢 Options
    // jobRepo.regular = ?;
    jobRepo.regular = selectedPackage == intRegularPackage;
    // jobRepo.sayosabon = ?;
    jobRepo.sayosabon = selectedPackage == intSayoSabonPackage;
    // jobRepo.addOn = ?;
    jobRepo.addOn = selectedPackage == intOthersPackage;
    jobRepo.fold = selectedFold;
    jobRepo.mix = selectedMix;

    /// 🔴 Containers
    jobRepo.basket = selectedBasket;
    jobRepo.ebag = selectedEbag;
    jobRepo.sako = selectedSako;

    /// 🔵 Payment: unpaid only false if paidcash and amount > finalprice
    /// 🔵 Payment: unpaid only false if paidgcash and amount > finalprice and verified
    selectedPaidCashAmount = int.tryParse(repoVarCashAmountVar.text) ?? 0;
    selectedPaidGCashAmount = int.tryParse(repoVarGCashAmountVar.text) ?? 0;

    //always reset to check
    selectedUnpaid = true;
    jobRepo.unpaid = true;
    if (selectedPaidCash &&
        selectedPaidGCash &&
        selectedPaidGCashVerified &&
        (selectedPaidCashAmount + selectedPaidGCashAmount >=
            selectedFinalPrice)) {
      selectedUnpaid = false;
      jobRepo.unpaid = false;
    } else if (selectedPaidCash &&
        selectedPaidCashAmount >= selectedFinalPrice) {
      selectedUnpaid = false;
      jobRepo.unpaid = false;
    } else if (selectedPaidGCash &&
        selectedPaidGCashAmount >= selectedFinalPrice &&
        selectedPaidGCashVerified) {
      selectedUnpaid = false;
      jobRepo.unpaid = false;
    }
    jobRepo.paidCash = selectedPaidCash;
    jobRepo.paidGCash = selectedPaidGCash;
    jobRepo.paidGCashVerified = selectedPaidGCashVerified;
    jobRepo.paidCashAmount = selectedPaidCashAmount;
    jobRepo.paidGCashAmount = selectedPaidGCashAmount;
    jobRepo.paymentReceivedBy = selectedPaymentReceivedBy;

    /// 🟣 Remarks
    jobRepo.remarks = selectedRemarksVar.text;

    /// 🟢 Items
    jobRepo.items = selectedItems;

    /// 🟠 Workflow Step
    jobRepo.processStep = selectedProcessStep;
    jobRepo.allStatus = selectedAllStatus;

    /// 🔴 Disposal
    jobRepo.forDisposal = selectedForDisposal;
    jobRepo.disposed = selectedDisposed;
    jobRepo.promoCounter = selectedPromoErrorCode;
  }

  void syncSelectedToRepoMin(JobModelRepository jobRepo) {
    //only values to be updated when showPaidUnpaid, isCustomerPickedUp
    //String docId;

    //jobRepo.jobId = selectedJobId;

    /// 🟣 Dates
    // jobRepo.dateQ = ?;
    // jobRepo.needOn = ?;
    // jobRepo.dateO = ?;
    // jobRepo.paidD = ?;
    // jobRepo.dateD = ?;
    // jobRepo.customerPickupDate = ?;
    // jobRepo.riderDeliveryDate = ?;

    /// 🟠 Employee
    //jobRepo.createdBy = selectedCreatedBy;
    //jobRepo.currentEmpId = selectedCurrentEmpId;

    /// 🟡 Customer
    //jobRepo.customerId = selectedCustomerId;
    //jobRepo.customerName = selectedCustomerNameVar.text;
    //jobRepo.forSorting = selectedForSorting;
    //jobRepo.riderPickup = selectedRiderPickup;
    jobRepo.forSorting = repoVarSelectedIntRiderPickup == intForSorting;
    if (jobRepo.riderPickup ||
        intRiderPickup == repoVarSelectedIntRiderPickup) {
      jobRepo.riderPickup = intRiderPickup == repoVarSelectedIntRiderPickup;
    }
    jobRepo.isDeliveredToCustomer = selectedIsDeliveredToCustomer;
    jobRepo.isCustomerPickedUp = selectedIsCustomerPickedUp;

    /// 🟤 Pricing
    //jobRepo.perKilo = selectedPerKilo;
    //jobRepo.perLoad = selectedPerLoad;
    //jobRepo.finalKilo = selectedFinalKilo;
    //jobRepo.finalLoad = selectedFinalLoad;
    //jobRepo.finalPrice = selectedFinalPrice;
    //jobRepo.promoCounter = selectedPromoCounter;
    // jobRepo.pricingSetup = ?;

    /// 🟢 Options
    // jobRepo.regular = ?;
    //jobRepo.regular = selectedPackage == regularPackage;
    // jobRepo.sayosabon = ?;
    //jobRepo.sayosabon = selectedPackage == sayoSabonPackage;
    // jobRepo.addOn = ?;
    //jobRepo.addOn = selectedPackage == othersPackage;
    //jobRepo.fold = selectedFold;
    //jobRepo.mix = selectedMix;

    /// 🔴 Containers
    //jobRepo.basket = selectedBasket;
    //jobRepo.ebag = selectedEbag;
    //jobRepo.sako = selectedSako;

    /// 🔵 Payment: unpaid only false if paidcash and amount > finalprice
    /// 🔵 Payment: unpaid only false if paidgcash and amount > finalprice and verified
    selectedPaidCashAmount = int.tryParse(repoVarCashAmountVar.text) ?? 0;
    selectedPaidGCashAmount = int.tryParse(repoVarGCashAmountVar.text) ?? 0;
    //always reset to check
    selectedUnpaid = true;
    jobRepo.unpaid = true;
    if (selectedPaidCash &&
        selectedPaidGCash &&
        selectedPaidGCashVerified &&
        (selectedPaidCashAmount + selectedPaidGCashAmount >=
            selectedFinalPrice)) {
      selectedUnpaid = false;
      jobRepo.unpaid = false;
    } else if (selectedPaidCash &&
        selectedPaidCashAmount >= selectedFinalPrice) {
      selectedUnpaid = false;
      jobRepo.unpaid = false;
    } else if (selectedPaidGCash &&
        selectedPaidGCashAmount >= selectedFinalPrice &&
        selectedPaidGCashVerified) {
      selectedUnpaid = false;
      jobRepo.unpaid = false;
    }
    jobRepo.paidCash = selectedPaidCash;
    jobRepo.paidGCash = selectedPaidGCash;
    jobRepo.paidGCashVerified = selectedPaidGCashVerified;
    jobRepo.paidCashAmount = selectedPaidCashAmount;
    jobRepo.paidGCashAmount = selectedPaidGCashAmount;
    jobRepo.paymentReceivedBy = selectedPaymentReceivedBy;

    /// 🟣 Remarks
    jobRepo.remarks = selectedRemarksVar.text;

    /// 🟢 Items
    //jobRepo.items = selectedItems;

    /// 🟠 Workflow Step
    jobRepo.processStep = selectedProcessStep;

    //ALLSTATUS = 1
    /// 🟣 Dates
    /// no one calls min of this method in done and completed
    if (jobRepo.processStep == 'done') {
      final bool isPaid = !selectedUnpaid &&
          (selectedPaidCash ||
              (selectedPaidGCash && selectedPaidGCashVerified));

      if (selectedIsCustomerPickedUp) {
        jobRepo.customerPickupDate = Timestamp.now();
      }

      if (selectedIsDeliveredToCustomer) {
        jobRepo.riderDeliveryDate = Timestamp.now();
      }

      if (selectedIsCustomerPickedUp || selectedIsDeliveredToCustomer) {
        selectedAllStatus = isPaid ? 1 : 0.7;
      } else {
        selectedAllStatus = 0.7;
      }
    }

    jobRepo.allStatus = selectedAllStatus;

    /// 🔴 Disposal
    //jobRepo.forDisposal = selectedForDisposal;
    //jobRepo.disposed = selectedDisposed;
  }
}
