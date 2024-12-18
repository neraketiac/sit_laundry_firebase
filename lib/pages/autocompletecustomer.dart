import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/customermodel.dart';
import 'package:laundry_firebase/models/loyaltymodel.dart';
import 'package:laundry_firebase/services/database_loyalty.dart';
import 'package:laundry_firebase/variables/variables.dart';

class AutoCompleteCustomer extends StatelessWidget {
  AutoCompleteCustomer({super.key});
  //late List<CustomerModel> _customerOptions;
  late TextEditingValue inputName;
  late TextFormField inputNameTFF;
  TextEditingController customerController = TextEditingController();
  //  = <CustomerModel>[
  //   CustomerModel(
  //       customerId: 1,
  //       name: "Jaydie",
  //       address: "TMM",
  //       contact: "TMM",
  //       remarks: "TMM",
  //       loyaltyCount: "TMM"),
  //   CustomerModel(
  //       customerId: 2,
  //       name: "Jojo",
  //       address: "TMM",
  //       contact: "TMM",
  //       remarks: "TMM",
  //       loyaltyCount: "TMM"),
  // ];

  static String _displayStringForOption(CustomerModel option) =>
      "${option.name} - ${option.address} - ${option.customerId}";

  @override
  Widget build(BuildContext context) {
    //_customerOptions = [];
    fetchUsers();
    return Autocomplete<CustomerModel>(
      displayStringForOption: _displayStringForOption,
      // optionsBuilder: (TextEditingValue textEditingValue) {
      //   if (textEditingValue.text == '') {
      optionsBuilder: (inputNameTFF) {
        if (inputNameTFF.text == '') {
          return const Iterable<CustomerModel>.empty();
        }
        return customerOptionsFromVariable.where((CustomerModel option) {
          return option
              .toStringCustomerModel()
              .toLowerCase()
              .contains(inputNameTFF.text.toLowerCase());
        });
      },
      onSelected: (CustomerModel selectedModel) {
        autocompleteSelected = selectedModel;
        debugPrint(
            'You just selected ${_displayStringForOption(selectedModel)}');
        debugPrint('Do something');
      },
    );
  }

  // Future<void> fetchUsers() {
  //   CollectionReference users =
  //       FirebaseFirestore.instance.collection('loyalty');
  //   return users.get().then((QuerySnapshot snapshot) {
  //     for (var doc in snapshot.docs) {
  //       print(doc.id + " " + doc['Name'] + " " + doc['Address']);
  //       _customerOptions.add(CustomerModel(
  //           customerId: int.parse(doc.id),
  //           name: doc['Name'],
  //           address: doc['Address'],
  //           contact: doc['Name'],
  //           remarks: doc['Name'],
  //           loyaltyCount: doc['Count']));
  //     }
  //   }).catchError((error) => print("Failed to fetch users: $error"));
  // }
}
