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
  Timestamp dateQ;
  Timestamp needOn;
  Timestamp dateO;
  Timestamp paidD;
  Timestamp dateD;

  /// 🟠 Employee
  String createdBy;
  String currentEmpId;

  /// 🟡 Customer
  int customerId;
  String customerName;
  bool forSorting;
  bool riderPickup;

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
  bool partialPaidCash;
  bool partialPaidGCash;
  int partialPaidCashAmount; //portion paid by cash
  int partialPaidGCashAmount; //portion paid by gcash
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

  /// 🔴 Disposal
  bool forDisposal;
  bool disposed;

  JobModel({
    required this.docId,
    required this.jobId,
    required this.dateQ,
    required this.needOn,
    required this.dateO,
    required this.paidD,
    required this.dateD,
    required this.createdBy,
    required this.currentEmpId,
    required this.customerId,
    required this.customerName,
    required this.forSorting,
    required this.riderPickup,
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
    required this.partialPaidCash,
    required this.partialPaidGCash,
    required this.partialPaidCashAmount,
    required this.partialPaidGCashAmount,
    required this.paidGCashverified,
    required this.paymentReceivedBy,
    required this.remarks,
    required this.items,
    required this.processStep,
    required this.forDisposal,
    required this.disposed,
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
      createdBy: '',
      currentEmpId: '',
      customerId: 0,
      customerName: '',
      forSorting: false,
      riderPickup: false,
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
      disposed: false,
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
    String? createdBy,
    String? currentEmpId,
    int? customerId,
    String? customerName,
    bool? forSorting,
    bool? riderPickup,
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
    bool? partialPaidCash,
    bool? partialPaidGCash,
    int? partialPaidCashAmount,
    int? partialPaidGCashAmount,
    String? paymentReceivedBy,
    String? remarks,
    List<OtherItemModel>? items,
    String? processStep,
    bool? forDisposal,
    bool? disposed,
  }) {
    return JobModel(
      docId: docId ?? this.docId,
      jobId: jobsId ?? this.jobId,
      dateQ: dateQ ?? this.dateQ,
      needOn: needOn ?? this.needOn,
      dateO: dateO ?? this.dateO,
      paidD: paidD ?? this.paidD,
      dateD: dateD ?? this.dateD,
      createdBy: createdBy ?? this.createdBy,
      currentEmpId: currentEmpId ?? this.currentEmpId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      forSorting: forSorting ?? this.forSorting,
      riderPickup: riderPickup ?? this.riderPickup,
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
      partialPaidCash: partialPaidCash ?? this.partialPaidCash,
      partialPaidGCash: partialPaidGCash ?? this.partialPaidGCash,
      partialPaidCashAmount:
          partialPaidCashAmount ?? this.partialPaidCashAmount,
      partialPaidGCashAmount:
          partialPaidGCashAmount ?? this.partialPaidGCashAmount,
      paidGCashverified: paidGCashverified ?? this.paidGCashverified,
      paymentReceivedBy: paymentReceivedBy ?? this.paymentReceivedBy,
      remarks: remarks ?? this.remarks,
      items: items ?? this.items,
      processStep: processStep ?? this.processStep,
      forDisposal: forDisposal ?? this.forDisposal,
      disposed: disposed ?? this.disposed,
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
        forSorting: json['Q00_ForSorting'],
        riderPickup: json['Q01_RiderPickup'],
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
        partialPaidCash: json['P03_PartialPaidCash'],
        partialPaidGCash: json['P04_PartialPaidGCash'],
        partialPaidCashAmount: json['P05_PartialPaidCashAmount'],
        partialPaidGCashAmount: json['P06_PartialPaidGCashAmount'],
        paidGCashverified: json['P07_PaidGCashVerified'],
        paymentReceivedBy: json['P08_PaymentReceivedBy'],
        paidD: json['A03_PaidD'],
        dateO: json['A04_DateO'],
        dateD: json['A05_DateD'],
        items: (json['items'] as List)
            .map((e) => OtherItemModel.fromJson(e))
            .toList(),
        processStep: json['O00_ProcessStep'],
        forDisposal: json['R01_ForDisposal'],
        disposed: json['R02_Disposed'],
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
        'Q00_ForSorting': forSorting,
        'Q01_RiderPickup': riderPickup,
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
        'P03_PartialPaidCash': partialPaidCash,
        'P04_PartialPaidGCash': partialPaidGCash,
        'P05_PartialPaidCashAmount': partialPaidCashAmount,
        'P06_PartialPaidGCashAmount': partialPaidGCashAmount,
        'P07_PaidGCashVerified': paidGCashverified,
        'P08_PaymentReceivedBy': paymentReceivedBy,
        'A03_PaidD': paidD,
        'A04_DateO': dateO,
        'A05_DateD': dateD,
        'items': items.map((e) => e.toJson()).toList(),
        'O00_ProcessStep': processStep,
        'R01_ForDisposal': forDisposal,
        'R02_Disposed': disposed,
      };
}
