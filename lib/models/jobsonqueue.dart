import 'package:cloud_firestore/cloud_firestore.dart';

class JobsOnQueue {
  Timestamp dateQ;
  String createdBy;
  String customer;
  int initialLoad;
  int initialPrice;
  String queueStat;
  String paymentStat;
  String paymentReceivedBy;
  Timestamp paidD;
  Timestamp needOn;
  bool maxFab;
  bool fold;
  bool mix;
  int basket;
  int bag;
  int kulang;
  int maySukli;

  JobsOnQueue({
    required this.dateQ,
    required this.createdBy,
    required this.customer,
    required this.initialLoad,
    required this.initialPrice,
    required this.queueStat,
    required this.paymentStat,
    required this.paymentReceivedBy,
    required this.paidD,
    required this.needOn,
    required this.maxFab,
    required this.fold,
    required this.mix,
    required this.basket,
    required this.bag,
    required this.kulang,
    required this.maySukli,
  });

  JobsOnQueue.fromJson(Map<String, Object?> json)
      : this(
          dateQ: json['DateQ']! as Timestamp,
          createdBy: json['CreatedBy']! as String,
          customer: json['Customer']! as String,
          initialLoad: json['InitialLoad']! as int,
          initialPrice: json['InitialPrice']! as int,
          queueStat: json['QueueStat']! as String,
          paymentStat: json['PaymentStat']! as String,
          paymentReceivedBy: json['PaymentReceivedBy']! as String,
          paidD: json['PaidD']! as Timestamp,
          needOn: json['NeedOn']! as Timestamp,
          maxFab: json['MaxFab']! as bool,
          fold: json['Fold']! as bool,
          mix: json['Mix']! as bool,
          basket: json['Basket']! as int,
          bag: json['Bag']! as int,
          kulang: json['Kulang']! as int,
          maySukli: json['MaySukli']! as int,
        );

  JobsOnQueue coyWith({
    Timestamp? dateQ,
    String? createdBy,
    String? customer,
    int? initialLoad,
    int? initialPrice,
    String? queueStat,
    String? paymentStat,
    String? paymentReceivedBy,
    Timestamp? paidD,
    Timestamp? needOn,
    bool? maxFab,
    bool? fold,
    bool? mix,
    int? basket,
    int? bag,
    int? kulang,
    int? maySukli,
  }) {
    return JobsOnQueue(
        dateQ: dateQ ?? this.dateQ,
        createdBy: createdBy ?? this.createdBy,
        customer: customer ?? this.customer,
        initialLoad: initialLoad ?? this.initialLoad,
        initialPrice: initialPrice ?? this.initialPrice,
        queueStat: queueStat ?? this.queueStat,
        paymentStat: paymentStat ?? this.paymentStat,
        paymentReceivedBy: paymentReceivedBy ?? this.paymentReceivedBy,
        paidD: paidD ?? this.paidD,
        needOn: needOn ?? this.needOn,
        maxFab: maxFab ?? this.maxFab,
        fold: fold ?? this.fold,
        mix: mix ?? this.mix,
        basket: basket ?? this.basket,
        bag: bag ?? this.bag,
        kulang: kulang ?? this.kulang,
        maySukli: maySukli ?? this.maySukli);
  }

  Map<String, Object?> toJson() {
    return {
      'DateQ': dateQ,
      'CreatedBy': createdBy,
      'Customer': customer,
      'InitialLoad': initialLoad,
      'InitialPrice': initialPrice,
      'QueueStat': queueStat,
      'PaymentStat': paymentStat,
      'PaymentReceivedBy': paymentReceivedBy,
      'PaidD': paidD,
      'NeedOn': needOn,
      'MaxFab': maxFab,
      'Fold': fold,
      'Mix': mix,
      'Basket': basket,
      'Bag': bag,
      'Kulang': kulang,
      'MaySukli': maySukli,
    };
  }
}
