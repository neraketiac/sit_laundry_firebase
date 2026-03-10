import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/newmodels/customermodel.dart';

class CustomerRepository {
  CustomerRepository._();
  static final CustomerRepository instance = CustomerRepository._();

  final List<CustomerModel> customers = [];
  bool _loaded = false;

  Future<void> loadOnce() async {
    if (_loaded) return;

    final snapshot =
        await FirebaseFirestore.instance.collection('loyalty').get();

    customers.addAll(
      snapshot.docs.map((doc) => CustomerModel(
            customerId: int.parse(doc.id),
            name: doc['Name'],
            address: doc['Address'],
            contact: doc['Name'],
            remarks: doc['Name'],
            loyaltyCount: doc['Count'],
          )),
    );

    _loaded = true;
  }
}
