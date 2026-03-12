import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/autocompletecustomer.dart';

Widget visCustomerName(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  return Container(
    padding: const EdgeInsets.all(1),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.12),
          Colors.white.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: Colors.white.withOpacity(0.25),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 25,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// SECTION LABEL
        Text(
          "     Select Customer",
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.75),
          ),
        ),

        const SizedBox(height: 2),

        /// AUTOCOMPLETE FIELD
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withOpacity(0.15),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: AutoCompleteCustomer(
            jobRepo: jobRepo,
            dialogSetState: dialogSetState,
          ),
        ),

        const SizedBox(height: 2),

        /// LOYALTY + NEW ACCOUNT
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${autocompleteSelected.loyaltyCount ?? 0}/10 ',
              style: const TextStyle(color: Colors.white),
            ),
            if ((autocompleteSelected.loyaltyCount ?? 0) >= 10)
              const Icon(
                Icons.star,
                size: 40,
                color: Colors.amberAccent,
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blueAccent,
                      Colors.purpleAccent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    allCardsVar(context);
                  },
                  child: const Text(
                    "New Account",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
