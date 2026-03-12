import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';

Widget visOnGoingStatus(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  String formatStepLabel(String step) {
    switch (step) {
      case "waiting":
        return "Waiting";
      case "washing":
        return "Washing";
      case "drying":
        return "Drying";
      case "folding":
        return "Folding";
      default:
        return step;
    }
  }

  return Visibility(
    visible: true,
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          /// 🔹 TITLE
          Text(
            "On-Going Status",
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 16),

          /// 🔹 STEP SELECTOR
          Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.black.withOpacity(0.25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: List.generate(
                listOnGoingStatus.length,
                (index) {
                  final step = listOnGoingStatus[index];
                  final isSelected = jobRepo.selectedProcessStep == step;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        jobRepo.selectedProcessStep = step;

                        dialogSetState();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                          formatStepLabel(step),
                          style: TextStyle(
                            fontSize: 12,
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
        ],
      ),
    ),
  );
}
