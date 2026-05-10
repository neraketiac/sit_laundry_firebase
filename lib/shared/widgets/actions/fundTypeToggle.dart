import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/features/payments/repository/gcash_repository.dart';

Widget fundTypeToggle(VoidCallback dialogSetState, List<int> listIntToSelect,
    GCashRepository gRepo,
    {bool showProcedureLabel = true}) {
  String getFundLabel(int index) {
    const labels = [
      "Cash-in",
      "Load",
      "Cash-Out",
    ];
    return labels[index];
  }

  List<List<String>> getDescriptionStepsGrouped(int fundCode) {
    if (fundCode == menuOthUniqIdCashIn || fundCode == menuOthUniqIdLoad) {
      return [
        ["Staff", "Ket", "Staff/Ket"],
        ["Ticket + Payment", "Attach SS", "Complete"]
      ];
    } else if (fundCode == menuOthUniqIdCashOut) {
      return [
        ["Staff", "Ket", "Staff/Ket"],
        ["Ticket + SS", "Check SS", "Bigay Cash"]
      ];
    }
    return [];
  }

  List<List<Color>> getDescriptionColorsGrouped(int fundCode) {
    final isDarkMode =
        true; // You can detect this from Theme.of(context).brightness

    final amberColor = isDarkMode ? Colors.amber[300]! : Colors.amber;
    final whiteColor = isDarkMode ? Colors.grey[200]! : Colors.white;
    final greenColor = isDarkMode ? Colors.green[300]! : Colors.green;

    if (fundCode == menuOthUniqIdCashIn || fundCode == menuOthUniqIdLoad) {
      return [
        [amberColor, whiteColor, greenColor],
        [amberColor, whiteColor, greenColor]
      ];
    } else if (fundCode == menuOthUniqIdCashOut) {
      return [
        [amberColor, whiteColor, greenColor],
        [amberColor, whiteColor, greenColor]
      ];
    }
    return [];
  }

  String getFundTypeLabel(int fundCode) {
    if (fundCode == menuOthUniqIdCashIn || fundCode == menuOthUniqIdLoad) {
      return "Cash In / Load Procedure";
    } else if (fundCode == menuOthUniqIdCashOut) {
      return "Cash Out Procedure";
    }
    return "";
  }

  return Visibility(
    visible: true,
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔹 TITLE
          Text(
            "Fund Type",
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 14),

          /// 🔹 SEGMENTED CONTROL
          Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.black.withValues(alpha: 0.25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: List.generate(
                listIntToSelect.length,
                (index) {
                  final fundCode = listIntToSelect[index];
                  final isSelected = gRepo.selectedFundCode == fundCode;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        gRepo.selectedFundCode = fundCode;

                        dialogSetState();
                      },

                      /// 👇 DOUBLE TAP LOGIC CLEANLY HERE
                      onDoubleTap: () {
                        if (fundCode == menuOthLaundryPayment) {
                          customerAmountVar.text =
                              (int.tryParse(customerAmountVar.text) ?? 0 + 155)
                                  .toString();
                        }

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
                          getFundLabel(index),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 🔹 DESCRIPTION - ROW 1: FUND TYPE LABEL
          if (showProcedureLabel)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  getFundTypeLabel(gRepo.selectedFundCode),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),

          if (showProcedureLabel) const SizedBox(height: 6),
          if (!showProcedureLabel) const SizedBox(height: 12),

          /// 🔹 DESCRIPTION - ROWS 2 & 3: ALIGNED COLUMNS
          if (showProcedureLabel)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    getDescriptionStepsGrouped(gRepo.selectedFundCode)[0]
                        .length,
                    (columnIndex) {
                      final steps1 =
                          getDescriptionStepsGrouped(gRepo.selectedFundCode)[0];
                      final steps2 =
                          getDescriptionStepsGrouped(gRepo.selectedFundCode)[1];
                      final colors1 = getDescriptionColorsGrouped(
                          gRepo.selectedFundCode)[0];
                      final colors2 = getDescriptionColorsGrouped(
                          gRepo.selectedFundCode)[1];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Row 2 content
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  steps1[columnIndex],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colors1[columnIndex],
                                  ),
                                ),
                                if (columnIndex < steps1.length - 1)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Text(
                                      ">",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Row 3 content
                            if (columnIndex < steps2.length)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    steps2[columnIndex],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colors2[columnIndex],
                                    ),
                                  ),
                                  if (columnIndex < steps2.length - 1)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(
                                        ">",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
