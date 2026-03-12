import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/customers/models/customermodel.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/customers/repository/customer_repository.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';

class AutoCompleteCustomer extends StatefulWidget {
  final JobModelRepository jobRepo;
  final VoidCallback dialogSetState;

  const AutoCompleteCustomer({
    required this.jobRepo,
    required this.dialogSetState,
    super.key,
  });

  @override
  State<AutoCompleteCustomer> createState() => _AutoCompleteCustomerState();
}

class _AutoCompleteCustomerState extends State<AutoCompleteCustomer> {
  String _currentQuery = "";

  static String _displayString(CustomerModel option) =>
      "${option.name} • ${option.address} • ${option.customerId}";

  @override
  Widget build(BuildContext context) {
    final customers = CustomerRepository.instance.customers;

    return Autocomplete<CustomerModel>(
      displayStringForOption: _displayString,

      /// INPUT FIELD
      fieldViewBuilder: _buildField,

      /// FILTER OPTIONS
      optionsBuilder: (value) {
        _currentQuery = value.text;

        if (value.text.trim().isEmpty) {
          usePromoFree = false;

          autocompleteSelected = CustomerModel(
            customerId: 0,
            name: '',
            address: '',
            contact: '',
            remarks: '',
            loyaltyCount: 0,
          );

          if (mounted) {
            widget.dialogSetState();
          }

          return const Iterable<CustomerModel>.empty();
        }

        final query = value.text.toLowerCase();

        return customers.where((customer) {
          final searchable =
              "${customer.name} ${customer.address} ${customer.customerId}"
                  .toLowerCase();

          return searchable.contains(query);
        });
      },

      /// DROPDOWN VIEW
      optionsViewBuilder: _buildOptionsDropdown,

      /// SELECTION
      onSelected: _onCustomerSelected,
    );
  }

  /// INPUT FIELD
  Widget _buildField(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final isFocused = focusNode.hasFocus;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.25),
            border: Border.all(
              color:
                  isFocused ? Colors.cyanAccent : Colors.white.withOpacity(0.2),
              width: isFocused ? 2 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.7),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              icon: Icon(Icons.search, color: Colors.cyanAccent),
              hintText: "Search customer...",
              hintStyle: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
            ),
            onFieldSubmitted: (_) => onFieldSubmitted(),
          ),
        );
      },
    );
  }

  /// DROPDOWN LIST
  Widget _buildOptionsDropdown(
    BuildContext context,
    AutocompleteOnSelected<CustomerModel> onSelected,
    Iterable<CustomerModel> options,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 250),
        tween: Tween(begin: 0, end: 1),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.95 + (value * 0.05),
              alignment: Alignment.topCenter,
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 260),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.3),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return _buildOptionTile(option, onSelected);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    CustomerModel option,
    AutocompleteOnSelected<CustomerModel> onSelected,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onSelected(option),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: _highlightMatch(
          _displayString(option),
          _currentQuery,
        ),
      ),
    );
  }

  /// HIGHLIGHT MATCH
  Widget _highlightMatch(String text, String query) {
    if (query.isEmpty) {
      return const Text(
        "",
        style: TextStyle(color: Colors.white),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final start = lowerText.indexOf(lowerQuery);

    if (start == -1) {
      return Text(text, style: const TextStyle(color: Colors.white));
    }

    final end = start + query.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, start),
            style: const TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: text.substring(end),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// CUSTOMER SELECTED
  void _onCustomerSelected(CustomerModel selected) {
    autocompleteSelected = selected;

    if (mounted) {
      widget.dialogSetState();
    }

    SuppliesHistRepository.instance.setCustomerName(selected.name);

    debugPrint(
        'selected.name=${selected.name} selected.customerId=${selected.customerId}');

    widget.jobRepo.selectedCustomerNameVar.text = selected.name;
    widget.jobRepo.selectedCustomerId = selected.customerId;
    widget.jobRepo.address = selected.address;

    if (widget.jobRepo.processStep == '') {
      removeOtherItem(widget.jobRepo, promoFree);
    }

    bCustomerName = true;
  }
}
