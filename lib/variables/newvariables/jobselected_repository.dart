import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';

class JobselectedRepository {
  //this repository is good when putting back unsave values, when user changed values but didnt save.
  //if the design is directly to firestore(no selected values), once changed the values, even it is not yet save
  //user already see the changes and cannot reset back. with this setup, we can easily sync select to repo or repo to selected

  // JobModel(
  //       docId: '',                                                           //no need selected, dont sync
  //       jobId: 0,
  int _selectedJobId = 0;
  //       dateQ: timestamp1900,                                                //no need selected, dont sync
  //       needOn: timestamp1900,                                               //no need selected, dont sync
  //       dateO: timestamp1900,                                                //no need selected, dont sync
  //       paidD: timestamp1900,                                                //no need selected, dont sync
  //       dateD: timestamp1900,                                                //no need selected, dont sync
  //       customerPickupDate: timestamp1900,                                   //no need selected, dont sync
  //       riderDeliveryDate: timestamp1900,                                    //no need selected, dont sync
  //       createdBy: '',
  String _selectedCreatedBy = '';
  //       currentEmpId: '',
  String _selectedCurrentEmpId = '';
  //       customerId: 0,
  int _selectedCustomerId = 0;
  //       customerName: '',
  //       forSorting: false,
  bool _selectedForSorting = false;
  //       riderPickup: false,
  bool _selectedRiderPickup = false;
  //       isCustomerPickedUp: false,
  bool _selectedIsCustomerPickedUp = false;
  //       isDeliveredToCustomer: false,
  bool _selectedIsDeliveredToCustomer = false;
  //       perKilo: false,
  bool _selectedPerKilo = false;
  //       perLoad: false,
  bool _selectedPerLoad = false;
  //       finalKilo: 0,
  double _selectedFinalKilo = 8;
  //       finalLoad: 0,
  int _selectedFinalLoad = 1;
  //       finalPrice: 0,
  int _selectedFinalPrice = 0;
  //       promoCounter: 0,
  int _selectedPromoCounter = 0;
  //       pricingSetup: '',
  //       regular: false,
  int _selectedPackage = regularPackage;
  int _selectedPackagePrev = regularPackage;

  //       sayosabon: false,
  //       addOn: false,
  int _selectedOthers = menuOthDVal;
  //       fold: true,
  bool _selectedFold = false;
  //       mix: true,
  bool _selectedMix = false;
  //       basket: 0,
  int _selectedBasket = 0;
  //       ebag: 0,
  int _selectedEbag = 0;
  //       sako: 0,
  int _selectedSako = 0;
  //       unpaid: true,
  bool _selectedUnpaid = false;
  //       paidCash: false,
  bool _selectedPaidCash = false;
  //       paidGCash: false,
  bool _selectedPaidGCash = false;
  //       paidGCashverified: false,
  bool _selectedPaidGCashVerified = false;
  //       paidCashAmount: 0,
  int _selectedPaidCashAmount = 0;
  //       paidGCashAmount: 0,
  int _selectedPaidGCashAmount = 0;
  //       paymentReceivedBy: '',
  String _selectedPaymentReceivedBy = '';
  //       remarks: '',
  TextEditingController _selectedRemarksVar = TextEditingController();
  //       items: [],
  List<OtherItemModel> _selectedItems = [];
  //       processStep: '',
  String _selectedProcessStep = '';
  //       allStatus: 0,
  double _selectedAllStatus = 0;
  //       forDisposal: false,
  bool _selectedForDisposal = false;
  //       disposed: false)
  bool _selectedDisposed = false;

  //*************************************************************************** */
  //usable but not directly connected to repo, use only for input or computation
  //*************************************************************************** */
  TextEditingController _selectedCustomerNameVar = TextEditingController();
  //as input for cash amount, later will be used in finalPrice
  TextEditingController _repoVarCashAmountVar = TextEditingController();
  //as input for gcash amount, later will be used in finalPrice
  TextEditingController _repoVarGCashAmountVar = TextEditingController();
  int _repoVarSelectedIntRiderPickup = forSorting; //use of list<int>
  int _repoVarBasePriceAmount = 0;
  //as input for price amount regular, later will be used in finalPrice
  int _repoVarTotalPriceRegSS = 155;
  //as input for price amount prev regular, later will be used in finalPrice
  int _repoVarTotalPriceShortCutRegSS = 0;
  //as input for price amount others, later will be used in finalPrice
  int _repoVarTotalPriceOthers = 0;
  //only use for when dropdown selected an item(1)
  OtherItemModel _repoVarSelectedItem = reg125ItemModel;
  int _repoVarAddFabCount = 0; //only use for shortcuts
  int _repoVarAddExtraDryCount = 0; //only use for shortcuts
  int _repoVarAddExtraWashCount = 0; //only use for shortcuts
  int _repoVarAddExtraSpinCount = 0; //only use for shortcuts
  int _maxPartial = 0; //use for maximum kill allowed for partial 190, 260
  int _selectedOthersShortCut = menuOth155; //use for selected add shortcuts

