import 'package:cloud_firestore/cloud_firestore.dart';

class JobsOnQueueModel {
  String docId;
  Timestamp dateQ;
  String createdBy;
  String currentEmpId;
  int customerId;
  bool perKilo;
  int initialKilo;
  int initialLoad;
  int initialPrice;
  int initialOthersPrice;
  int finalKilo;
  int finalLoad;
  int finalPrice;
  int finalOthersPrice;
  bool regular;
  bool sayosabon;
  bool others;
  bool addOns;
  Timestamp needOn;
  bool fold;
  bool mix;
  int basket;
  int bag;
  String remarks;
  bool unpaid;
  bool paidcash;
  bool paidgcash;
  String paymentReceivedBy;
  Timestamp dateO;
  Timestamp paidD;
  bool forSorting;
  bool riderPickup;
  int jobsId;
  bool waiting;
  bool washing;
  bool drying;
  bool folding;
  Timestamp dateD;
  bool waitCustomerPickup;
  bool waitRiderDelivery;
  bool nasaCustomerNa;
  bool waitingOneWeek;
  bool waitingTwoWeeks;
  bool forDisposal;
  bool disposed;

  JobsOnQueueModel({
    required this.docId,
    required this.dateQ,
    required this.createdBy,
    required this.currentEmpId,
    required this.customerId,
    required this.perKilo,
    required this.initialKilo,
    required this.initialLoad,
    required this.initialPrice,
    required this.initialOthersPrice,
    required this.finalKilo,
    required this.finalLoad,
    required this.finalPrice,
    required this.finalOthersPrice,
    required this.regular,
    required this.sayosabon,
    required this.others,
    required this.addOns,
    required this.needOn,
    required this.fold,
    required this.mix,
    required this.basket,
    required this.bag,
    required this.remarks,
    required this.unpaid,
    required this.paidcash,
    required this.paidgcash,
    required this.paymentReceivedBy,
    required this.dateO,
    required this.paidD,
    required this.forSorting,
    required this.riderPickup,
    required this.jobsId,
    required this.waiting,
    required this.washing,
    required this.drying,
    required this.folding,
    required this.dateD,
    required this.waitCustomerPickup,
    required this.waitRiderDelivery,
    required this.nasaCustomerNa,
    required this.waitingOneWeek,
    required this.waitingTwoWeeks,
    required this.forDisposal,
    required this.disposed,
  });

  JobsOnQueueModel coyWith({
    String? docId,
    Timestamp? dateQ,
    String? createdBy,
    String? currentEmpId,
    int? customerId,
    bool? perKilo,
    int? initialKilo,
    int? initialLoad,
    int? initialPrice,
    int? initialOthersPrice,
    int? finalKilo,
    int? finalLoad,
    int? finalPrice,
    int? finalOthersPrice,
    bool? regular,
    bool? sayosabon,
    bool? others,
    bool? addOns,
    Timestamp? needOn,
    bool? fold,
    bool? mix,
    int? basket,
    int? bag,
    String? remarks,
    bool? unpaid,
    bool? paidcash,
    bool? paidgcash,
    String? paymentReceivedBy,
    Timestamp? dateO,
    Timestamp? paidD,
    bool? forSorting,
    bool? riderPickup,
    int? jobsId,
    bool? waiting,
    bool? washing,
    bool? drying,
    bool? folding,
    Timestamp? dateD,
    bool? waitCustomerPickup,
    bool? waitRiderDelivery,
    bool? nasaCustomerNa,
    bool? waitingOneWeek,
    bool? waitingTwoWeeks,
    bool? forDisposal,
    bool? disposed,
  }) {
    return JobsOnQueueModel(
      docId: docId ?? this.docId,
      dateQ: dateQ ?? this.dateQ,
      createdBy: createdBy ?? this.createdBy,
      currentEmpId: currentEmpId ?? this.currentEmpId,
      customerId: customerId ?? this.customerId,
      perKilo: perKilo ?? this.perKilo,
      initialKilo: initialKilo ?? this.initialKilo,
      initialLoad: initialLoad ?? this.initialLoad,
      initialPrice: initialPrice ?? this.initialPrice,
      initialOthersPrice: initialOthersPrice ?? this.initialOthersPrice,
      finalKilo: finalKilo ?? this.finalKilo,
      finalLoad: finalLoad ?? this.finalLoad,
      finalPrice: finalPrice ?? this.finalPrice,
      finalOthersPrice: finalOthersPrice ?? this.finalOthersPrice,
      regular: regular ?? this.regular,
      sayosabon: sayosabon ?? this.sayosabon,
      others: others ?? this.others,
      addOns: addOns ?? this.addOns,
      needOn: needOn ?? this.needOn,
      fold: fold ?? this.fold,
      mix: mix ?? this.mix,
      basket: basket ?? this.basket,
      bag: bag ?? this.bag,
      remarks: remarks ?? this.remarks,
      unpaid: unpaid ?? this.unpaid,
      paidcash: paidcash ?? this.paidcash,
      paidgcash: paidgcash ?? this.paidgcash,
      paymentReceivedBy: paymentReceivedBy ?? this.paymentReceivedBy,
      dateO: dateO ?? this.dateO,
      paidD: paidD ?? this.paidD,
      forSorting: forSorting ?? this.forSorting,
      riderPickup: riderPickup ?? this.riderPickup,
      jobsId: jobsId ?? this.jobsId,
      waiting: waiting ?? this.waiting,
      washing: washing ?? this.washing,
      drying: drying ?? this.drying,
      folding: folding ?? this.folding,
      dateD: dateD ?? this.dateD,
      waitCustomerPickup: waitCustomerPickup ?? this.waitCustomerPickup,
      waitRiderDelivery: waitRiderDelivery ?? this.waitRiderDelivery,
      nasaCustomerNa: nasaCustomerNa ?? this.nasaCustomerNa,
      waitingOneWeek: waitingOneWeek ?? this.waitingOneWeek,
      waitingTwoWeeks: waitingTwoWeeks ?? this.waitingTwoWeeks,
      forDisposal: forDisposal ?? this.forDisposal,
      disposed: disposed ?? this.disposed,
    );
  }

