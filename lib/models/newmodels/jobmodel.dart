import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';

// /// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
// /// 🔹 JOB ITEM MODEL
// /// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
// class JobItem {
//   int itemId;
//   String itemName;
//   int itemPcs;
//   int itemPrice;
//   int itemPriceTotal;

//   JobItem({
//     required this.itemId,
//     required this.itemName,
//     required this.itemPcs,
//     required this.itemPrice,
//     required this.itemPriceTotal,
//   });

//   factory JobItem.fromJson(Map<String, dynamic> json) => JobItem(
//         itemId: json['itemId'] as int,
//         itemName: json['itemName'] as String,
//         itemPcs: json['itemPcs'] as int,
//         itemPrice: json['itemPrice'] as int,
//         itemPriceTotal: json['itemPriceTotal'] as int,
//       );

//   Map<String, dynamic> toJson() => {
//         'itemId': itemId,
//         'itemName': itemName,
//         'itemPcs': itemPcs,
//         'itemPrice': itemPrice,
//         'itemPriceTotal': itemPriceTotal,
//       };
// }

/// 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩
/// 🔹 JOBS MODEL (RECOMMENDED)
/// 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩
class JobModel {
  /// 🔵 Identity
  String docId;
  int jobId;

  /// 🟣 Dates
  Timestamp dateQ; //Queue Date
  Timestamp needOn; //need on date
  Timestamp dateO; //On-Going date
  Timestamp paidD; //Paid Date / GCash Date
  Timestamp dateD; //Done Date
  Timestamp dateC; //Completed Date
  Timestamp customerPickupDate; //Done - pickup ni customer Date
  Timestamp riderDeliveryDate; //Done - delivery date ni rider

  /// 🟠 Employee
  String createdBy;
  String currentEmpId;

  /// 🟡 Customer
  int customerId;
  String customerName;
  String address; // NEW FIELD
  bool forSorting;
  bool riderPickup;
  bool isCustomerPickedUp;
  bool isDeliveredToCustomer;

  /// 🟤 Pricing
  bool perKilo;
  bool perLoad;
  double finalKilo;
  int finalLoad;
  int finalPrice;
  int promoCounter;
  String pricingSetup;

  /// 🟢 Options
  bool regular;
  bool sayosabon;
  bool addOn;
  bool fold;
  bool mix;

  /// 🔴 Containers
  int basket;
  int ebag;
  int sako;

  /// 🔵 Payment
  bool unpaid;
  bool paidCash;
  bool paidGCash;
  bool paidGCashverified;
  int paidCashAmount;
  int paidGCashAmount; //portion paid by gcash
  //if combine, can be tag paidCash & paidGCash
  String paymentReceivedBy;

  /// 🟣 Remarks
  String remarks;

  /// 🟢 Items (LIST VERSION 🔥)
  List<OtherItemModel> items;

  /// 🟠 Workflow Step
  /// Used ONLY in `Jobs_ongoing`
  /// Values: 'waiting', 'washing' | 'drying' | 'folding' | 'done'
  String processStep;
  double allStatus;
  //on queue 0.10 for pickup, 1.0 sorting
  //on-going 0.10 waiting, 0.6 washing, 0.7 drying, 0.8 folding
  //done     0.5 unpaid, 0.5 customer pickup, 0.5 for delivery, 0.5 delivered pay via gcash
  //         customer pickup done + paid cash = 1.0
  //         delivery done + paid cash = 1.0
  //         delivery done + padi via gcash = 0.75 if verified = 1.0

  /// 🔴 Disposal
  bool forDisposal;
  bool disposed;
  bool isSyncToDB2; //tels if sync to db2
  bool
      isPromoCounter; //if this is false, succeeding records will not be checked and consider false.

  JobModel({
    required this.docId,
    required this.jobId,
    required this.dateQ,
    required this.needOn,
    required this.dateO,
    required this.paidD,
    required this.dateD,
    required this.dateC,
    required this.customerPickupDate,
    required this.riderDeliveryDate,
    required this.createdBy,
    required this.currentEmpId,
    required this.customerId,
    required this.customerName,
    required this.address,
    required this.forSorting,
    required this.riderPickup,
    required this.isCustomerPickedUp,
    required this.isDeliveredToCustomer,
    required this.perKilo,
    required this.perLoad,
    required this.finalKilo,
    required this.finalLoad,
    required this.finalPrice,
    required this.promoCounter,
    required this.pricingSetup,
    required this.regular,
    required this.sayosabon,
    required this.addOn,
    required this.fold,
    required this.mix,
    required this.basket,
    required this.ebag,
    required this.sako,
    required this.unpaid,
    required this.paidCash,
    required this.paidGCash,
    required this.paidGCashverified,
    required this.paidCashAmount,
    required this.paidGCashAmount,
    required this.paymentReceivedBy,
    required this.remarks,
    required this.items,
    required this.processStep,
    required this.allStatus,
    required this.forDisposal,
    required this.disposed,
    required this.isSyncToDB2,
    required this.isPromoCounter,
  });

