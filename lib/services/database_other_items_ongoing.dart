import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/services/navigator_key.dart';
import 'package:laundry_firebase/variables/variables.dart';

const String COLLECTION_REF = "JobsOnGoing";
const String SUB_COLLECTION_REF = "OtherItems";
const Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

class DatabaseOtherItemsOnGoing {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _otherItemsRef;

  DatabaseOtherItemsOnGoing(String id) {
    _otherItemsRef = _firestore
        .collection(COLLECTION_REF)
        .doc(id)
        .collection(SUB_COLLECTION_REF)
        .withConverter<OtherItemModel>(
            fromFirestore: (snapshots, _) => OtherItemModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (oIM, _) => oIM.toJson());
  }

  Stream<QuerySnapshot> getOtherItems() {
    return _otherItemsRef.snapshots();
  }

  void addOtherItems(OtherItemModel oIM) async {
    _otherItemsRef
        .add(oIM)
        .then((value) => {
              //messageResult("Insert Done.${otherItemModel.itemName}"),
              print("Insert Done.${oIM.itemName}${value.id}"),
              updateDocId(OtherItemModel(
                docId: value.id,
                itemId: oIM.itemId,
                itemGroup: oIM.itemGroup,
                itemName: oIM.itemName,
                itemPrice: oIM.itemPrice,
                stocksAlert: oIM.stocksAlert,
                stocksType: oIM.stocksType,
              )),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError(
          (error) => print("Insert Failed : $error ${oIM.itemName}"),
        );
  }

  void updateDocId(OtherItemModel oIM) async {
    _otherItemsRef
        .doc(oIM.docId)
        .update(oIM.toJson())
        .then((value) => {
              print("Update Done.${oIM.itemName}"),
            })
        .catchError(
          (error) => print("Update Failed : $error ${oIM.itemName}"),
        );
  }

  Future<void> deleteOtheritems(String docIdSub) async {
    await _otherItemsRef
        .doc(docIdSub)
        .delete()
        .then((value) => {
              print("Delete Done."),
            })
        .catchError(
          (error) => print("Delete Failed : $error"),
        );
  }

  bool checkIfDocExists(OtherItemModel oIM) {
    bool found = false;
    _otherItemsRef
        .doc(oIM.docId)
        .update(oIM.toJson())
        .then((value) => {
              print("Check done"),
              found = true,
            })
        .catchError(
          (error) => print("Update Failed"),
        );
    return found;
  }
}
