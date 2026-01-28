import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';

// /// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
// /// 🔹 JOB ITEM MODEL
// /// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
// class JobItem {
//   final int itemId;
//   final String itemName;
//   final int itemPcs;
//   final int itemPrice;
//   final int itemPriceTotal;

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
class JobsModel {
  /// 🔵 Identity
  final String docId;

  /// 🟣 Dates
  final Timestamp dateQ;
  final Timestamp needOn;
  final Timestamp dateO;
  final Timestamp paidD;
  final Timestamp dateD;

  /// 🟠 Employee
  final String createdBy;
  final String currentEmpId;

  /// 🟡 Customer
  final int customerId;
  final String customerName;
  final bool
      riderPickup; //always false, if true and already done status, auto-tag readyForDelivery
  //can still be change readyForPickup by the customer

  /// 🟤 Pricing
  final bool perKilo;
  final bool perLoad;
  final int finalKilo;
  final int finalLoad;
  final int finalPrice;

  /// 🟢 Options
  final bool regular;
  final bool sayosabon;
  final bool addOn;
  final bool fold;
  final bool mix;

  /// 🔴 Containers
  final int basket;
  final int ebag;
  final int sako;

  /// 🔵 Payment
  final bool unpaid;
  final bool paidcash;
  final bool paidgcash;
  final bool paidgcashverified;
  final String paymentReceivedBy;

  /// 🟣 Remarks
  final String remarks;

  /// 🟢 Items (LIST VERSION 🔥)
  final List<OtherItemModel> items;

  /// 🟠 Workflow Step
  /// Used ONLY in `Jobs_ongoing`
  /// Values: 'washing' | 'drying' | 'folding'
  final String processStep;

  /// 🔴 Disposal
  final bool forDisposal;
  final bool disposed;

  JobsModel({
    required this.docId,
    required this.dateQ,
    required this.needOn,
    required this.dateO,
    required this.paidD,
    required this.dateD,
    required this.createdBy,
    required this.currentEmpId,
    required this.customerId,
    required this.customerName,
    required this.riderPickup,
    required this.perKilo,
    required this.perLoad,
    required this.finalKilo,
    required this.finalLoad,
    required this.finalPrice,
    required this.regular,
    required this.sayosabon,
    required this.addOn,
    required this.fold,
    required this.mix,
    required this.basket,
    required this.ebag,
    required this.sako,
    required this.unpaid,
    required this.paidcash,
    required this.paidgcash,
    required this.paidgcashverified,
    required this.paymentReceivedBy,
    required this.remarks,
    required this.items,
    required this.processStep,
    required this.forDisposal,
    required this.disposed,
  });

  factory JobsModel.makeEmpty() {
    return JobsModel(
      docId: '',
      dateQ: Timestamp.now(),
      needOn: Timestamp.now(),
      dateO: Timestamp.now(),
      paidD: Timestamp.now(),
      dateD: Timestamp.now(),
      createdBy: '',
      currentEmpId: '',
      customerId: 0,
      customerName: '',
      riderPickup: false,
      perKilo: true,
      perLoad: false,
      finalKilo: 0,
      finalLoad: 0,
      finalPrice: 0,
      regular: true,
      sayosabon: false,
      addOn: false,
      fold: true,
      mix: true,
      basket: 0,
      ebag: 0,
      sako: 0,
      unpaid: true,
      paidcash: false,
      paidgcash: false,
      paidgcashverified: false,
      paymentReceivedBy: '',
      remarks: '',
      items: [OtherItemModel.makeEmpty()],
      processStep: '',
      forDisposal: false,
      disposed: false,
    );
  }

