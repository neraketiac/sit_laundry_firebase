import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/customermodel.dart';

const String CUSTOMER_REF = "customer";
const Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

class DatabaseCustomer {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _customerRef;

  DatabaseCustomer() {
    _customerRef =
        _firestore.collection(CUSTOMER_REF).withConverter<CustomerModel>(
            fromFirestore: (snapshots, _) => CustomerModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (customerModel, _) => customerModel.toJson());
  }

  Stream<QuerySnapshot> getCustomers() {
    return _customerRef.snapshots();
  }

  void addCustomer(CustomerModel customerModel) async {
    _customerRef
        .add(customerModel)
        .then((value) => {
              print("Insert Done.${customerModel.name}"),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError(
          (error) => print("Failed : ${error} ${customerModel.name}"),
        );
  }

  void updateCustomer(String customerId, CustomerModel customerModel) {
    _customerRef.doc(customerId).update(customerModel.toJson());
  }
}
