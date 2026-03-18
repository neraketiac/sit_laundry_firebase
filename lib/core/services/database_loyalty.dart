import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/loyalty/models/loyaltymodel.dart';
import 'package:laundry_firebase/core/global/variables.dart';

const String LOYALTY_REF = "loyalty";
const Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

class DatabaseLoyalty {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _customerRef;

  DatabaseLoyalty() {
    _customerRef =
        _firestore.collection(LOYALTY_REF).withConverter<LoyaltyModel>(
            fromFirestore: (snapshots, _) => LoyaltyModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (loyaltyModel, _) => loyaltyModel.toJson());
  }

  Stream<QuerySnapshot> getCustomers() {
    return _customerRef.snapshots();
  }

  void addCustomer(LoyaltyModel loyaltyModel) async {
    _customerRef
        .add(loyaltyModel)
        .then((value) => {
              print("Insert Done.${loyaltyModel.name}"),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError(
          (error) => print("Failed : $error ${loyaltyModel.name}"),
        );
  }

  void addCustomerWithId(LoyaltyModel loyaltyModel, String loyaltyId) async {
    _customerRef
        .doc(loyaltyId)
        .set(loyaltyModel)
        .then((value) => {
              print("Insert Done.${loyaltyModel.name}"),
            })
        .catchError(
          (error) => print("Failed : $error ${loyaltyModel.name}"),
        );
  }

  void updateCustomer(String customerId, LoyaltyModel loyaltyModel) {
    _customerRef.doc(customerId).update(loyaltyModel.toJson());
  }

  /// Add count
  Future<void> addCountByCardNumber(int cardNumber, int i) async {
    try {
      final snapshot = await _customerRef
          .where('cardNumber', isEqualTo: cardNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print("Customer not found for cardNumber: $cardNumber");
        return;
      }

      final docId = snapshot.docs.first.id;

      await _customerRef.doc(docId).update({
        'Count': FieldValue.increment(i),
      });

      autocompleteSelected.loyaltyCount += i;

      print("Count updated +$i for cardNumber: $cardNumber");
    } catch (e) {
      print("Failed to update count: $e");
    }
  }

  /// Set count to specific value
  Future<void> setCountByCardNumber(int cardNumber, int newCount) async {
    try {
      final snapshot = await _customerRef
          .where('cardNumber', isEqualTo: cardNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print("Customer not found for cardNumber: $cardNumber");
        return;
      }

      final docId = snapshot.docs.first.id;

      await _customerRef.doc(docId).update({
        'Count': newCount,
      });

      print("Count set to $newCount for cardNumber: $cardNumber");
    } catch (e) {
      print("Failed to set count: $e");
    }
  }
}
