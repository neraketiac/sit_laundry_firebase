import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerFirebaseModel {
  String      docId;
  //Customer1
  int         a101CustId;
  String      a101Name;
  String      a101Address;
  int         a101Phone;
  Timestamp   a101Date; 
  String      a101Remarks;
  int         a101PromoLoadsCurr; //* current no. of loads for promo, reset every when free was consumed
  int         a101FreeCurr;       //* current no. of free, (-1) when used
  int         a101BalCurr;        //* (+) need to pay in WKL, (-) need to give to customer, (0) no balance
  Timestamp   a101FreeDate;       //* last date when free was consumed
  int         a101LoadsOverAll;   //* overall loads
  int         a101FreeOverAll;    //* overall free
  int         a101PaidOverAll;    //* overall amount received hist
  //Customer2
  int         a102CustId;
  String      a102Name;
  String      a102Address;
  int         a102Phone;
  Timestamp   a102Date; 
  String      a102Remarks;
  int         a102PromoLoadsCurr;
  int         a102FreeCurr;
  int         a102BalCurr;
  Timestamp   a102FreeDate;
  int         a102LoadsOverAll;
  int         a102FreeOverAll;
  int         a102PaidOverAll;
  //Customer3
  int         a103CustId;
  String      a103Name;
  String      a103Address;
  int         a103Phone;
  Timestamp   a103Date; 
  String      a103Remarks;
  int         a103PromoLoadsCurr;
  int         a103FreeCurr;
  int         a103BalCurr;
  Timestamp   a103FreeDate;
  int         a103LoadsOverAll;
  int         a103FreeOverAll;
  int         a103PaidOverAll;
  //Customer4
  int         a104CustId;
  String      a104Name;
  String      a104Address;
  int         a104Phone;
  Timestamp   a104Date; 
  String      a104Remarks;
  int         a104PromoLoadsCurr;
  int         a104FreeCurr;
  int         a104BalCurr;
  Timestamp   a104FreeDate;
  int         a104LoadsOverAll;
  int         a104FreeOverAll;
  int         a104PaidOverAll;
  //Customer5
  int         a105CustId;
  String      a105Name;
  String      a105Address;
  int         a105Phone;
  Timestamp   a105Date; 
  String      a105Remarks;
  int         a105PromoLoadsCurr;
  int         a105FreeCurr;
  int         a105BalCurr;
  Timestamp   a105FreeDate;
  int         a105LoadsOverAll;
  int         a105FreeOverAll;
  int         a105PaidOverAll;
  //Customer6
  int         a106CustId;
  String      a106Name;
  String      a106Address;
  int         a106Phone;
  Timestamp   a106Date; 
  String      a106Remarks;
  int         a106PromoLoadsCurr;
  int         a106FreeCurr;
  int         a106BalCurr;
  Timestamp   a106FreeDate;
  int         a106LoadsOverAll;
  int         a106FreeOverAll;
  int         a106PaidOverAll;
  //Customer7
  int         a107CustId;
  String      a107Name;
  String      a107Address;
  int         a107Phone;
  Timestamp   a107Date; 
  String      a107Remarks;
  int         a107PromoLoadsCurr;
  int         a107FreeCurr;
  int         a107BalCurr;
  Timestamp   a107FreeDate;
  int         a107LoadsOverAll;
  int         a107FreeOverAll;
  int         a107PaidOverAll;
  //Customer8
  int         a108CustId;
  String      a108Name;
  String      a108Address;
  int         a108Phone;
  Timestamp   a108Date; 
  String      a108Remarks;
  int         a108PromoLoadsCurr;
  int         a108FreeCurr;
  int         a108BalCurr;
  Timestamp   a108FreeDate;
  int         a108LoadsOverAll;
  int         a108FreeOverAll;
  int         a108PaidOverAll;
  //Customer9
  int         a109CustId;
  String      a109Name;
  String      a109Address;
  int         a109Phone;
  Timestamp   a109Date; 
  String      a109Remarks;
  int         a109PromoLoadsCurr;
  int         a109FreeCurr;
  int         a109BalCurr;
  Timestamp   a109FreeDate;
  int         a109LoadsOverAll;
  int         a109FreeOverAll;
  int         a109PaidOverAll;
  //Customer10
  int         a110CustId;
  String      a110Name;
  String      a110Address;
  int         a110Phone;
  Timestamp   a110Date; 
  String      a110Remarks;
  int         a110PromoLoadsCurr;
  int         a110FreeCurr;
  int         a110BalCurr;
  Timestamp   a110FreeDate;
  int         a110LoadsOverAll;
  int         a110FreeOverAll;
  int         a110PaidOverAll;
  //Customer11
  int         a111CustId;
  String      a111Name;
  String      a111Address;
  int         a111Phone;
  Timestamp   a111Date; 
  String      a111Remarks;
  int         a111PromoLoadsCurr;
  int         a111FreeCurr;
  int         a111BalCurr;
  Timestamp   a111FreeDate;
  int         a111LoadsOverAll;
  int         a111FreeOverAll;
  int         a111PaidOverAll;
  //Customer12
  int         a112CustId;
  String      a112Name;
  String      a112Address;
  int         a112Phone;
  Timestamp   a112Date; 
  String      a112Remarks;
  int         a112PromoLoadsCurr;
  int         a112FreeCurr;
  int         a112BalCurr;
  Timestamp   a112FreeDate;
  int         a112LoadsOverAll;
  int         a112FreeOverAll;
  int         a112PaidOverAll;
  //Customer13
  int         a113CustId;
  String      a113Name;
  String      a113Address;
  int         a113Phone;
  Timestamp   a113Date; 
  String      a113Remarks;
  int         a113PromoLoadsCurr;
  int         a113FreeCurr;
  int         a113BalCurr;
  Timestamp   a113FreeDate;
  int         a113LoadsOverAll;
  int         a113FreeOverAll;
  int         a113PaidOverAll;
  //Customer14
  int         a114CustId;
  String      a114Name;
  String      a114Address;
  int         a114Phone;
  Timestamp   a114Date; 
  String      a114Remarks;
  int         a114PromoLoadsCurr;
  int         a114FreeCurr;
  int         a114BalCurr;
  Timestamp   a114FreeDate;
  int         a114LoadsOverAll;
  int         a114FreeOverAll;
  int         a114PaidOverAll;
  //Customer15
  int         a115CustId;
  String      a115Name;
  String      a115Address;
  int         a115Phone;
  Timestamp   a115Date; 
  String      a115Remarks;
  int         a115PromoLoadsCurr;
  int         a115FreeCurr;
  int         a115BalCurr;
  Timestamp   a115FreeDate;
  int         a115LoadsOverAll;
  int         a115FreeOverAll;
  int         a115PaidOverAll;
  //Customer16
  int         a116CustId;
  String      a116Name;
  String      a116Address;
  int         a116Phone;
  Timestamp   a116Date; 
  String      a116Remarks;
  int         a116PromoLoadsCurr;
  int         a116FreeCurr;
  int         a116BalCurr;
  Timestamp   a116FreeDate;
  int         a116LoadsOverAll;
  int         a116FreeOverAll;
  int         a116PaidOverAll;
  //Customer17
  int         a117CustId;
  String      a117Name;
  String      a117Address;
  int         a117Phone;
  Timestamp   a117Date; 
  String      a117Remarks;
  int         a117PromoLoadsCurr;
  int         a117FreeCurr;
  int         a117BalCurr;
  Timestamp   a117FreeDate;
  int         a117LoadsOverAll;
  int         a117FreeOverAll;
  int         a117PaidOverAll;
  //Customer18
  int         a118CustId;
  String      a118Name;
  String      a118Address;
  int         a118Phone;
  Timestamp   a118Date; 
  String      a118Remarks;
  int         a118PromoLoadsCurr;
  int         a118FreeCurr;
  int         a118BalCurr;
  Timestamp   a118FreeDate;
  int         a118LoadsOverAll;
  int         a118FreeOverAll;
  int         a118PaidOverAll;
  //Customer19
  int         a119CustId;
  String      a119Name;
  String      a119Address;
  int         a119Phone;
  Timestamp   a119Date; 
  String      a119Remarks;
  int         a119PromoLoadsCurr;
  int         a119FreeCurr;
  int         a119BalCurr;
  Timestamp   a119FreeDate;
  int         a119LoadsOverAll;
  int         a119FreeOverAll;
  int         a119PaidOverAll;
  //Customer20
  int         a120CustId;
  String      a120Name;
  String      a120Address;
  int         a120Phone;
  Timestamp   a120Date; 
  String      a120Remarks;
  int         a120PromoLoadsCurr;
  int         a120FreeCurr;
  int         a120BalCurr;
  Timestamp   a120FreeDate;
  int         a120LoadsOverAll;
  int         a120FreeOverAll;
  int         a120PaidOverAll;

  CustomerFirebaseModel({
required this.docId,
required this.a101CustId,
required this.a101Name,
required this.a101Address,
required this.a101Phone,
required this.a101Date, 
required this.a101Remarks,
required this.a101PromoLoadsCurr,
required this.a101FreeCurr,
required this.a101BalCurr,
required this.a101FreeDate,
required this.a101LoadsOverAll,
required this.a101FreeOverAll,
required this.a101PaidOverAll,
required this.a102CustId,
required this.a102Name,
required this.a102Address,
required this.a102Phone,
required this.a102Date, 
required this.a102Remarks,
required this.a102PromoLoadsCurr,
required this.a102FreeCurr,
required this.a102BalCurr,
required this.a102FreeDate,
required this.a102LoadsOverAll,
required this.a102FreeOverAll,
required this.a102PaidOverAll,
required this.a103CustId,
required this.a103Name,
required this.a103Address,
required this.a103Phone,
required this.a103Date, 
required this.a103Remarks,
required this.a103PromoLoadsCurr,
required this.a103FreeCurr,
required this.a103BalCurr,
required this.a103FreeDate,
required this.a103LoadsOverAll,
required this.a103FreeOverAll,
required this.a103PaidOverAll,
required this.a104CustId,
required this.a104Name,
required this.a104Address,
required this.a104Phone,
required this.a104Date, 
required this.a104Remarks,
required this.a104PromoLoadsCurr,
required this.a104FreeCurr,
required this.a104BalCurr,
required this.a104FreeDate,
required this.a104LoadsOverAll,
required this.a104FreeOverAll,
required this.a104PaidOverAll,
required this.a105CustId,
required this.a105Name,
required this.a105Address,
required this.a105Phone,
required this.a105Date, 
required this.a105Remarks,
required this.a105PromoLoadsCurr,
required this.a105FreeCurr,
required this.a105BalCurr,
required this.a105FreeDate,
required this.a105LoadsOverAll,
required this.a105FreeOverAll,
required this.a105PaidOverAll,
required this.a106CustId,
required this.a106Name,
required this.a106Address,
required this.a106Phone,
required this.a106Date, 
required this.a106Remarks,
required this.a106PromoLoadsCurr,
required this.a106FreeCurr,
required this.a106BalCurr,
required this.a106FreeDate,
required this.a106LoadsOverAll,
required this.a106FreeOverAll,
required this.a106PaidOverAll,
required this.a107CustId,
required this.a107Name,
required this.a107Address,
required this.a107Phone,
required this.a107Date, 
required this.a107Remarks,
required this.a107PromoLoadsCurr,
required this.a107FreeCurr,
required this.a107BalCurr,
required this.a107FreeDate,
required this.a107LoadsOverAll,
required this.a107FreeOverAll,
required this.a107PaidOverAll,
required this.a108CustId,
required this.a108Name,
required this.a108Address,
required this.a108Phone,
required this.a108Date, 
required this.a108Remarks,
required this.a108PromoLoadsCurr,
required this.a108FreeCurr,
required this.a108BalCurr,
required this.a108FreeDate,
required this.a108LoadsOverAll,
required this.a108FreeOverAll,
required this.a108PaidOverAll,
required this.a109CustId,
required this.a109Name,
required this.a109Address,
required this.a109Phone,
required this.a109Date, 
required this.a109Remarks,
required this.a109PromoLoadsCurr,
required this.a109FreeCurr,
required this.a109BalCurr,
required this.a109FreeDate,
required this.a109LoadsOverAll,
required this.a109FreeOverAll,
required this.a109PaidOverAll,
required this.a110CustId,
required this.a110Name,
required this.a110Address,
required this.a110Phone,
required this.a110Date, 
required this.a110Remarks,
required this.a110PromoLoadsCurr,
required this.a110FreeCurr,
required this.a110BalCurr,
required this.a110FreeDate,
required this.a110LoadsOverAll,
required this.a110FreeOverAll,
required this.a110PaidOverAll,
required this.a111CustId,
required this.a111Name,
required this.a111Address,
required this.a111Phone,
required this.a111Date, 
required this.a111Remarks,
required this.a111PromoLoadsCurr,
required this.a111FreeCurr,
required this.a111BalCurr,
required this.a111FreeDate,
required this.a111LoadsOverAll,
required this.a111FreeOverAll,
required this.a111PaidOverAll,
required this.a112CustId,
required this.a112Name,
required this.a112Address,
required this.a112Phone,
required this.a112Date, 
required this.a112Remarks,
required this.a112PromoLoadsCurr,
required this.a112FreeCurr,
required this.a112BalCurr,
required this.a112FreeDate,
required this.a112LoadsOverAll,
required this.a112FreeOverAll,
required this.a112PaidOverAll,
required this.a113CustId,
required this.a113Name,
required this.a113Address,
required this.a113Phone,
required this.a113Date, 
required this.a113Remarks,
required this.a113PromoLoadsCurr,
required this.a113FreeCurr,
required this.a113BalCurr,
required this.a113FreeDate,
required this.a113LoadsOverAll,
required this.a113FreeOverAll,
required this.a113PaidOverAll,
required this.a114CustId,
required this.a114Name,
required this.a114Address,
required this.a114Phone,
required this.a114Date, 
required this.a114Remarks,
required this.a114PromoLoadsCurr,
required this.a114FreeCurr,
required this.a114BalCurr,
required this.a114FreeDate,
required this.a114LoadsOverAll,
required this.a114FreeOverAll,
required this.a114PaidOverAll,
required this.a115CustId,
required this.a115Name,
required this.a115Address,
required this.a115Phone,
required this.a115Date, 
required this.a115Remarks,
required this.a115PromoLoadsCurr,
required this.a115FreeCurr,
required this.a115BalCurr,
required this.a115FreeDate,
required this.a115LoadsOverAll,
required this.a115FreeOverAll,
required this.a115PaidOverAll,
required this.a116CustId,
required this.a116Name,
required this.a116Address,
required this.a116Phone,
required this.a116Date, 
required this.a116Remarks,
required this.a116PromoLoadsCurr,
required this.a116FreeCurr,
required this.a116BalCurr,
required this.a116FreeDate,
required this.a116LoadsOverAll,
required this.a116FreeOverAll,
required this.a116PaidOverAll,
required this.a117CustId,
required this.a117Name,
required this.a117Address,
required this.a117Phone,
required this.a117Date, 
required this.a117Remarks,
required this.a117PromoLoadsCurr,
required this.a117FreeCurr,
required this.a117BalCurr,
required this.a117FreeDate,
required this.a117LoadsOverAll,
required this.a117FreeOverAll,
required this.a117PaidOverAll,
required this.a118CustId,
required this.a118Name,
required this.a118Address,
required this.a118Phone,
required this.a118Date, 
required this.a118Remarks,
required this.a118PromoLoadsCurr,
required this.a118FreeCurr,
required this.a118BalCurr,
required this.a118FreeDate,
required this.a118LoadsOverAll,
required this.a118FreeOverAll,
required this.a118PaidOverAll,
required this.a119CustId,
required this.a119Name,
required this.a119Address,
required this.a119Phone,
required this.a119Date, 
required this.a119Remarks,
required this.a119PromoLoadsCurr,
required this.a119FreeCurr,
required this.a119BalCurr,
required this.a119FreeDate,
required this.a119LoadsOverAll,
required this.a119FreeOverAll,
required this.a119PaidOverAll,
required this.a120CustId,
required this.a120Name,
required this.a120Address,
required this.a120Phone,
required this.a120Date, 
required this.a120Remarks,
required this.a120PromoLoadsCurr,
required this.a120FreeCurr,
required this.a120BalCurr,
required this.a120FreeDate,
required this.a120LoadsOverAll,
required this.a120FreeOverAll,
required this.a120PaidOverAll,

  });

  CustomerFirebaseModel.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['DocId']! as String,
          //customer 1
          a101CustId:         json['a101CustId']! as int,
          a101Name:           json['a101Name']! as String,
          a101Address:        json['a101Address']! as String,
          a101Phone:          json['a101Phone']! as int,
          a101Date:           json['a101Date']! as Timestamp,
          a101Remarks:        json['a101Remarks']! as String,
          a101PromoLoadsCurr: json['a101PromoLoadsCurr']! as int,
          a101FreeCurr:       json['a101FreeCurr']! as int,
          a101BalCurr:        json['a101BalCurr']! as int,
          a101FreeDate:       json['a101FreeDate']! as Timestamp,
          a101LoadsOverAll:   json['a101LoadsOverAll']! as int,
          a101FreeOverAll:    json['a101FreeOverAll']! as int,
          a101PaidOverAll:    json['a101PaidOverAll']! as int,
          //customer 2
          a102CustId:         json['a102CustId']! as int,
          a102Name:           json['a102Name']! as String,
          a102Address:        json['a102Address']! as String,
          a102Phone:          json['a102Phone']! as int,
          a102Date:           json['a102Date']! as Timestamp,
          a102Remarks:        json['a102Remarks']! as String,
          a102PromoLoadsCurr: json['a102PromoLoadsCurr']! as int,
          a102FreeCurr:       json['a102FreeCurr']! as int,
          a102BalCurr:        json['a102BalCurr']! as int,
          a102FreeDate:       json['a102FreeDate']! as Timestamp,
          a102LoadsOverAll:   json['a102LoadsOverAll']! as int,
          a102FreeOverAll:    json['a102FreeOverAll']! as int,
          a102PaidOverAll:    json['a102PaidOverAll']! as int,
          //customer 3
          a103CustId:         json['a103CustId']! as int,
          a103Name:           json['a103Name']! as String,
          a103Address:        json['a103Address']! as String,
          a103Phone:          json['a103Phone']! as int,
          a103Date:           json['a103Date']! as Timestamp,
          a103Remarks:        json['a103Remarks']! as String,
          a103PromoLoadsCurr: json['a103PromoLoadsCurr']! as int,
          a103FreeCurr:       json['a103FreeCurr']! as int,
          a103BalCurr:        json['a103BalCurr']! as int,
          a103FreeDate:       json['a103FreeDate']! as Timestamp,
          a103LoadsOverAll:   json['a103LoadsOverAll']! as int,
          a103FreeOverAll:    json['a103FreeOverAll']! as int,
          a103PaidOverAll:    json['a103PaidOverAll']! as int,
          //customer 4
          a104CustId:         json['a104CustId']! as int,
          a104Name:           json['a104Name']! as String,
          a104Address:        json['a104Address']! as String,
          a104Phone:          json['a104Phone']! as int,
          a104Date:           json['a104Date']! as Timestamp,
          a104Remarks:        json['a104Remarks']! as String,
          a104PromoLoadsCurr: json['a104PromoLoadsCurr']! as int,
          a104FreeCurr:       json['a104FreeCurr']! as int,
          a104BalCurr:        json['a104BalCurr']! as int,
          a104FreeDate:       json['a104FreeDate']! as Timestamp,
          a104LoadsOverAll:   json['a104LoadsOverAll']! as int,
          a104FreeOverAll:    json['a104FreeOverAll']! as int,
          a104PaidOverAll:    json['a104PaidOverAll']! as int,
          //customer 5
          a105CustId:         json['a105CustId']! as int,
          a105Name:           json['a105Name']! as String,
          a105Address:        json['a105Address']! as String,
          a105Phone:          json['a105Phone']! as int,
          a105Date:           json['a105Date']! as Timestamp,
          a105Remarks:        json['a105Remarks']! as String,
          a105PromoLoadsCurr: json['a105PromoLoadsCurr']! as int,
          a105FreeCurr:       json['a105FreeCurr']! as int,
          a105BalCurr:        json['a105BalCurr']! as int,
          a105FreeDate:       json['a105FreeDate']! as Timestamp,
          a105LoadsOverAll:   json['a105LoadsOverAll']! as int,
          a105FreeOverAll:    json['a105FreeOverAll']! as int,
          a105PaidOverAll:    json['a105PaidOverAll']! as int,
          //customer 6
          a106CustId:         json['a106CustId']! as int,
          a106Name:           json['a106Name']! as String,
          a106Address:        json['a106Address']! as String,
          a106Phone:          json['a106Phone']! as int,
          a106Date:           json['a106Date']! as Timestamp,
          a106Remarks:        json['a106Remarks']! as String,
          a106PromoLoadsCurr: json['a106PromoLoadsCurr']! as int,
          a106FreeCurr:       json['a106FreeCurr']! as int,
          a106BalCurr:        json['a106BalCurr']! as int,
          a106FreeDate:       json['a106FreeDate']! as Timestamp,
          a106LoadsOverAll:   json['a106LoadsOverAll']! as int,
          a106FreeOverAll:    json['a106FreeOverAll']! as int,
          a106PaidOverAll:    json['a106PaidOverAll']! as int,
          //customer 7
          a107CustId:         json['a107CustId']! as int,
          a107Name:           json['a107Name']! as String,
          a107Address:        json['a107Address']! as String,
          a107Phone:          json['a107Phone']! as int,
          a107Date:           json['a107Date']! as Timestamp,
          a107Remarks:        json['a107Remarks']! as String,
          a107PromoLoadsCurr: json['a107PromoLoadsCurr']! as int,
          a107FreeCurr:       json['a107FreeCurr']! as int,
          a107BalCurr:        json['a107BalCurr']! as int,
          a107FreeDate:       json['a107FreeDate']! as Timestamp,
          a107LoadsOverAll:   json['a107LoadsOverAll']! as int,
          a107FreeOverAll:    json['a107FreeOverAll']! as int,
          a107PaidOverAll:    json['a107PaidOverAll']! as int,
          //customer 8
          a108CustId:         json['a108CustId']! as int,
          a108Name:           json['a108Name']! as String,
          a108Address:        json['a108Address']! as String,
          a108Phone:          json['a108Phone']! as int,
          a108Date:           json['a108Date']! as Timestamp,
          a108Remarks:        json['a108Remarks']! as String,
          a108PromoLoadsCurr: json['a108PromoLoadsCurr']! as int,
          a108FreeCurr:       json['a108FreeCurr']! as int,
          a108BalCurr:        json['a108BalCurr']! as int,
          a108FreeDate:       json['a108FreeDate']! as Timestamp,
          a108LoadsOverAll:   json['a108LoadsOverAll']! as int,
          a108FreeOverAll:    json['a108FreeOverAll']! as int,
          a108PaidOverAll:    json['a108PaidOverAll']! as int,
          //customer 9
          a109CustId:         json['a109CustId']! as int,
          a109Name:           json['a109Name']! as String,
          a109Address:        json['a109Address']! as String,
          a109Phone:          json['a109Phone']! as int,
          a109Date:           json['a109Date']! as Timestamp,
          a109Remarks:        json['a109Remarks']! as String,
          a109PromoLoadsCurr: json['a109PromoLoadsCurr']! as int,
          a109FreeCurr:       json['a109FreeCurr']! as int,
          a109BalCurr:        json['a109BalCurr']! as int,
          a109FreeDate:       json['a109FreeDate']! as Timestamp,
          a109LoadsOverAll:   json['a109LoadsOverAll']! as int,
          a109FreeOverAll:    json['a109FreeOverAll']! as int,
          a109PaidOverAll:    json['a109PaidOverAll']! as int,
          //customer 10
          a110CustId:         json['a110CustId']! as int,
          a110Name:           json['a110Name']! as String,
          a110Address:        json['a110Address']! as String,
          a110Phone:          json['a110Phone']! as int,
          a110Date:           json['a110Date']! as Timestamp,
          a110Remarks:        json['a110Remarks']! as String,
          a110PromoLoadsCurr: json['a110PromoLoadsCurr']! as int,
          a110FreeCurr:       json['a110FreeCurr']! as int,
          a110BalCurr:        json['a110BalCurr']! as int,
          a110FreeDate:       json['a110FreeDate']! as Timestamp,
          a110LoadsOverAll:   json['a110LoadsOverAll']! as int,
          a110FreeOverAll:    json['a110FreeOverAll']! as int,
          a110PaidOverAll:    json['a110PaidOverAll']! as int,
          //customer 11
          a111CustId:         json['a111CustId']! as int,
          a111Name:           json['a111Name']! as String,
          a111Address:        json['a111Address']! as String,
          a111Phone:          json['a111Phone']! as int,
          a111Date:           json['a111Date']! as Timestamp,
          a111Remarks:        json['a111Remarks']! as String,
          a111PromoLoadsCurr: json['a111PromoLoadsCurr']! as int,
          a111FreeCurr:       json['a111FreeCurr']! as int,
          a111BalCurr:        json['a111BalCurr']! as int,
          a111FreeDate:       json['a111FreeDate']! as Timestamp,
          a111LoadsOverAll:   json['a111LoadsOverAll']! as int,
          a111FreeOverAll:    json['a111FreeOverAll']! as int,
          a111PaidOverAll:    json['a111PaidOverAll']! as int,
          //customer 12
          a112CustId:         json['a112CustId']! as int,
          a112Name:           json['a112Name']! as String,
          a112Address:        json['a112Address']! as String,
          a112Phone:          json['a112Phone']! as int,
          a112Date:           json['a112Date']! as Timestamp,
          a112Remarks:        json['a112Remarks']! as String,
          a112PromoLoadsCurr: json['a112PromoLoadsCurr']! as int,
          a112FreeCurr:       json['a112FreeCurr']! as int,
          a112BalCurr:        json['a112BalCurr']! as int,
          a112FreeDate:       json['a112FreeDate']! as Timestamp,
          a112LoadsOverAll:   json['a112LoadsOverAll']! as int,
          a112FreeOverAll:    json['a112FreeOverAll']! as int,
          a112PaidOverAll:    json['a112PaidOverAll']! as int,          
          //customer 13
          a113CustId:         json['a113CustId']! as int,
          a113Name:           json['a113Name']! as String,
          a113Address:        json['a113Address']! as String,
          a113Phone:          json['a113Phone']! as int,
          a113Date:           json['a113Date']! as Timestamp,
          a113Remarks:        json['a113Remarks']! as String,
          a113PromoLoadsCurr: json['a113PromoLoadsCurr']! as int,
          a113FreeCurr:       json['a113FreeCurr']! as int,
          a113BalCurr:        json['a113BalCurr']! as int,
          a113FreeDate:       json['a113FreeDate']! as Timestamp,
          a113LoadsOverAll:   json['a113LoadsOverAll']! as int,
          a113FreeOverAll:    json['a113FreeOverAll']! as int,
          a113PaidOverAll:    json['a113PaidOverAll']! as int,          
          //customer 14
          a114CustId:         json['a114CustId']! as int,
          a114Name:           json['a114Name']! as String,
          a114Address:        json['a114Address']! as String,
          a114Phone:          json['a114Phone']! as int,
          a114Date:           json['a114Date']! as Timestamp,
          a114Remarks:        json['a114Remarks']! as String,
          a114PromoLoadsCurr: json['a114PromoLoadsCurr']! as int,
          a114FreeCurr:       json['a114FreeCurr']! as int,
          a114BalCurr:        json['a114BalCurr']! as int,
          a114FreeDate:       json['a114FreeDate']! as Timestamp,
          a114LoadsOverAll:   json['a114LoadsOverAll']! as int,
          a114FreeOverAll:    json['a114FreeOverAll']! as int,
          a114PaidOverAll:    json['a114PaidOverAll']! as int,          
          //customer 15
          a115CustId:         json['a115CustId']! as int,
          a115Name:           json['a115Name']! as String,
          a115Address:        json['a115Address']! as String,
          a115Phone:          json['a115Phone']! as int,
          a115Date:           json['a115Date']! as Timestamp,
          a115Remarks:        json['a115Remarks']! as String,
          a115PromoLoadsCurr: json['a115PromoLoadsCurr']! as int,
          a115FreeCurr:       json['a115FreeCurr']! as int,
          a115BalCurr:        json['a115BalCurr']! as int,
          a115FreeDate:       json['a115FreeDate']! as Timestamp,
          a115LoadsOverAll:   json['a115LoadsOverAll']! as int,
          a115FreeOverAll:    json['a115FreeOverAll']! as int,
          a115PaidOverAll:    json['a115PaidOverAll']! as int,          
          //customer 16
          a116CustId:         json['a116CustId']! as int,
          a116Name:           json['a116Name']! as String,
          a116Address:        json['a116Address']! as String,
          a116Phone:          json['a116Phone']! as int,
          a116Date:           json['a116Date']! as Timestamp,
          a116Remarks:        json['a116Remarks']! as String,
          a116PromoLoadsCurr: json['a116PromoLoadsCurr']! as int,
          a116FreeCurr:       json['a116FreeCurr']! as int,
          a116BalCurr:        json['a116BalCurr']! as int,
          a116FreeDate:       json['a116FreeDate']! as Timestamp,
          a116LoadsOverAll:   json['a116LoadsOverAll']! as int,
          a116FreeOverAll:    json['a116FreeOverAll']! as int,
          a116PaidOverAll:    json['a116PaidOverAll']! as int,          
          //customer 17
          a117CustId:         json['a117CustId']! as int,
          a117Name:           json['a117Name']! as String,
          a117Address:        json['a117Address']! as String,
          a117Phone:          json['a117Phone']! as int,
          a117Date:           json['a117Date']! as Timestamp,
          a117Remarks:        json['a117Remarks']! as String,
          a117PromoLoadsCurr: json['a117PromoLoadsCurr']! as int,
          a117FreeCurr:       json['a117FreeCurr']! as int,
          a117BalCurr:        json['a117BalCurr']! as int,
          a117FreeDate:       json['a117FreeDate']! as Timestamp,
          a117LoadsOverAll:   json['a117LoadsOverAll']! as int,
          a117FreeOverAll:    json['a117FreeOverAll']! as int,
          a117PaidOverAll:    json['a117PaidOverAll']! as int,          
          //customer 18
          a118CustId:         json['a118CustId']! as int,
          a118Name:           json['a118Name']! as String,
          a118Address:        json['a118Address']! as String,
          a118Phone:          json['a118Phone']! as int,
          a118Date:           json['a118Date']! as Timestamp,
          a118Remarks:        json['a118Remarks']! as String,
          a118PromoLoadsCurr: json['a118PromoLoadsCurr']! as int,
          a118FreeCurr:       json['a118FreeCurr']! as int,
          a118BalCurr:        json['a118BalCurr']! as int,
          a118FreeDate:       json['a118FreeDate']! as Timestamp,
          a118LoadsOverAll:   json['a118LoadsOverAll']! as int,
          a118FreeOverAll:    json['a118FreeOverAll']! as int,
          a118PaidOverAll:    json['a118PaidOverAll']! as int,          
          //customer 19
          a119CustId:         json['a119CustId']! as int,
          a119Name:           json['a119Name']! as String,
          a119Address:        json['a119Address']! as String,
          a119Phone:          json['a119Phone']! as int,
          a119Date:           json['a119Date']! as Timestamp,
          a119Remarks:        json['a119Remarks']! as String,
          a119PromoLoadsCurr: json['a119PromoLoadsCurr']! as int,
          a119FreeCurr:       json['a119FreeCurr']! as int,
          a119BalCurr:        json['a119BalCurr']! as int,
          a119FreeDate:       json['a119FreeDate']! as Timestamp,
          a119LoadsOverAll:   json['a119LoadsOverAll']! as int,
          a119FreeOverAll:    json['a119FreeOverAll']! as int,
          a119PaidOverAll:    json['a119PaidOverAll']! as int,          
          //customer 20
          a120CustId:         json['a120CustId']! as int,
          a120Name:           json['a120Name']! as String,
          a120Address:        json['a120Address']! as String,
          a120Phone:          json['a120Phone']! as int,
          a120Date:           json['a120Date']! as Timestamp,
          a120Remarks:        json['a120Remarks']! as String,
          a120PromoLoadsCurr: json['a120PromoLoadsCurr']! as int,
          a120FreeCurr:       json['a120FreeCurr']! as int,
          a120BalCurr:        json['a120BalCurr']! as int,
          a120FreeDate:       json['a120FreeDate']! as Timestamp,
          a120LoadsOverAll:   json['a120LoadsOverAll']! as int,
          a120FreeOverAll:    json['a120FreeOverAll']! as int,
          a120PaidOverAll:    json['a120PaidOverAll']! as int,          
        );

  CustomerFirebaseModel coyWith({
  String?      docId,
  //Customer1
  int?         a101CustId,
  String?      a101Name,
  String?      a101Address,
  int?         a101Phone,
  Timestamp?   a101Date, 
  String?      a101Remarks,
  int?         a101PromoLoadsCurr,
  int?         a101FreeCurr,
  int?         a101BalCurr,
  Timestamp?   a101FreeDate,
  int?         a101LoadsOverAll,
  int?         a101FreeOverAll,
  int?         a101PaidOverAll,
  //Customer2
  int?         a102CustId,
  String?      a102Name,
  String?      a102Address,
  int?         a102Phone,
  Timestamp?   a102Date, 
  String?      a102Remarks,
  int?         a102PromoLoadsCurr,
  int?         a102FreeCurr,
  int?         a102BalCurr,
  Timestamp?   a102FreeDate,
  int?         a102LoadsOverAll,
  int?         a102FreeOverAll,
  int?         a102PaidOverAll,
  //Customer3
  int?         a103CustId,
  String?      a103Name,
  String?      a103Address,
  int?         a103Phone,
  Timestamp?   a103Date, 
  String?      a103Remarks,
  int?         a103PromoLoadsCurr,
  int?         a103FreeCurr,
  int?         a103BalCurr,
  Timestamp?   a103FreeDate,
  int?         a103LoadsOverAll,
  int?         a103FreeOverAll,
  int?         a103PaidOverAll,
  //Customer4
  int?         a104CustId,
  String?      a104Name,
  String?      a104Address,
  int?         a104Phone,
  Timestamp?   a104Date, 
  String?      a104Remarks,
  int?         a104PromoLoadsCurr,
  int?         a104FreeCurr,
  int?         a104BalCurr,
  Timestamp?   a104FreeDate,
  int?         a104LoadsOverAll,
  int?         a104FreeOverAll,
  int?         a104PaidOverAll,
  //Customer5
  int?         a105CustId,
  String?      a105Name,
  String?      a105Address,
  int?         a105Phone,
  Timestamp?   a105Date, 
  String?      a105Remarks,
  int?         a105PromoLoadsCurr,
  int?         a105FreeCurr,
  int?         a105BalCurr,
  Timestamp?   a105FreeDate,
  int?         a105LoadsOverAll,
  int?         a105FreeOverAll,
  int?         a105PaidOverAll,
  //Customer6
  int?         a106CustId,
  String?      a106Name,
  String?      a106Address,
  int?         a106Phone,
  Timestamp?   a106Date, 
  String?      a106Remarks,
  int?         a106PromoLoadsCurr,
  int?         a106FreeCurr,
  int?         a106BalCurr,
  Timestamp?   a106FreeDate,
  int?         a106LoadsOverAll,
  int?         a106FreeOverAll,
  int?         a106PaidOverAll,
  //Customer7
  int?         a107CustId,
  String?      a107Name,
  String?      a107Address,
  int?         a107Phone,
  Timestamp?   a107Date, 
  String?      a107Remarks,
  int?         a107PromoLoadsCurr,
  int?         a107FreeCurr,
  int?         a107BalCurr,
  Timestamp?   a107FreeDate,
  int?         a107LoadsOverAll,
  int?         a107FreeOverAll,
  int?         a107PaidOverAll,
  //Customer8
  int?         a108CustId,
  String?      a108Name,
  String?      a108Address,
  int?         a108Phone,
  Timestamp?   a108Date, 
  String?      a108Remarks,
  int?         a108PromoLoadsCurr,
  int?         a108FreeCurr,
  int?         a108BalCurr,
  Timestamp?   a108FreeDate,
  int?         a108LoadsOverAll,
  int?         a108FreeOverAll,
  int?         a108PaidOverAll,
  //Customer9
  int?         a109CustId,
  String?      a109Name,
  String?      a109Address,
  int?         a109Phone,
  Timestamp?   a109Date, 
  String?      a109Remarks,
  int?         a109PromoLoadsCurr,
  int?         a109FreeCurr,
  int?         a109BalCurr,
  Timestamp?   a109FreeDate,
  int?         a109LoadsOverAll,
  int?         a109FreeOverAll,
  int?         a109PaidOverAll,
  //Customer10
  int?         a110CustId,
  String?      a110Name,
  String?      a110Address,
  int?         a110Phone,
  Timestamp?   a110Date, 
  String?      a110Remarks,
  int?         a110PromoLoadsCurr,
  int?         a110FreeCurr,
  int?         a110BalCurr,
  Timestamp?   a110FreeDate,
  int?         a110LoadsOverAll,
  int?         a110FreeOverAll,
  int?         a110PaidOverAll,
  //Customer11
  int?         a111CustId,
  String?      a111Name,
  String?      a111Address,
  int?         a111Phone,
  Timestamp?   a111Date, 
  String?      a111Remarks,
  int?         a111PromoLoadsCurr,
  int?         a111FreeCurr,
  int?         a111BalCurr,
  Timestamp?   a111FreeDate,
  int?         a111LoadsOverAll,
  int?         a111FreeOverAll,
  int?         a111PaidOverAll,
  //Customer12
  int?         a112CustId,
  String?      a112Name,
  String?      a112Address,
  int?         a112Phone,
  Timestamp?   a112Date, 
  String?      a112Remarks,
  int?         a112PromoLoadsCurr,
  int?         a112FreeCurr,
  int?         a112BalCurr,
  Timestamp?   a112FreeDate,
  int?         a112LoadsOverAll,
  int?         a112FreeOverAll,
  int?         a112PaidOverAll,
  //Customer13
  int?         a113CustId,
  String?      a113Name,
  String?      a113Address,
  int?         a113Phone,
  Timestamp?   a113Date, 
  String?      a113Remarks,
  int?         a113PromoLoadsCurr,
  int?         a113FreeCurr,
  int?         a113BalCurr,
  Timestamp?   a113FreeDate,
  int?         a113LoadsOverAll,
  int?         a113FreeOverAll,
  int?         a113PaidOverAll,
  //Customer14
  int?         a114CustId,
  String?      a114Name,
  String?      a114Address,
  int?         a114Phone,
  Timestamp?   a114Date, 
  String?      a114Remarks,
  int?         a114PromoLoadsCurr,
  int?         a114FreeCurr,
  int?         a114BalCurr,
  Timestamp?   a114FreeDate,
  int?         a114LoadsOverAll,
  int?         a114FreeOverAll,
  int?         a114PaidOverAll,
  //Customer15
  int?         a115CustId,
  String?      a115Name,
  String?      a115Address,
  int?         a115Phone,
  Timestamp?   a115Date, 
  String?      a115Remarks,
  int?         a115PromoLoadsCurr,
  int?         a115FreeCurr,
  int?         a115BalCurr,
  Timestamp?   a115FreeDate,
  int?         a115LoadsOverAll,
  int?         a115FreeOverAll,
  int?         a115PaidOverAll,
  //Customer16
  int?         a116CustId,
  String?      a116Name,
  String?      a116Address,
  int?         a116Phone,
  Timestamp?   a116Date, 
  String?      a116Remarks,
  int?         a116PromoLoadsCurr,
  int?         a116FreeCurr,
  int?         a116BalCurr,
  Timestamp?   a116FreeDate,
  int?         a116LoadsOverAll,
  int?         a116FreeOverAll,
  int?         a116PaidOverAll,
  //Customer17
  int?         a117CustId,
  String?      a117Name,
  String?      a117Address,
  int?         a117Phone,
  Timestamp?   a117Date, 
  String?      a117Remarks,
  int?         a117PromoLoadsCurr,
  int?         a117FreeCurr,
  int?         a117BalCurr,
  Timestamp?   a117FreeDate,
  int?         a117LoadsOverAll,
  int?         a117FreeOverAll,
  int?         a117PaidOverAll,
  //Customer18
  int?         a118CustId,
  String?      a118Name,
  String?      a118Address,
  int?         a118Phone,
  Timestamp?   a118Date, 
  String?      a118Remarks,
  int?         a118PromoLoadsCurr,
  int?         a118FreeCurr,
  int?         a118BalCurr,
  Timestamp?   a118FreeDate,
  int?         a118LoadsOverAll,
  int?         a118FreeOverAll,
  int?         a118PaidOverAll,
  //Customer19
  int?         a119CustId,
  String?      a119Name,
  String?      a119Address,
  int?         a119Phone,
  Timestamp?   a119Date, 
  String?      a119Remarks,
  int?         a119PromoLoadsCurr,
  int?         a119FreeCurr,
  int?         a119BalCurr,
  Timestamp?   a119FreeDate,
  int?         a119LoadsOverAll,
  int?         a119FreeOverAll,
  int?         a119PaidOverAll,
  //Customer20
  int?         a120CustId,
  String?      a120Name,
  String?      a120Address,
  int?         a120Phone,
  Timestamp?   a120Date, 
  String?      a120Remarks,
  int?         a120PromoLoadsCurr,
  int?         a120FreeCurr,
  int?         a120BalCurr,
  Timestamp?   a120FreeDate,
  int?         a120LoadsOverAll,
  int?         a120FreeOverAll,
  int?         a120PaidOverAll,
  }) {
    return CustomerFirebaseModel(
      docId:	docId	??	this.docId,
a101CustId:	a101CustId	??	this.a101CustId,
a101Name:	a101Name	??	this.a101Name,
a101Address:	a101Address	??	this.a101Address,
a101Phone:	a101Phone	??	this.a101Phone,
a101Date :	a101Date 	??	this.a101Date ,
a101Remarks:	a101Remarks	??	this.a101Remarks,
a101PromoLoadsCurr:	a101PromoLoadsCurr	??	this.a101PromoLoadsCurr,
a101FreeCurr:	a101FreeCurr	??	this.a101FreeCurr,
a101BalCurr:	a101BalCurr	??	this.a101BalCurr,
a101FreeDate:	a101FreeDate	??	this.a101FreeDate,
a101LoadsOverAll:	a101LoadsOverAll	??	this.a101LoadsOverAll,
a101FreeOverAll:	a101FreeOverAll	??	this.a101FreeOverAll,
a101PaidOverAll:	a101PaidOverAll	??	this.a101PaidOverAll,
a102CustId:	a102CustId	??	this.a102CustId,
a102Name:	a102Name	??	this.a102Name,
a102Address:	a102Address	??	this.a102Address,
a102Phone:	a102Phone	??	this.a102Phone,
a102Date :	a102Date 	??	this.a102Date ,
a102Remarks:	a102Remarks	??	this.a102Remarks,
a102PromoLoadsCurr:	a102PromoLoadsCurr	??	this.a102PromoLoadsCurr,
a102FreeCurr:	a102FreeCurr	??	this.a102FreeCurr,
a102BalCurr:	a102BalCurr	??	this.a102BalCurr,
a102FreeDate:	a102FreeDate	??	this.a102FreeDate,
a102LoadsOverAll:	a102LoadsOverAll	??	this.a102LoadsOverAll,
a102FreeOverAll:	a102FreeOverAll	??	this.a102FreeOverAll,
a102PaidOverAll:	a102PaidOverAll	??	this.a102PaidOverAll,
a103CustId:	a103CustId	??	this.a103CustId,
a103Name:	a103Name	??	this.a103Name,
a103Address:	a103Address	??	this.a103Address,
a103Phone:	a103Phone	??	this.a103Phone,
a103Date :	a103Date 	??	this.a103Date ,
a103Remarks:	a103Remarks	??	this.a103Remarks,
a103PromoLoadsCurr:	a103PromoLoadsCurr	??	this.a103PromoLoadsCurr,
a103FreeCurr:	a103FreeCurr	??	this.a103FreeCurr,
a103BalCurr:	a103BalCurr	??	this.a103BalCurr,
a103FreeDate:	a103FreeDate	??	this.a103FreeDate,
a103LoadsOverAll:	a103LoadsOverAll	??	this.a103LoadsOverAll,
a103FreeOverAll:	a103FreeOverAll	??	this.a103FreeOverAll,
a103PaidOverAll:	a103PaidOverAll	??	this.a103PaidOverAll,
a104CustId:	a104CustId	??	this.a104CustId,
a104Name:	a104Name	??	this.a104Name,
a104Address:	a104Address	??	this.a104Address,
a104Phone:	a104Phone	??	this.a104Phone,
a104Date :	a104Date 	??	this.a104Date ,
a104Remarks:	a104Remarks	??	this.a104Remarks,
a104PromoLoadsCurr:	a104PromoLoadsCurr	??	this.a104PromoLoadsCurr,
a104FreeCurr:	a104FreeCurr	??	this.a104FreeCurr,
a104BalCurr:	a104BalCurr	??	this.a104BalCurr,
a104FreeDate:	a104FreeDate	??	this.a104FreeDate,
a104LoadsOverAll:	a104LoadsOverAll	??	this.a104LoadsOverAll,
a104FreeOverAll:	a104FreeOverAll	??	this.a104FreeOverAll,
a104PaidOverAll:	a104PaidOverAll	??	this.a104PaidOverAll,
a105CustId:	a105CustId	??	this.a105CustId,
a105Name:	a105Name	??	this.a105Name,
a105Address:	a105Address	??	this.a105Address,
a105Phone:	a105Phone	??	this.a105Phone,
a105Date :	a105Date 	??	this.a105Date ,
a105Remarks:	a105Remarks	??	this.a105Remarks,
a105PromoLoadsCurr:	a105PromoLoadsCurr	??	this.a105PromoLoadsCurr,
a105FreeCurr:	a105FreeCurr	??	this.a105FreeCurr,
a105BalCurr:	a105BalCurr	??	this.a105BalCurr,
a105FreeDate:	a105FreeDate	??	this.a105FreeDate,
a105LoadsOverAll:	a105LoadsOverAll	??	this.a105LoadsOverAll,
a105FreeOverAll:	a105FreeOverAll	??	this.a105FreeOverAll,
a105PaidOverAll:	a105PaidOverAll	??	this.a105PaidOverAll,
a106CustId:	a106CustId	??	this.a106CustId,
a106Name:	a106Name	??	this.a106Name,
a106Address:	a106Address	??	this.a106Address,
a106Phone:	a106Phone	??	this.a106Phone,
a106Date :	a106Date 	??	this.a106Date ,
a106Remarks:	a106Remarks	??	this.a106Remarks,
a106PromoLoadsCurr:	a106PromoLoadsCurr	??	this.a106PromoLoadsCurr,
a106FreeCurr:	a106FreeCurr	??	this.a106FreeCurr,
a106BalCurr:	a106BalCurr	??	this.a106BalCurr,
a106FreeDate:	a106FreeDate	??	this.a106FreeDate,
a106LoadsOverAll:	a106LoadsOverAll	??	this.a106LoadsOverAll,
a106FreeOverAll:	a106FreeOverAll	??	this.a106FreeOverAll,
a106PaidOverAll:	a106PaidOverAll	??	this.a106PaidOverAll,
a107CustId:	a107CustId	??	this.a107CustId,
a107Name:	a107Name	??	this.a107Name,
a107Address:	a107Address	??	this.a107Address,
a107Phone:	a107Phone	??	this.a107Phone,
a107Date :	a107Date 	??	this.a107Date ,
a107Remarks:	a107Remarks	??	this.a107Remarks,
a107PromoLoadsCurr:	a107PromoLoadsCurr	??	this.a107PromoLoadsCurr,
a107FreeCurr:	a107FreeCurr	??	this.a107FreeCurr,
a107BalCurr:	a107BalCurr	??	this.a107BalCurr,
a107FreeDate:	a107FreeDate	??	this.a107FreeDate,
a107LoadsOverAll:	a107LoadsOverAll	??	this.a107LoadsOverAll,
a107FreeOverAll:	a107FreeOverAll	??	this.a107FreeOverAll,
a107PaidOverAll:	a107PaidOverAll	??	this.a107PaidOverAll,
a108CustId:	a108CustId	??	this.a108CustId,
a108Name:	a108Name	??	this.a108Name,
a108Address:	a108Address	??	this.a108Address,
a108Phone:	a108Phone	??	this.a108Phone,
a108Date :	a108Date 	??	this.a108Date ,
a108Remarks:	a108Remarks	??	this.a108Remarks,
a108PromoLoadsCurr:	a108PromoLoadsCurr	??	this.a108PromoLoadsCurr,
a108FreeCurr:	a108FreeCurr	??	this.a108FreeCurr,
a108BalCurr:	a108BalCurr	??	this.a108BalCurr,
a108FreeDate:	a108FreeDate	??	this.a108FreeDate,
a108LoadsOverAll:	a108LoadsOverAll	??	this.a108LoadsOverAll,
a108FreeOverAll:	a108FreeOverAll	??	this.a108FreeOverAll,
a108PaidOverAll:	a108PaidOverAll	??	this.a108PaidOverAll,
a109CustId:	a109CustId	??	this.a109CustId,
a109Name:	a109Name	??	this.a109Name,
a109Address:	a109Address	??	this.a109Address,
a109Phone:	a109Phone	??	this.a109Phone,
a109Date :	a109Date 	??	this.a109Date ,
a109Remarks:	a109Remarks	??	this.a109Remarks,
a109PromoLoadsCurr:	a109PromoLoadsCurr	??	this.a109PromoLoadsCurr,
a109FreeCurr:	a109FreeCurr	??	this.a109FreeCurr,
a109BalCurr:	a109BalCurr	??	this.a109BalCurr,
a109FreeDate:	a109FreeDate	??	this.a109FreeDate,
a109LoadsOverAll:	a109LoadsOverAll	??	this.a109LoadsOverAll,
a109FreeOverAll:	a109FreeOverAll	??	this.a109FreeOverAll,
a109PaidOverAll:	a109PaidOverAll	??	this.a109PaidOverAll,
a110CustId:	a110CustId	??	this.a110CustId,
a110Name:	a110Name	??	this.a110Name,
a110Address:	a110Address	??	this.a110Address,
a110Phone:	a110Phone	??	this.a110Phone,
a110Date :	a110Date 	??	this.a110Date ,
a110Remarks:	a110Remarks	??	this.a110Remarks,
a110PromoLoadsCurr:	a110PromoLoadsCurr	??	this.a110PromoLoadsCurr,
a110FreeCurr:	a110FreeCurr	??	this.a110FreeCurr,
a110BalCurr:	a110BalCurr	??	this.a110BalCurr,
a110FreeDate:	a110FreeDate	??	this.a110FreeDate,
a110LoadsOverAll:	a110LoadsOverAll	??	this.a110LoadsOverAll,
a110FreeOverAll:	a110FreeOverAll	??	this.a110FreeOverAll,
a110PaidOverAll:	a110PaidOverAll	??	this.a110PaidOverAll,
a111CustId:	a111CustId	??	this.a111CustId,
a111Name:	a111Name	??	this.a111Name,
a111Address:	a111Address	??	this.a111Address,
a111Phone:	a111Phone	??	this.a111Phone,
a111Date :	a111Date 	??	this.a111Date ,
a111Remarks:	a111Remarks	??	this.a111Remarks,
a111PromoLoadsCurr:	a111PromoLoadsCurr	??	this.a111PromoLoadsCurr,
a111FreeCurr:	a111FreeCurr	??	this.a111FreeCurr,
a111BalCurr:	a111BalCurr	??	this.a111BalCurr,
a111FreeDate:	a111FreeDate	??	this.a111FreeDate,
a111LoadsOverAll:	a111LoadsOverAll	??	this.a111LoadsOverAll,
a111FreeOverAll:	a111FreeOverAll	??	this.a111FreeOverAll,
a111PaidOverAll:	a111PaidOverAll	??	this.a111PaidOverAll,
a112CustId:	a112CustId	??	this.a112CustId,
a112Name:	a112Name	??	this.a112Name,
a112Address:	a112Address	??	this.a112Address,
a112Phone:	a112Phone	??	this.a112Phone,
a112Date :	a112Date 	??	this.a112Date ,
a112Remarks:	a112Remarks	??	this.a112Remarks,
a112PromoLoadsCurr:	a112PromoLoadsCurr	??	this.a112PromoLoadsCurr,
a112FreeCurr:	a112FreeCurr	??	this.a112FreeCurr,
a112BalCurr:	a112BalCurr	??	this.a112BalCurr,
a112FreeDate:	a112FreeDate	??	this.a112FreeDate,
a112LoadsOverAll:	a112LoadsOverAll	??	this.a112LoadsOverAll,
a112FreeOverAll:	a112FreeOverAll	??	this.a112FreeOverAll,
a112PaidOverAll:	a112PaidOverAll	??	this.a112PaidOverAll,
a113CustId:	a113CustId	??	this.a113CustId,
a113Name:	a113Name	??	this.a113Name,
a113Address:	a113Address	??	this.a113Address,
a113Phone:	a113Phone	??	this.a113Phone,
a113Date :	a113Date 	??	this.a113Date ,
a113Remarks:	a113Remarks	??	this.a113Remarks,
a113PromoLoadsCurr:	a113PromoLoadsCurr	??	this.a113PromoLoadsCurr,
a113FreeCurr:	a113FreeCurr	??	this.a113FreeCurr,
a113BalCurr:	a113BalCurr	??	this.a113BalCurr,
a113FreeDate:	a113FreeDate	??	this.a113FreeDate,
a113LoadsOverAll:	a113LoadsOverAll	??	this.a113LoadsOverAll,
a113FreeOverAll:	a113FreeOverAll	??	this.a113FreeOverAll,
a113PaidOverAll:	a113PaidOverAll	??	this.a113PaidOverAll,
a114CustId:	a114CustId	??	this.a114CustId,
a114Name:	a114Name	??	this.a114Name,
a114Address:	a114Address	??	this.a114Address,
a114Phone:	a114Phone	??	this.a114Phone,
a114Date :	a114Date 	??	this.a114Date ,
a114Remarks:	a114Remarks	??	this.a114Remarks,
a114PromoLoadsCurr:	a114PromoLoadsCurr	??	this.a114PromoLoadsCurr,
a114FreeCurr:	a114FreeCurr	??	this.a114FreeCurr,
a114BalCurr:	a114BalCurr	??	this.a114BalCurr,
a114FreeDate:	a114FreeDate	??	this.a114FreeDate,
a114LoadsOverAll:	a114LoadsOverAll	??	this.a114LoadsOverAll,
a114FreeOverAll:	a114FreeOverAll	??	this.a114FreeOverAll,
a114PaidOverAll:	a114PaidOverAll	??	this.a114PaidOverAll,
a115CustId:	a115CustId	??	this.a115CustId,
a115Name:	a115Name	??	this.a115Name,
a115Address:	a115Address	??	this.a115Address,
a115Phone:	a115Phone	??	this.a115Phone,
a115Date :	a115Date 	??	this.a115Date ,
a115Remarks:	a115Remarks	??	this.a115Remarks,
a115PromoLoadsCurr:	a115PromoLoadsCurr	??	this.a115PromoLoadsCurr,
a115FreeCurr:	a115FreeCurr	??	this.a115FreeCurr,
a115BalCurr:	a115BalCurr	??	this.a115BalCurr,
a115FreeDate:	a115FreeDate	??	this.a115FreeDate,
a115LoadsOverAll:	a115LoadsOverAll	??	this.a115LoadsOverAll,
a115FreeOverAll:	a115FreeOverAll	??	this.a115FreeOverAll,
a115PaidOverAll:	a115PaidOverAll	??	this.a115PaidOverAll,
a116CustId:	a116CustId	??	this.a116CustId,
a116Name:	a116Name	??	this.a116Name,
a116Address:	a116Address	??	this.a116Address,
a116Phone:	a116Phone	??	this.a116Phone,
a116Date :	a116Date 	??	this.a116Date ,
a116Remarks:	a116Remarks	??	this.a116Remarks,
a116PromoLoadsCurr:	a116PromoLoadsCurr	??	this.a116PromoLoadsCurr,
a116FreeCurr:	a116FreeCurr	??	this.a116FreeCurr,
a116BalCurr:	a116BalCurr	??	this.a116BalCurr,
a116FreeDate:	a116FreeDate	??	this.a116FreeDate,
a116LoadsOverAll:	a116LoadsOverAll	??	this.a116LoadsOverAll,
a116FreeOverAll:	a116FreeOverAll	??	this.a116FreeOverAll,
a116PaidOverAll:	a116PaidOverAll	??	this.a116PaidOverAll,
a117CustId:	a117CustId	??	this.a117CustId,
a117Name:	a117Name	??	this.a117Name,
a117Address:	a117Address	??	this.a117Address,
a117Phone:	a117Phone	??	this.a117Phone,
a117Date :	a117Date 	??	this.a117Date ,
a117Remarks:	a117Remarks	??	this.a117Remarks,
a117PromoLoadsCurr:	a117PromoLoadsCurr	??	this.a117PromoLoadsCurr,
a117FreeCurr:	a117FreeCurr	??	this.a117FreeCurr,
a117BalCurr:	a117BalCurr	??	this.a117BalCurr,
a117FreeDate:	a117FreeDate	??	this.a117FreeDate,
a117LoadsOverAll:	a117LoadsOverAll	??	this.a117LoadsOverAll,
a117FreeOverAll:	a117FreeOverAll	??	this.a117FreeOverAll,
a117PaidOverAll:	a117PaidOverAll	??	this.a117PaidOverAll,
a118CustId:	a118CustId	??	this.a118CustId,
a118Name:	a118Name	??	this.a118Name,
a118Address:	a118Address	??	this.a118Address,
a118Phone:	a118Phone	??	this.a118Phone,
a118Date :	a118Date 	??	this.a118Date ,
a118Remarks:	a118Remarks	??	this.a118Remarks,
a118PromoLoadsCurr:	a118PromoLoadsCurr	??	this.a118PromoLoadsCurr,
a118FreeCurr:	a118FreeCurr	??	this.a118FreeCurr,
a118BalCurr:	a118BalCurr	??	this.a118BalCurr,
a118FreeDate:	a118FreeDate	??	this.a118FreeDate,
a118LoadsOverAll:	a118LoadsOverAll	??	this.a118LoadsOverAll,
a118FreeOverAll:	a118FreeOverAll	??	this.a118FreeOverAll,
a118PaidOverAll:	a118PaidOverAll	??	this.a118PaidOverAll,
a119CustId:	a119CustId	??	this.a119CustId,
a119Name:	a119Name	??	this.a119Name,
a119Address:	a119Address	??	this.a119Address,
a119Phone:	a119Phone	??	this.a119Phone,
a119Date :	a119Date 	??	this.a119Date ,
a119Remarks:	a119Remarks	??	this.a119Remarks,
a119PromoLoadsCurr:	a119PromoLoadsCurr	??	this.a119PromoLoadsCurr,
a119FreeCurr:	a119FreeCurr	??	this.a119FreeCurr,
a119BalCurr:	a119BalCurr	??	this.a119BalCurr,
a119FreeDate:	a119FreeDate	??	this.a119FreeDate,
a119LoadsOverAll:	a119LoadsOverAll	??	this.a119LoadsOverAll,
a119FreeOverAll:	a119FreeOverAll	??	this.a119FreeOverAll,
a119PaidOverAll:	a119PaidOverAll	??	this.a119PaidOverAll,
a120CustId:	a120CustId	??	this.a120CustId,
a120Name:	a120Name	??	this.a120Name,
a120Address:	a120Address	??	this.a120Address,
a120Phone:	a120Phone	??	this.a120Phone,
a120Date :	a120Date 	??	this.a120Date ,
a120Remarks:	a120Remarks	??	this.a120Remarks,
a120PromoLoadsCurr:	a120PromoLoadsCurr	??	this.a120PromoLoadsCurr,
a120FreeCurr:	a120FreeCurr	??	this.a120FreeCurr,
a120BalCurr:	a120BalCurr	??	this.a120BalCurr,
a120FreeDate:	a120FreeDate	??	this.a120FreeDate,
a120LoadsOverAll:	a120LoadsOverAll	??	this.a120LoadsOverAll,
a120FreeOverAll:	a120FreeOverAll	??	this.a120FreeOverAll,
a120PaidOverAll:	a120PaidOverAll	??	this.a120PaidOverAll,

    );
  }

  Map<String, dynamic> toJson() => {
        'docId':	docId	,
'a101CustId':	a101CustId	,
'a101Name':	a101Name	,
'a101Address':	a101Address	,
'a101Phone':	a101Phone	,
'a101Date ':	a101Date 	,
'a101Remarks':	a101Remarks	,
'a101PromoLoadsCurr':	a101PromoLoadsCurr	,
'a101FreeCurr':	a101FreeCurr	,
'a101BalCurr':	a101BalCurr	,
'a101FreeDate':	a101FreeDate	,
'a101LoadsOverAll':	a101LoadsOverAll	,
'a101FreeOverAll':	a101FreeOverAll	,
'a101PaidOverAll':	a101PaidOverAll	,
'a102CustId':	a102CustId	,
'a102Name':	a102Name	,
'a102Address':	a102Address	,
'a102Phone':	a102Phone	,
'a102Date ':	a102Date 	,
'a102Remarks':	a102Remarks	,
'a102PromoLoadsCurr':	a102PromoLoadsCurr	,
'a102FreeCurr':	a102FreeCurr	,
'a102BalCurr':	a102BalCurr	,
'a102FreeDate':	a102FreeDate	,
'a102LoadsOverAll':	a102LoadsOverAll	,
'a102FreeOverAll':	a102FreeOverAll	,
'a102PaidOverAll':	a102PaidOverAll	,
'a103CustId':	a103CustId	,
'a103Name':	a103Name	,
'a103Address':	a103Address	,
'a103Phone':	a103Phone	,
'a103Date ':	a103Date 	,
'a103Remarks':	a103Remarks	,
'a103PromoLoadsCurr':	a103PromoLoadsCurr	,
'a103FreeCurr':	a103FreeCurr	,
'a103BalCurr':	a103BalCurr	,
'a103FreeDate':	a103FreeDate	,
'a103LoadsOverAll':	a103LoadsOverAll	,
'a103FreeOverAll':	a103FreeOverAll	,
'a103PaidOverAll':	a103PaidOverAll	,
'a104CustId':	a104CustId	,
'a104Name':	a104Name	,
'a104Address':	a104Address	,
'a104Phone':	a104Phone	,
'a104Date ':	a104Date 	,
'a104Remarks':	a104Remarks	,
'a104PromoLoadsCurr':	a104PromoLoadsCurr	,
'a104FreeCurr':	a104FreeCurr	,
'a104BalCurr':	a104BalCurr	,
'a104FreeDate':	a104FreeDate	,
'a104LoadsOverAll':	a104LoadsOverAll	,
'a104FreeOverAll':	a104FreeOverAll	,
'a104PaidOverAll':	a104PaidOverAll	,
'a105CustId':	a105CustId	,
'a105Name':	a105Name	,
'a105Address':	a105Address	,
'a105Phone':	a105Phone	,
'a105Date ':	a105Date 	,
'a105Remarks':	a105Remarks	,
'a105PromoLoadsCurr':	a105PromoLoadsCurr	,
'a105FreeCurr':	a105FreeCurr	,
'a105BalCurr':	a105BalCurr	,
'a105FreeDate':	a105FreeDate	,
'a105LoadsOverAll':	a105LoadsOverAll	,
'a105FreeOverAll':	a105FreeOverAll	,
'a105PaidOverAll':	a105PaidOverAll	,
'a106CustId':	a106CustId	,
'a106Name':	a106Name	,
'a106Address':	a106Address	,
'a106Phone':	a106Phone	,
'a106Date ':	a106Date 	,
'a106Remarks':	a106Remarks	,
'a106PromoLoadsCurr':	a106PromoLoadsCurr	,
'a106FreeCurr':	a106FreeCurr	,
'a106BalCurr':	a106BalCurr	,
'a106FreeDate':	a106FreeDate	,
'a106LoadsOverAll':	a106LoadsOverAll	,
'a106FreeOverAll':	a106FreeOverAll	,
'a106PaidOverAll':	a106PaidOverAll	,
'a107CustId':	a107CustId	,
'a107Name':	a107Name	,
'a107Address':	a107Address	,
'a107Phone':	a107Phone	,
'a107Date ':	a107Date 	,
'a107Remarks':	a107Remarks	,
'a107PromoLoadsCurr':	a107PromoLoadsCurr	,
'a107FreeCurr':	a107FreeCurr	,
'a107BalCurr':	a107BalCurr	,
'a107FreeDate':	a107FreeDate	,
'a107LoadsOverAll':	a107LoadsOverAll	,
'a107FreeOverAll':	a107FreeOverAll	,
'a107PaidOverAll':	a107PaidOverAll	,
'a108CustId':	a108CustId	,
'a108Name':	a108Name	,
'a108Address':	a108Address	,
'a108Phone':	a108Phone	,
'a108Date ':	a108Date 	,
'a108Remarks':	a108Remarks	,
'a108PromoLoadsCurr':	a108PromoLoadsCurr	,
'a108FreeCurr':	a108FreeCurr	,
'a108BalCurr':	a108BalCurr	,
'a108FreeDate':	a108FreeDate	,
'a108LoadsOverAll':	a108LoadsOverAll	,
'a108FreeOverAll':	a108FreeOverAll	,
'a108PaidOverAll':	a108PaidOverAll	,
'a109CustId':	a109CustId	,
'a109Name':	a109Name	,
'a109Address':	a109Address	,
'a109Phone':	a109Phone	,
'a109Date ':	a109Date 	,
'a109Remarks':	a109Remarks	,
'a109PromoLoadsCurr':	a109PromoLoadsCurr	,
'a109FreeCurr':	a109FreeCurr	,
'a109BalCurr':	a109BalCurr	,
'a109FreeDate':	a109FreeDate	,
'a109LoadsOverAll':	a109LoadsOverAll	,
'a109FreeOverAll':	a109FreeOverAll	,
'a109PaidOverAll':	a109PaidOverAll	,
'a110CustId':	a110CustId	,
'a110Name':	a110Name	,
'a110Address':	a110Address	,
'a110Phone':	a110Phone	,
'a110Date ':	a110Date 	,
'a110Remarks':	a110Remarks	,
'a110PromoLoadsCurr':	a110PromoLoadsCurr	,
'a110FreeCurr':	a110FreeCurr	,
'a110BalCurr':	a110BalCurr	,
'a110FreeDate':	a110FreeDate	,
'a110LoadsOverAll':	a110LoadsOverAll	,
'a110FreeOverAll':	a110FreeOverAll	,
'a110PaidOverAll':	a110PaidOverAll	,
'a111CustId':	a111CustId	,
'a111Name':	a111Name	,
'a111Address':	a111Address	,
'a111Phone':	a111Phone	,
'a111Date ':	a111Date 	,
'a111Remarks':	a111Remarks	,
'a111PromoLoadsCurr':	a111PromoLoadsCurr	,
'a111FreeCurr':	a111FreeCurr	,
'a111BalCurr':	a111BalCurr	,
'a111FreeDate':	a111FreeDate	,
'a111LoadsOverAll':	a111LoadsOverAll	,
'a111FreeOverAll':	a111FreeOverAll	,
'a111PaidOverAll':	a111PaidOverAll	,
'a112CustId':	a112CustId	,
'a112Name':	a112Name	,
'a112Address':	a112Address	,
'a112Phone':	a112Phone	,
'a112Date ':	a112Date 	,
'a112Remarks':	a112Remarks	,
'a112PromoLoadsCurr':	a112PromoLoadsCurr	,
'a112FreeCurr':	a112FreeCurr	,
'a112BalCurr':	a112BalCurr	,
'a112FreeDate':	a112FreeDate	,
'a112LoadsOverAll':	a112LoadsOverAll	,
'a112FreeOverAll':	a112FreeOverAll	,
'a112PaidOverAll':	a112PaidOverAll	,
'a113CustId':	a113CustId	,
'a113Name':	a113Name	,
'a113Address':	a113Address	,
'a113Phone':	a113Phone	,
'a113Date ':	a113Date 	,
'a113Remarks':	a113Remarks	,
'a113PromoLoadsCurr':	a113PromoLoadsCurr	,
'a113FreeCurr':	a113FreeCurr	,
'a113BalCurr':	a113BalCurr	,
'a113FreeDate':	a113FreeDate	,
'a113LoadsOverAll':	a113LoadsOverAll	,
'a113FreeOverAll':	a113FreeOverAll	,
'a113PaidOverAll':	a113PaidOverAll	,
'a114CustId':	a114CustId	,
'a114Name':	a114Name	,
'a114Address':	a114Address	,
'a114Phone':	a114Phone	,
'a114Date ':	a114Date 	,
'a114Remarks':	a114Remarks	,
'a114PromoLoadsCurr':	a114PromoLoadsCurr	,
'a114FreeCurr':	a114FreeCurr	,
'a114BalCurr':	a114BalCurr	,
'a114FreeDate':	a114FreeDate	,
'a114LoadsOverAll':	a114LoadsOverAll	,
'a114FreeOverAll':	a114FreeOverAll	,
'a114PaidOverAll':	a114PaidOverAll	,
'a115CustId':	a115CustId	,
'a115Name':	a115Name	,
'a115Address':	a115Address	,
'a115Phone':	a115Phone	,
'a115Date ':	a115Date 	,
'a115Remarks':	a115Remarks	,
'a115PromoLoadsCurr':	a115PromoLoadsCurr	,
'a115FreeCurr':	a115FreeCurr	,
'a115BalCurr':	a115BalCurr	,
'a115FreeDate':	a115FreeDate	,
'a115LoadsOverAll':	a115LoadsOverAll	,
'a115FreeOverAll':	a115FreeOverAll	,
'a115PaidOverAll':	a115PaidOverAll	,
'a116CustId':	a116CustId	,
'a116Name':	a116Name	,
'a116Address':	a116Address	,
'a116Phone':	a116Phone	,
'a116Date ':	a116Date 	,
'a116Remarks':	a116Remarks	,
'a116PromoLoadsCurr':	a116PromoLoadsCurr	,
'a116FreeCurr':	a116FreeCurr	,
'a116BalCurr':	a116BalCurr	,
'a116FreeDate':	a116FreeDate	,
'a116LoadsOverAll':	a116LoadsOverAll	,
'a116FreeOverAll':	a116FreeOverAll	,
'a116PaidOverAll':	a116PaidOverAll	,
'a117CustId':	a117CustId	,
'a117Name':	a117Name	,
'a117Address':	a117Address	,
'a117Phone':	a117Phone	,
'a117Date ':	a117Date 	,
'a117Remarks':	a117Remarks	,
'a117PromoLoadsCurr':	a117PromoLoadsCurr	,
'a117FreeCurr':	a117FreeCurr	,
'a117BalCurr':	a117BalCurr	,
'a117FreeDate':	a117FreeDate	,
'a117LoadsOverAll':	a117LoadsOverAll	,
'a117FreeOverAll':	a117FreeOverAll	,
'a117PaidOverAll':	a117PaidOverAll	,
'a118CustId':	a118CustId	,
'a118Name':	a118Name	,
'a118Address':	a118Address	,
'a118Phone':	a118Phone	,
'a118Date ':	a118Date 	,
'a118Remarks':	a118Remarks	,
'a118PromoLoadsCurr':	a118PromoLoadsCurr	,
'a118FreeCurr':	a118FreeCurr	,
'a118BalCurr':	a118BalCurr	,
'a118FreeDate':	a118FreeDate	,
'a118LoadsOverAll':	a118LoadsOverAll	,
'a118FreeOverAll':	a118FreeOverAll	,
'a118PaidOverAll':	a118PaidOverAll	,
'a119CustId':	a119CustId	,
'a119Name':	a119Name	,
'a119Address':	a119Address	,
'a119Phone':	a119Phone	,
'a119Date ':	a119Date 	,
'a119Remarks':	a119Remarks	,
'a119PromoLoadsCurr':	a119PromoLoadsCurr	,
'a119FreeCurr':	a119FreeCurr	,
'a119BalCurr':	a119BalCurr	,
'a119FreeDate':	a119FreeDate	,
'a119LoadsOverAll':	a119LoadsOverAll	,
'a119FreeOverAll':	a119FreeOverAll	,
'a119PaidOverAll':	a119PaidOverAll	,
'a120CustId':	a120CustId	,
'a120Name':	a120Name	,
'a120Address':	a120Address	,
'a120Phone':	a120Phone	,
'a120Date ':	a120Date 	,
'a120Remarks':	a120Remarks	,
'a120PromoLoadsCurr':	a120PromoLoadsCurr	,
'a120FreeCurr':	a120FreeCurr	,
'a120BalCurr':	a120BalCurr	,
'a120FreeDate':	a120FreeDate	,
'a120LoadsOverAll':	a120LoadsOverAll	,
'a120FreeOverAll':	a120FreeOverAll	,
'a120PaidOverAll':	a120PaidOverAll	,
      };

}