  JobsOnQueueModel.fromJson(Map<String, dynamic> json)
      : this(
            docId: json['A0_DocId']! as String,
            dateQ: json['A1_DateQ']! as Timestamp,
            forSorting: json['A2_ForSorting']! as bool,
            riderPickup: json['A3_RiderPickup']! as bool,
            createdBy: json['A4_CreatedBy']! as String,
            currentEmpId: json['A41_CurrentEmpId']! as String,
            customerId: json['A5_CustomerId']! as int,
            perKilo: json['A51_PerKilo']! as bool,
            initialKilo: json['A6_InitialKilo']! as int,
            initialLoad: json['A7_InitialLoad']! as int,
            initialPrice: json['A8_InitialPrice']! as int,
            initialOthersPrice: json['A9_InitialOthersPrice']! as int,
            finalKilo: json['B1_FinalKilo']! as int,
            finalLoad: json['B2_FinalLoad']! as int,
            finalPrice: json['B3_FinalPrice']! as int,
            finalOthersPrice: json['B4_FinalOthersPrice']! as int,
            regular: json['B5_Regular']! as bool,
            sayosabon: json['B6_SayoSabon']! as bool,
            others: json['B7_Others']! as bool,
            addOns: json['B8_AddOns']! as bool,
            needOn: json['B9_NeedOn']! as Timestamp,
            fold: json['C1_Fold']! as bool,
            mix: json['C2_Mix']! as bool,
            basket: json['C3_Basket']! as int,
            bag: json['C4_Bag']! as int,
            remarks: json['C5_Remarks']! as String,
            unpaid: json['C6_Unpaid']! as bool,
            paidcash: json['C7_PaidCash']! as bool,
            paidgcash: json['C8_PaidGCash']! as bool,
            paymentReceivedBy: json['C9_PaymentReceivedBy']! as String,
            dateO: json['D1_DateO']! as Timestamp,
            paidD: json['D2_PaidD']! as Timestamp,
            jobsId: json['D30_JobsId'] as int,
            waiting: json['D3_Waiting']! as bool,
            washing: json['D4_Washing']! as bool,
            drying: json['D5_Drying']! as bool,
            folding: json['D6_Folding']! as bool,
            dateD: json['D7_DateD']! as Timestamp,
            waitCustomerPickup: json['D8_WaitCustomerPickup']! as bool,
            waitRiderDelivery: json['D9_WaitRiderDelivery']! as bool,
            nasaCustomerNa: json['E1_NasaCustomerNa']! as bool,
            waitingOneWeek: json['E2_WaitingOneWeek']! as bool,
            waitingTwoWeeks: json['E3_WaitingTwoWeeks']! as bool,
            forDisposal: json['E4_ForDisposal']! as bool,
            disposed: json['E5_Disposed']! as bool);

  Map<String, dynamic> toJson() => {
        'A0_DocId': docId,
        'A1_DateQ': dateQ,
        'A2_ForSorting': forSorting,
        'A3_RiderPickup': riderPickup,
        'A4_CreatedBy': createdBy,
        'A41_CurrentEmpId': currentEmpId,
        'A5_CustomerId': customerId,
        'A51_PerKilo': perKilo,
        'A6_InitialKilo': initialKilo,
        'A7_InitialLoad': initialLoad,
        'A8_InitialPrice': initialPrice,
        'A9_InitialOthersPrice': initialOthersPrice,
        'B1_FinalKilo': finalKilo,
        'B2_FinalLoad': finalLoad,
        'B3_FinalPrice': finalPrice,
        'B4_FinalOthersPrice': finalOthersPrice,
        'B5_Regular': regular,
        'B6_SayoSabon': sayosabon,
        'B7_Others': others,
        'B8_AddOns': addOns,
        'B9_NeedOn': needOn,
        'C1_Fold': fold,
        'C2_Mix': mix,
        'C3_Basket': basket,
        'C4_Bag': bag,
        'C5_Remarks': remarks,
        'C6_Unpaid': unpaid,
        'C7_PaidCash': paidcash,
        'C8_PaidGCash': paidgcash,
        'C9_PaymentReceivedBy': paymentReceivedBy,
        'D1_DateO': dateO,
        'D2_PaidD': paidD,
        'D30_JobsId': jobsId,
        'D3_Waiting': waiting,
        'D4_Washing': washing,
        'D5_Drying': drying,
        'D6_Folding': folding,
        'D7_DateD': dateD,
        'D8_WaitCustomerPickup': waitCustomerPickup,
        'D9_WaitRiderDelivery': waitRiderDelivery,
        'E1_NasaCustomerNa': nasaCustomerNa,
        'E2_WaitingOneWeek': waitingOneWeek,
        'E3_WaitingTwoWeeks': waitingTwoWeeks,
        'E4_ForDisposal': forDisposal,
        'E5_Disposed': disposed,
      };
}