  factory JobModel.makeEmpty() {
    return JobModel(
      docId: '',
      jobId: 0,
      dateQ: Timestamp.now(),
      needOn: Timestamp.now(),
      dateO: Timestamp.now(),
      paidD: Timestamp.now(),
      dateD: Timestamp.now(),
      dateC: Timestamp.now(),
      customerPickupDate: Timestamp.now(),
      riderDeliveryDate: Timestamp.now(),
      createdBy: '',
      currentEmpId: '',
      customerId: 0,
      customerName: '',
      address: '',
      forSorting: false,
      riderPickup: false,
      isCustomerPickedUp: false,
      isDeliveredToCustomer: false,
      perKilo: true,
      perLoad: false,
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
      isPromoCounter: true,
    );
  }

  /// 🟦 COPY WITH
  JobModel copyWith({
    String? docId,
    int? jobsId,
    Timestamp? dateQ,
    Timestamp? needOn,
    Timestamp? dateO,
    Timestamp? paidD,
    Timestamp? dateD,
    Timestamp? dateC,
    Timestamp? customerPickupDate,
    Timestamp? riderDeliveryDate,
    String? createdBy,
    String? currentEmpId,
    int? customerId,
    String? customerName,
    String? address,
    bool? forSorting,
    bool? riderPickup,
    bool? isCustomerPickedUp,
    bool? isDeliveredToCustomer,
    bool? perKilo,
    bool? perLoad,
    double? finalKilo,
    int? finalLoad,
    int? finalPrice,
    int? promoCounter,
    String? pricingSetup,
    bool? regular,
    bool? sayosabon,
    bool? addOn,
    bool? fold,
    bool? mix,
    int? basket,
    int? ebag,
    int? sako,
    bool? unpaid,
    bool? paidCash,
    bool? paidGCash,
    bool? paidGCashverified,
    int? paidCashAmount,
    int? paidGCashAmount,
    String? paymentReceivedBy,
    String? remarks,
    List<OtherItemModel>? items,
    String? processStep,
    double? allStatus,
    bool? forDisposal,
    bool? disposed,
    bool? isSyncToDB2,
    bool? isPromoCounter,
  }) {
    return JobModel(
      docId: docId ?? this.docId,
      jobId: jobsId ?? this.jobId,
      dateQ: dateQ ?? this.dateQ,
      needOn: needOn ?? this.needOn,
      dateO: dateO ?? this.dateO,
      paidD: paidD ?? this.paidD,
      dateD: dateD ?? this.dateD,
      dateC: dateC ?? this.dateC,
      customerPickupDate: customerPickupDate ?? this.customerPickupDate,
      riderDeliveryDate: riderDeliveryDate ?? this.riderDeliveryDate,
      createdBy: createdBy ?? this.createdBy,
      currentEmpId: currentEmpId ?? this.currentEmpId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      forSorting: forSorting ?? this.forSorting,
      riderPickup: riderPickup ?? this.riderPickup,
      isCustomerPickedUp: isCustomerPickedUp ?? this.isCustomerPickedUp,
      isDeliveredToCustomer:
          isDeliveredToCustomer ?? this.isDeliveredToCustomer,
      perKilo: perKilo ?? this.perKilo,
      perLoad: perLoad ?? this.perLoad,
      finalKilo: finalKilo ?? this.finalKilo,
      finalLoad: finalLoad ?? this.finalLoad,
      finalPrice: finalPrice ?? this.finalPrice,
      promoCounter: promoCounter ?? this.promoCounter,
      pricingSetup: pricingSetup ?? this.pricingSetup,
      regular: regular ?? this.regular,
      sayosabon: sayosabon ?? this.sayosabon,
      addOn: addOn ?? this.addOn,
      fold: fold ?? this.fold,
      mix: mix ?? this.mix,
      basket: basket ?? this.basket,
      ebag: ebag ?? this.ebag,
      sako: sako ?? this.sako,
      unpaid: unpaid ?? this.unpaid,
      paidCash: paidCash ?? this.paidCash,
      paidGCash: paidGCash ?? this.paidGCash,
      paidGCashverified: paidGCashverified ?? this.paidGCashverified,
      paidCashAmount: paidCashAmount ?? this.paidCashAmount,
      paidGCashAmount: paidGCashAmount ?? this.paidGCashAmount,
      paymentReceivedBy: paymentReceivedBy ?? this.paymentReceivedBy,
      remarks: remarks ?? this.remarks,
      items: items ?? this.items,
      processStep: processStep ?? this.processStep,
      allStatus: allStatus ?? this.allStatus,
      forDisposal: forDisposal ?? this.forDisposal,
      disposed: disposed ?? this.disposed,
      isSyncToDB2: isSyncToDB2 ?? this.isSyncToDB2,
      isPromoCounter: isPromoCounter ?? this.isPromoCounter,
    );
  }

