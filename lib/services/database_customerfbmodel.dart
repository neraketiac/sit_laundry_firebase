import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/customerfirebasemodel.dart';

const String _customerFbmRef = "CustomerFBM";
const Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

class DatabaseCustomerFBModel {
  final _firestore = FirebaseFirestore.instance;

late final CollectionReference _customerFBMColRef;

  DatabaseCustomerFBModel() {
    _customerFBMColRef = _firestore
        .collection(_customerFbmRef)
        .withConverter<CustomerFirebaseModel>(
            fromFirestore: (snapshots, _) => CustomerFirebaseModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (cFBM, _) => cFBM.toJson());
  }

  Stream<QuerySnapshot> getCustomerFBM() {
    return _customerFBMColRef.snapshots();
  }

  void addCustomerFBM(CustomerFirebaseModel cFBM) async {

    await _customerFBMColRef
        .add(cFBM)
        .then((value) => {
              print("Insert Done.${cFBM.docId}"),
              })
        .catchError(
          (error) => print("Failed : $error ${cFBM.docId}"),
        );
  }

  void updateDocId(CustomerFirebaseModel cFBM) async {
    _customerFBMColRef
        .doc(cFBM.docId)
        .update(cFBM.toJson())
        .then((value) => {
              print("Update Done updateDocId"),
            })
        .catchError(
          (error) => print("Update Failed : $error"),
        );
  }

  void deleteCustomerFBMDocId(String docId) {
    deleteCustomerFBM(docId);
  }

  void deleteCustomerFBM(String docId) async {
    _customerFBMColRef
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