  //================= GETTERS =================

  int get selectedJobId => _selectedJobId;
  String get selectedCreatedBy => _selectedCreatedBy;
  String get selectedCurrentEmpId => _selectedCurrentEmpId;
  int get selectedCustomerId => _selectedCustomerId;
  bool get selectedForSorting => _selectedForSorting;
  bool get selectedRiderPickup => _selectedRiderPickup;
  bool get selectedIsCustomerPickedUp => _selectedIsCustomerPickedUp;
  bool get selectedIsDeliveredToCustomer => _selectedIsDeliveredToCustomer;
  bool get selectedPerKilo => _selectedPerKilo;
  bool get selectedPerLoad => _selectedPerLoad;
  double get selectedFinalKilo => _selectedFinalKilo;
  int get selectedFinalLoad => _selectedFinalLoad;
  int get selectedFinalPrice => _selectedFinalPrice;
  int get selectedPromoCounter => _selectedPromoCounter;
  int get selectedPackage => _selectedPackage;
  int get selectedPackagePrev => _selectedPackagePrev;
  int get selectedOthers => _selectedOthers;
  bool get selectedFold => _selectedFold;
  bool get selectedMix => _selectedMix;
  int get selectedBasket => _selectedBasket;
  int get selectedEbag => _selectedEbag;
  int get selectedSako => _selectedSako;
  bool get selectedUnpaid => _selectedUnpaid;
  bool get selectedPaidCash => _selectedPaidCash;
  bool get selectedPaidGCash => _selectedPaidGCash;
  bool get selectedPaidGCashVerified => _selectedPaidGCashVerified;
  int get selectedPaidCashAmount => _selectedPaidCashAmount;
  int get selectedPaidGCashAmount => _selectedPaidGCashAmount;
  String get selectedPaymentReceivedBy => _selectedPaymentReceivedBy;
  TextEditingController get selectedRemarksVar => _selectedRemarksVar;
  List<OtherItemModel> get selectedItems => _selectedItems;
  String get selectedProcessStep => _selectedProcessStep;
  double get selectedAllStatus => _selectedAllStatus;
  bool get selectedForDisposal => _selectedForDisposal;
  bool get selectedDisposed => _selectedDisposed;
  TextEditingController get selectedCustomerNameVar => _selectedCustomerNameVar;
  TextEditingController get repoVarCashAmountVar => _repoVarCashAmountVar;
  TextEditingController get repoVarGCashAmountVar => _repoVarGCashAmountVar;
  int get repoVarSelectedIntRiderPickup => _repoVarSelectedIntRiderPickup;
  int get repoVarBasePriceAmount => _repoVarBasePriceAmount;
  int get repoVarTotalPriceRegSS => _repoVarTotalPriceRegSS;
  int get repoVarTotalPriceShortCutRegSS => _repoVarTotalPriceShortCutRegSS;
  int get repoVarTotalPriceOthers => _repoVarTotalPriceOthers;
  OtherItemModel get repoVarSelectedItem => _repoVarSelectedItem;
  int get repoVarAddFabCount => _repoVarAddFabCount;
  int get repoVarAddExtraDryCount => _repoVarAddExtraDryCount;
  int get repoVarAddExtraWashCount => _repoVarAddExtraWashCount;
  int get repoVarAddExtraSpinCount => _repoVarAddExtraSpinCount;
  int get maxPartial => _maxPartial;
  int get selectedOthersShortCut => _selectedOthersShortCut;

  //================= SETTERS =================

