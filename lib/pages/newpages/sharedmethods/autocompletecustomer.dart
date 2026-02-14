import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/oldmodels/customermodel.dart';
import 'package:laundry_firebase/variables/newvariables/customer_repository.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

class AutoCompleteCustomer extends StatelessWidget {
  late JobModelRepository jobRepo;
  AutoCompleteCustomer({required this.jobRepo, super.key});
  late TextEditingValue inputName;
  late TextFormField inputNameTFF;

  static String _displayStringForOption(CustomerModel option) =>
      "${option.name} - ${option.address} - ${option.customerId}";

  @override
  Widget build(BuildContext context) {
    final customer = CustomerRepository.instance.customers;

    return Autocomplete<CustomerModel>(
      displayStringForOption: _displayStringForOption,
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Enter Name',
            labelStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            hintText: 'Search Name',
            hintStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          onFieldSubmitted: (value) => onFieldSubmitted(),
        );
      },
      optionsBuilder: (inputNameTFF) {
        if (inputNameTFF.text == '') {
          return const Iterable<CustomerModel>.empty();
        }
        return customer.where((CustomerModel option) {
          return option
              .toStringCustomerModel()
              .toLowerCase()
              .contains(inputNameTFF.text.toLowerCase());
        });
      },
      onSelected: (CustomerModel selectedModel) {
        autocompleteSelected = selectedModel;
        SuppliesHistRepository.instance.setCustomerName(selectedModel.name);
        jobRepo.customerName = selectedModel.name;
        jobRepo.customerId = selectedModel.customerId;
        bCustomerName = true;
        debugPrint(
            'You just selected ${_displayStringForOption(selectedModel)}');
      },
    );
  }
}
