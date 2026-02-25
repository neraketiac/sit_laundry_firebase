import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/oldmodels/customermodel.dart';
import 'package:laundry_firebase/variables/newvariables/customer_repository.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

class AutoCompleteCustomer extends StatelessWidget {
  final JobModelRepository jobRepo;

  const AutoCompleteCustomer({
    required this.jobRepo,
    super.key,
  });

  static String _displayStringForOption(CustomerModel option) =>
      "${option.name} - ${option.address} - ${option.customerId}";

  @override
  Widget build(BuildContext context) {
    final customers = CustomerRepository.instance.customers;

    return Autocomplete<CustomerModel>(
      displayStringForOption: _displayStringForOption,

      /// 🔹 INPUT FIELD
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(0.25),
            border: Border.all(
              color: focusNode.hasFocus
                  ? Colors.blueAccent
                  : Colors.white.withOpacity(0.2),
              width: focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              hintText: "Search customer...",
              hintStyle: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
              border: InputBorder.none,
            ),
            onFieldSubmitted: (value) => onFieldSubmitted(),
          ),
        );
      },

      /// 🔹 FILTER OPTIONS
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<CustomerModel>.empty();
        }

        return customers.where((CustomerModel option) {
          return option
              .toStringCustomerModel()
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },

      /// 🔹 DROPDOWN DESIGN
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.85),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                maxHeight: 250,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);

                  return GestureDetector(
                    onTap: () => onSelected(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _displayStringForOption(option),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },

      /// 🔹 WHEN SELECTED
      onSelected: (CustomerModel selectedModel) {
        autocompleteSelected = selectedModel;

        SuppliesHistRepository.instance.setCustomerName(selectedModel.name);

        jobRepo.customerName = selectedModel.name;
        jobRepo.customerId = selectedModel.customerId;

        bCustomerName = true;

        debugPrint(
          'Selected ${_displayStringForOption(selectedModel)}',
        );
      },
    );
  }
}