  set selectedJobId(int v) => _selectedJobId = v;
  set selectedCreatedBy(String v) => _selectedCreatedBy = v;
  set selectedCurrentEmpId(String v) => _selectedCurrentEmpId = v;
  set selectedCustomerId(int v) => _selectedCustomerId = v;
  set selectedForSorting(bool v) => _selectedForSorting = v;
  set selectedRiderPickup(bool v) => _selectedRiderPickup = v;
  set selectedIsCustomerPickedUp(bool v) => _selectedIsCustomerPickedUp = v;
  set selectedIsDeliveredToCustomer(bool v) =>
      _selectedIsDeliveredToCustomer = v;
  set selectedPerKilo(bool v) => _selectedPerKilo = v;
  set selectedPerLoad(bool v) => _selectedPerLoad = v;
  set selectedFinalKilo(double v) => _selectedFinalKilo = v;
  set selectedFinalLoad(int v) => _selectedFinalLoad = v;
  set selectedFinalPrice(int v) => _selectedFinalPrice = v;
  set selectedPromoCounter(int v) => _selectedPromoCounter = v;
  set selectedPackage(int v) => _selectedPackage = v;
  set selectedPackagePrev(int v) => _selectedPackagePrev = v;
  set selectedOthers(int v) => _selectedOthers = v;
  set selectedFold(bool v) => _selectedFold = v;
  set selectedMix(bool v) => _selectedMix = v;
  set selectedBasket(int v) => _selectedBasket = v;
  set selectedEbag(int v) => _selectedEbag = v;
  set selectedSako(int v) => _selectedSako = v;
  set selectedUnpaid(bool v) => _selectedUnpaid = v;
  set selectedPaidCash(bool v) => _selectedPaidCash = v;
  set selectedPaidGCash(bool v) => _selectedPaidGCash = v;
  set selectedPaidGCashVerified(bool v) => _selectedPaidGCashVerified = v;
  set selectedPaidCashAmount(int v) => _selectedPaidCashAmount = v;
  set selectedPaidGCashAmount(int v) => _selectedPaidGCashAmount = v;
  set selectedPaymentReceivedBy(String v) => _selectedPaymentReceivedBy = v;
  set selectedRemarksVar(TextEditingController v) => _selectedRemarksVar = v;
  set selectedItems(List<OtherItemModel> v) => _selectedItems = v;
  set selectedProcessStep(String v) => _selectedProcessStep = v;
  set selectedAllStatus(double v) => _selectedAllStatus = v;
  set selectedForDisposal(bool v) => _selectedForDisposal = v;
  set selectedDisposed(bool v) => _selectedDisposed = v;
  set selectedCustomerNameVar(TextEditingController v) =>
      _selectedCustomerNameVar = v;
  set repoVarCashAmountVar(TextEditingController v) =>
      _repoVarCashAmountVar = v;
  set repoVarGCashAmountVar(TextEditingController v) =>
      _repoVarGCashAmountVar = v;
  set repoVarSelectedIntRiderPickup(int v) =>
      _repoVarSelectedIntRiderPickup = v;
  set repoVarBasePriceAmount(int v) => _repoVarBasePriceAmount = v;
  set repoVarTotalPriceRegSS(int v) => _repoVarTotalPriceRegSS = v;
  set repoVarTotalPriceShortCutRegSS(int v) =>
      _repoVarTotalPriceShortCutRegSS = v;
  set repoVarTotalPriceOthers(int v) => _repoVarTotalPriceOthers = v;
  set repoVarSelectedItem(OtherItemModel v) => _repoVarSelectedItem = v;
  set repoVarAddFabCount(int v) => _repoVarAddFabCount = v;
  set repoVarAddExtraDryCount(int v) => _repoVarAddExtraDryCount = v;
  set repoVarAddExtraWashCount(int v) => _repoVarAddExtraWashCount = v;
  set repoVarAddExtraSpinCount(int v) => _repoVarAddExtraSpinCount = v;
  set maxPartial(int v) => _maxPartial = v;
  set selectedOthersShortCut(int v) => _selectedOthersShortCut = v;

  void reset() {
    selectedJobId = 0;
    selectedCreatedBy = '';
    selectedCurrentEmpId = '';
    selectedCustomerId = 0;
    selectedCustomerNameVar.text = '';
    selectedForSorting = false;
    selectedRiderPickup = false;
    selectedIsCustomerPickedUp = false;
    selectedIsDeliveredToCustomer = false;
    selectedPerKilo = false;
    selectedPerLoad = false;
    selectedFinalKilo = 8;
    selectedFinalLoad = 1;
    selectedFinalPrice = 0;
    selectedPromoCounter = 0;
    selectedPackage = regularPackage;
    selectedPackagePrev = regularPackage;
    selectedOthers = menuOthDVal;
    selectedFold = false;
    selectedMix = false;
    selectedBasket = 0;
    selectedEbag = 0;
    selectedSako = 0;
    selectedUnpaid = false;
    selectedPaidCash = false;
    selectedPaidGCash = false;
    selectedPaidGCashVerified = false;
    selectedPaidCashAmount = 0;
    selectedPaidGCashAmount = 0;
    selectedPaymentReceivedBy = '';
    selectedRemarksVar.text = '';
    selectedItems = [];
    selectedProcessStep = '';
    selectedAllStatus = 0;
    selectedForDisposal = false;
    selectedDisposed = false;
    repoVarCashAmountVar.text = '';
    repoVarGCashAmountVar.text = '';
    repoVarSelectedIntRiderPickup = forSorting;
    repoVarBasePriceAmount = 0;
    repoVarTotalPriceRegSS = 155;
    repoVarTotalPriceShortCutRegSS = 0;
    repoVarTotalPriceOthers = 0;
    repoVarSelectedItem = reg125ItemModel;
    repoVarAddFabCount = 0;
    repoVarAddExtraDryCount = 0;
    repoVarAddExtraWashCount = 0;
    repoVarAddExtraSpinCount = 0;
  }
}
