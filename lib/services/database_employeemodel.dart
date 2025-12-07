import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/customerfirebasemodel.dart';
import 'package:laundry_firebase/models/employeemodel.dart';

const String _employeeModelRef = "CustomerFBM";
const Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

class DatabaseEmployeeModel {
  final _firestore = FirebaseFirestore.instance;

late final CollectionReference _employeeMColRef;

  DatabaseEmployeeModel(String sEmployeeId) {
    _employeeMColRef = _firestore
        //.collection(_employeeModelRef)
        .collection(sEmployeeId)
        .withConverter<EmployeeModel>(
            fromFirestore: (snapshots, _) => EmployeeModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (eM, _) => eM.toJson());
  }

  Stream<QuerySnapshot> getEmployeeModel() {
    return _employeeMColRef.snapshots();
  }

  void addEmployeeModel(EmployeeModel eM) async {

    await _employeeMColRef
        .add(eM)
        .then((value) => {
              print("Insert Done.${eM.docId}"),
              })
        .catchError(
          (error) => print("Failed : $error ${eM.docId}"),
        );
  }

  void updateDocId(EmployeeModel eM) async {
    _employeeMColRef
        .doc(eM.docId)
        .update(eM.toJson())
        .then((value) => {
              print("Update Done updateDocId"),
            })
        .catchError(
          (error) => print("Update Failed : $error"),
        );
  }

  void deleteEmployeeMDocId(String docId) {
    deleteEmployeeM(docId);
  }

  void deleteEmployeeM(String docId) async {
    _employeeMColRef
        .doc(docId)
        .delete()
        .then((value) => {
              print("Delete Customer FBM."),
            })
        .catchError(
          (error) => print("Delete Failed : $error"),
        );
  }
}
