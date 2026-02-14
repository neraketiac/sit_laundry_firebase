import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:laundry_firebase/models/employeemodel.dart';
import 'package:laundry_firebase/services/database_employee_hist.dart';
import 'package:laundry_firebase/variables/variables.dart';

const String EMPLOYEE_CURR_REF = "EmployeeCurr";

class DatabaseEmployeeCurrent {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _employeeCurrRef;

  DatabaseEmployeeCurrent() {
    _employeeCurrRef =
        _firestore.collection(EMPLOYEE_CURR_REF).withConverter<EmployeeModel>(
            fromFirestore: (snapshots, _) => EmployeeModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (eM, _) => eM.toJson());
  }

  Stream<QuerySnapshot> get() {
    if (empIdGlobal == 'Ket' || empIdGlobal == 'DonF') {
      return _employeeCurrRef.orderBy('LogDate', descending: true).snapshots();
    } else {
      return _employeeCurrRef
          .where('EmpId', isEqualTo: empNameToId[empIdGlobal])
          .orderBy('LogDate', descending: true)
          .snapshots();
    }
  }

  Future<bool> addEmployeeCurr(EmployeeModel eM) async {
    eM = await _computeCurrentStocks(eM);

    DatabaseEmployeeHist databaseEmployeeHist = DatabaseEmployeeHist();
    await databaseEmployeeHist.addEmployeeHist(eM);

    //to be used in Current
    eM.currentStocks = eM.currentStocks + eM.currentCounter;

    bool bSuccess = false;
    print("Doc id before=${eM.docId}");

    if (eM.docId.isNotEmpty) {
      print("Is not empty");
      await _updateDocId(eM);
      bSuccess = true;
    } else {
      print("Is empty");
      await _employeeCurrRef
          .add(eM)
          .then((value) => {
                eM.docId = value.id,
                print("DocID${value.id}"),
                _updateDocId(eM),
                print("Supplies Current Save done...."),
                bSuccess = true,
              })
          .catchError((error) => {
                print("Failed : $error ${eM.empId}"),
                bSuccess = false,
              });
    }

    return bSuccess;
  }

  Future<bool> addEmployeeHist(EmployeeModel eM) async {
    bool bSuccess = false;
    await _employeeCurrRef
        .add(eM)
        .then((value) => {
              print("Employee History Save done."),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed : $error ${eM.empId}"),
              bSuccess = false,
            });
    return bSuccess;
  }

  Future<EmployeeModel> _computeCurrentStocks(EmployeeModel eM) async {
    debugPrint("Compute Current Stocks for ${eM.empId}");
    var collectionRef = FirebaseFirestore.instance
        .collection('EmployeeCurr')
        .where('EmpId', isEqualTo: eM.empId);
    var querySnapshots = await collectionRef.get();
    for (var doc in querySnapshots.docs) {
      eM.currentStocks = doc['CurrentStocks'];
      eM.countId = doc['CountId'] + 1;
      eM.docId = doc['DocId'];
      break;
    }

    return eM;
  }

  Future<void> _updateDocId(EmployeeModel eM) async {
    await _employeeCurrRef
        .doc(eM.docId)
        .update(eM.toJson())
        .then((value) => {
              print("Update Done updateDocId database_employee_current"),
            })
        .catchError(
          (error) => print("Update Failed : $error"),
        );
  }
}
