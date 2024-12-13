//import 'package:cloud_firestore/cloud_firestore.dart';

class JobsOnQueueModel {
  final DateTime dateQ;
  final String createdBy;
  final String customer;
  final int initialKilo;
  final int initialLoad;
  final int initialPrice;
  final int? initialOthersPrice;
  final int? finalKilo;
  final int? finalLoad;
  final int? finalPrice;
  final int? finalOthersPrice;
  final String queueStat;
  final String paymentStat;
  final String paymentReceivedBy;
  final DateTime? paidD;
  final DateTime needOn;
  final bool fold;
  final bool mix;
  final int basket;
  final int bag;
  final String remarks;

  JobsOnQueueModel({
    required this.dateQ,
    required this.createdBy,
    required this.customer,
    required this.initialKilo,
    required this.initialLoad,
    required this.initialPrice,
    this.initialOthersPrice,
    this.finalKilo,
    this.finalLoad,
    this.finalPrice,
    this.finalOthersPrice,
    required this.queueStat,
    required this.paymentStat,
    required this.paymentReceivedBy,
    this.paidD,
    required this.needOn,
    required this.fold,
    required this.mix,
    required this.basket,
    required this.bag,
    required this.remarks,
  });

  JobsOnQueueModel.fromJson(Map<String, dynamic> json)
      : this(
            dateQ: json['DateQ']! as DateTime,
            createdBy: json['CreatedBy']! as String,
            customer: json['Customer']! as String,
            initialKilo: json['InitialKilo']! as int,
            initialLoad: json['InitialLoad']! as int,
            initialPrice: json['InitialPrice']! as int,
            initialOthersPrice: json['InitialOthersPrice']! as int,
            finalKilo: json['FinalKilo']! as int,
            finalLoad: json['FinalLoad']! as int,
            finalPrice: json['FinalPrice']! as int,
            finalOthersPrice: json['FinalOthersPrice']! as int,
            queueStat: json['QueueStat']! as String,
            paymentStat: json['PaymentStat']! as String,
            paymentReceivedBy: json['PaymentReceivedBy']! as String,
            paidD: json['PaidD']! as DateTime,
            needOn: json['NeedOn']! as DateTime,
            fold: json['Fold']! as bool,
            mix: json['Mix']! as bool,
            basket: json['Basket']! as int,
            bag: json['Bag']! as int,
            remarks: json['Remarks']! as String);

  JobsOnQueueModel coyWith({
    DateTime? dateQ,
    String? createdBy,
    String? customer,
    int? initialKilo,
    int? initialLoad,
    int? initialPrice,
    int? intialOthersPrice,
    int? finalKilo,
    int? finalLoad,
    int? finalPrice,
    int? finalOthersPrice,
    String? queueStat,
    String? paymentStat,
    String? paymentReceivedBy,
    DateTime? paidD,
    DateTime? needOn,
    bool? fold,
    bool? mix,
    int? basket,
    int? bag,
    String? remarks,
  }) {
    return JobsOnQueueModel(
      dateQ: dateQ ?? this.dateQ,
      createdBy: createdBy ?? this.createdBy,
      customer: customer ?? this.customer,
      initialKilo: initialKilo ?? this.initialKilo,
      initialLoad: initialLoad ?? this.initialLoad,
      initialPrice: initialPrice ?? this.initialPrice,
      initialOthersPrice: initialOthersPrice ?? this.initialOthersPrice,
      finalKilo: finalKilo ?? this.finalKilo,
      finalLoad: finalLoad ?? this.finalLoad,
      finalPrice: finalPrice ?? this.finalPrice,
      finalOthersPrice: finalOthersPrice ?? this.finalOthersPrice,
      queueStat: queueStat ?? this.queueStat,
      paymentStat: paymentStat ?? this.paymentStat,
      paymentReceivedBy: paymentReceivedBy ?? this.paymentReceivedBy,
      paidD: paidD ?? this.paidD,
      needOn: needOn ?? this.needOn,
      fold: fold ?? this.fold,
      mix: mix ?? this.mix,
      basket: basket ?? this.basket,
      bag: bag ?? this.bag,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toJson() => {
        //return {
        'DateQ': dateQ,
        'CreatedBy': createdBy,
        'Customer': customer,
        'InitialKilo': initialKilo,
        'InitialLoad': initialLoad,
        'InitialPrice': initialPrice,
        'InitialOthersPrice': initialOthersPrice,
        'FinalKilo': finalKilo,
        'FinalLoad': finalLoad,
        'FinalPrice': finalPrice,
        'FinalOthersPrice': finalOthersPrice,
        'QueueStat': queueStat,
        'PaymentStat': paymentStat,
        'PaymentReceivedBy': paymentReceivedBy,
        'PaidD': paidD,
        'NeedOn': needOn,
        'Fold': fold,
        'Mix': mix,
        'Basket': basket,
        'Bag': bag,
        'Remarks': remarks,
      };
  //}
}