  /// 🟩 FROM FIRESTORE
  factory JobModel.fromJson(Map<String, dynamic> json) => JobModel(
        docId: json['A00_DocId'],
        jobId: json['A00_JobId'],
        dateQ: json['A01_DateQ'],
        createdBy: json['A10_CreatedBy'],
        currentEmpId: json['A12_CurrentEmpId'],
        customerId: json['C00_CustomerId'],
        customerName: json['C01_CustomerName'],
        address: json['C02_Address'] ?? '',
        forSorting: json['Q00_ForSorting'],
        riderPickup: json['Q01_RiderPickup'],
        isCustomerPickedUp: json['Q01_IsCustomerPickedUp'],
        isDeliveredToCustomer: json['Q01_IsDeliveredToCustomer'],
        perKilo: json['Q02_PerKilo'],
        perLoad: json['Q03_PerLoad'],
        finalKilo: json['Q04_FinalKilo'],
        finalLoad: json['Q05_FinalLoad'],
        finalPrice: json['Q06_FinalPrice'],
        promoCounter: json['Q06_PromoCounter'],
        pricingSetup: json['Q06_PricingSetup'],
        regular: json['Q07_Regular'],
        sayosabon: json['Q08_Sayosabon'],
        addOn: json['Q09_AddOn'],
        needOn: json['A02_NeedOn'],
        fold: json['Q10_Fold'],
        mix: json['Q11_Mix'],
        basket: json['Q12_Basket'],
        ebag: json['Q13_Ebag'],
        sako: json['Q14_Sako'],
        remarks: json['R00_Remarks'],
        unpaid: json['P00_Unpaid'],
        paidCash: json['P01_PaidCash'],
        paidGCash: json['P02_PaidGCash'],
        paidGCashverified: json['P03_PaidGCashVerified'],
        paidCashAmount: json['P04_PaidCashAmount'],
        paidGCashAmount: json['P05_PaidGCashAmount'],
        paymentReceivedBy: json['P08_PaymentReceivedBy'],
        paidD: json['A03_PaidD'],
        dateO: json['A04_DateO'],
        dateD: json['A05_DateD'],
        dateC: json['A06_DateC'],
        customerPickupDate: json['A06_CustomerPickupDate'],
        riderDeliveryDate: json['A07_RiderDeliveryDate'],
        items: (json['items'] as List)
            .map((e) => OtherItemModel.fromJson(e))
            .toList(),
        processStep: json['O00_ProcessStep'],
        allStatus: json['O01_AllStatus'],
        forDisposal: json['R01_ForDisposal'],
        disposed: json['R02_Disposed'],
        isSyncToDB2: json['Z00_IsSyncToDB2'] ?? false,
        isPromoCounter: json['Z01_IsPromoCounter'] ?? true,
      );

  /// 🟧 TO FIRESTORE
  Map<String, dynamic> toJson() => {
        'A00_DocId': docId,
        'A00_JobId': jobId,
        'A01_DateQ': dateQ,
        'A10_CreatedBy': createdBy,
        'A12_CurrentEmpId': currentEmpId,
        'C00_CustomerId': customerId,
        'C01_CustomerName': customerName,
        'C02_Address': address,
        'Q00_ForSorting': forSorting,
        'Q01_RiderPickup': riderPickup,
        'Q01_IsCustomerPickedUp': isCustomerPickedUp,
        'Q01_IsDeliveredToCustomer': isDeliveredToCustomer,
        'Q02_PerKilo': perKilo,
        'Q03_PerLoad': perLoad,
        'Q04_FinalKilo': finalKilo,
        'Q05_FinalLoad': finalLoad,
        'Q06_FinalPrice': finalPrice,
        'Q06_PromoCounter': promoCounter,
        'Q06_PricingSetup': pricingSetup,
        'Q07_Regular': regular,
        'Q08_Sayosabon': sayosabon,
        'Q09_AddOn': addOn,
        'A02_NeedOn': needOn,
        'Q10_Fold': fold,
        'Q11_Mix': mix,
        'Q12_Basket': basket,
        'Q13_Ebag': ebag,
        'Q14_Sako': sako,
        'R00_Remarks': remarks,
        'P00_Unpaid': unpaid,
        'P01_PaidCash': paidCash,
        'P02_PaidGCash': paidGCash,
        'P03_PaidGCashVerified': paidGCashverified,
        'P04_PaidCashAmount': paidCashAmount,
        'P05_PaidGCashAmount': paidGCashAmount,
        'P08_PaymentReceivedBy': paymentReceivedBy,
        'A03_PaidD': paidD,
        'A04_DateO': dateO,
        'A05_DateD': dateD,
        'A06_DateC': dateC,
        'A06_CustomerPickupDate': customerPickupDate,
        'A07_RiderDeliveryDate': riderDeliveryDate,
        'items': items.map((e) => e.toJson()).toList(),
        'O00_ProcessStep': processStep,
        'O01_AllStatus': allStatus,
        'R01_ForDisposal': forDisposal,
        'R02_Disposed': disposed,
        'Z00_IsSyncToDB2': isSyncToDB2,
        'Z01_IsPromoCounter': isPromoCounter,
      };
}
