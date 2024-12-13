import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/services/navigator_key.dart';

const String COLLECTION_REF = "JobsOnQueue";
const String SUB_COLLECTION_REF = "OtherItems";
const Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

class DatabaseOtherItems {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _otherItemsRef;

  DatabaseOtherItems(String id) {
    _otherItemsRef = _firestore
        .collection(COLLECTION_REF)
        .doc(id)
        .collection(SUB_COLLECTION_REF)
        .withConverter<OtherItemModel>(
            fromFirestore: (snapshots, _) => OtherItemModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (otherItemsModel, _) => otherItemsModel.toJson());
  }

  Stream<QuerySnapshot> getOtherItems() {
    return _otherItemsRef.snapshots();
  }

  void addOtherItems(OtherItemModel otherItemModel) async {
    _otherItemsRef
        .add(otherItemModel)
        .then((value) => {
              //messageResult("Insert Done.${otherItemModel.itemName}"),
              print("Insert Done.${otherItemModel.itemName}"),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError(
          (error) => print("Failed : $error ${otherItemModel.itemName}"),
        );
    ;
  }
}
