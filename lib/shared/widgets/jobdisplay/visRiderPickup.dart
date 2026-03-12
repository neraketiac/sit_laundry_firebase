import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';

Widget visRiderPickup(
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
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 Label
        Text(
          jobRepo.selectedProcessStep == 'done'
              ? "     Final Status"
              : "     Initial Status",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white.withOpacity(0.75),
          ),
        ),

        const SizedBox(height: 2),

        /// 🔥 Custom Segmented Control
        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(0.15),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: List.generate(
              listRiderPickup.length,
              (index) {
                final isSelected = jobRepo.repoVarSelectedIntRiderPickup ==
                    listRiderPickup[index];

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      jobRepo.repoVarSelectedIntRiderPickup =
                          listRiderPickup[index];

                      dialogSetState();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.purpleAccent,
                                ],
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        index == 0
                            ? (jobRepo.selectedProcessStep == 'done'
                                ? 'Customer Pickup'
                                : "For Sorting")
                            : (jobRepo.selectedProcessStep == 'done'
                                ? 'Rider Delivery'
                                : "Rider Pickup"),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        /// 🔽 Dynamic Checkbox
        if (jobRepo.selectedProcessStep == 'done') ...[
          const SizedBox(height: 6),
          if (jobRepo.repoVarSelectedIntRiderPickup == listRiderPickup[0])
            Row(
              children: [
                Checkbox(
                  value: jobRepo.selectedIsCustomerPickedUp ?? false,
                  onChanged: (value) {
                    jobRepo.selectedIsCustomerPickedUp = value ?? false;

                    dialogSetState();
                  },
                ),
                const Text(
                  "Nakuha na ni customer",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          if (jobRepo.repoVarSelectedIntRiderPickup == listRiderPickup[1])
            Row(
              children: [
                Checkbox(
                  value: jobRepo.selectedIsDeliveredToCustomer ?? false,
                  onChanged: (value) {
                    jobRepo.selectedIsDeliveredToCustomer = value ?? false;

                    dialogSetState();
                  },
                ),
                const Text(
                  "Nadeliver na kay customer",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
        ]
      ],
    ),
  );
}