  /// 🟦 COPY WITH
  JobsModel copyWith({
    String? docId,
    Timestamp? dateQ,
    Timestamp? needOn,
    Timestamp? dateO,
    Timestamp? paidD,
    Timestamp? dateD,
    String? createdBy,
    String? currentEmpId,
    int? customerId,
    String? customerName,
    bool? riderPickup,
    bool? perKilo,
    bool? perLoad,
    int? finalKilo,
    int? finalLoad,
    int? finalPrice,
    bool? regular,
    bool? sayosabon,
    bool? addOn,
    bool? fold,
    bool? mix,
    int? basket,
    int? ebag,
    int? sako,
    bool? unpaid,
    bool? paidcash,
    bool? paidgcash,
    bool? paidgcashverified,
    String? paymentReceivedBy,
    String? remarks,
    List<OtherItemModel>? items,
    String? processStep,
    bool? forDisposal,
    bool? disposed,
  }) {
    return JobsModel(
      docId: docId ?? this.docId,
      dateQ: dateQ ?? this.dateQ,
      needOn: needOn ?? this.needOn,
      dateO: dateO ?? this.dateO,
      paidD: paidD ?? this.paidD,
      dateD: dateD ?? this.dateD,
      createdBy: createdBy ?? this.createdBy,
      currentEmpId: currentEmpId ?? this.currentEmpId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      riderPickup: riderPickup ?? this.riderPickup,
      perKilo: perKilo ?? this.perKilo,
      perLoad: perLoad ?? this.perLoad,
      finalKilo: finalKilo ?? this.finalKilo,
      finalLoad: finalLoad ?? this.finalLoad,
      finalPrice: finalPrice ?? this.finalPrice,
      regular: regular ?? this.regular,
      sayosabon: sayosabon ?? this.sayosabon,
      addOn: addOn ?? this.addOn,
      fold: fold ?? this.fold,
      mix: mix ?? this.mix,
      basket: basket ?? this.basket,
      ebag: ebag ?? this.ebag,
      sako: sako ?? this.sako,
      unpaid: unpaid ?? this.unpaid,
      paidcash: paidcash ?? this.paidcash,
      paidgcash: paidgcash ?? this.paidgcash,
      paidgcashverified: paidgcashverified ?? this.paidgcashverified,
      paymentReceivedBy: paymentReceivedBy ?? this.paymentReceivedBy,
      remarks: remarks ?? this.remarks,
      items: items ?? this.items,
      processStep: processStep ?? this.processStep,
      forDisposal: forDisposal ?? this.forDisposal,
      disposed: disposed ?? this.disposed,
    );
  }

  /// 🟩 FROM FIRESTORE
  factory JobsModel.fromJson(Map<String, dynamic> json) => JobsModel(
        docId: json['A0_DocId'],
        dateQ: json['A1_DateQ'],
        createdBy: json['A1a_CreatedBy'],
        currentEmpId: json['A1b_CurrentEmpId'],
        customerId: json['A4_CustomerId'],
        customerName: json['A5_CustomerName'],
        riderPickup: json['A51_RiderPickup'],
        perKilo: json['A6_PerKilo'],
        perLoad: json['A7_PerLoad'],
        finalKilo: json['A8_FinalKilo'],
        finalLoad: json['A9_FinalLoad'],
        finalPrice: json['A10_FinalPrice'],
        regular: json['A11_Regular'],
        sayosabon: json['A12_Sayosabon'],
        addOn: json['A13_AddOn'],
        needOn: json['A14_NeedOn'],
        fold: json['A15_Fold'],
        mix: json['A16_Mix'],
        basket: json['A17_Basket'],
        ebag: json['A18_Ebag'],
        sako: json['A19_Sako'],
        remarks: json['A20_Remarks'],
        unpaid: json['A21_Unpaid'],
        paidcash: json['A22_PaidCash'],
        paidgcash: json['A23_PaidGCash'],
        paidgcashverified: json['A24_PaidGCashVerified'],
        paymentReceivedBy: json['A25_PaymentReceivedBy'],
        paidD: json['A26_PaidD'],
        dateO: json['A27_DateO'],
        dateD: json['C5_DateD'],
        items: (json['items'] as List)
            .map((e) => OtherItemModel.fromJson(e))
            .toList(),
        processStep: json['processStep'],
        forDisposal: json['C11_ForDisposal'],
        disposed: json['C12_Disposed'],
      );

  /// 🟧 TO FIRESTORE
  Map<String, dynamic> toJson() => {
        'A0_DocId': docId,
        'A1_DateQ': dateQ,
        'A1a_CreatedBy': createdBy,
        'A1b_CurrentEmpId': currentEmpId,
        'A4_CustomerId': customerId,
        'A5_CustomerName': customerName,
        'A51_RiderPickup': riderPickup,
        'A6_PerKilo': perKilo,
        'A7_PerLoad': perLoad,
        'A8_FinalKilo': finalKilo,
        'A9_FinalLoad': finalLoad,
        'A10_FinalPrice': finalPrice,
        'A11_Regular': regular,
        'A12_Sayosabon': sayosabon,
        'A13_AddOn': addOn,
        'A14_NeedOn': needOn,
        'A15_Fold': fold,
        'A16_Mix': mix,
        'A17_Basket': basket,
        'A18_Ebag': ebag,
        'A19_Sako': sako,
        'A20_Remarks': remarks,
        'A21_Unpaid': unpaid,
        'A22_PaidCash': paidcash,
        'A23_PaidGCash': paidgcash,
        'A24_PaidGCashVerified': paidgcashverified,
        'A25_PaymentReceivedBy': paymentReceivedBy,
        'A26_PaidD': paidD,
        'A27_DateO': dateO,
        'C5_DateD': dateD,
        'items': items.map((e) => e.toJson()).toList(),
        'processStep': processStep,
        'C11_ForDisposal': forDisposal,
        'C12_Disposed': disposed,
      };
}
