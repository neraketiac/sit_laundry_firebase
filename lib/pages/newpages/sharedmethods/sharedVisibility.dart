import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showPaidUnpaid.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedConstantsFinal.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/variables/newvariables/gcash_repository.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_ble.dart';
import 'package:laundry_firebase/variables/newvariables/variables_det.dart';
import 'package:laundry_firebase/variables/newvariables/variables_fab.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';
import 'package:laundry_firebase/variables/newvariables/variables_supplies.dart';

class PHPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all spaces
    String digits = newValue.text.replaceAll(' ', '');

    // Allow digits only
    digits = digits.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 11 digits
    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    String formatted = '';

    for (int i = 0; i < digits.length; i++) {
      formatted += digits[i];

      // Add spaces after 2, 4, and 7 digits
      if (i == 1 || i == 3 || i == 6) {
        if (i != digits.length - 1) {
          formatted += ' ';
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

Widget visCustomerName(
  BuildContext context,
  Function setState,
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
        /// 🔹 Section Label
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

        /// 🔹 Autocomplete Field wrapped in glass box
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
          ),
        ),

        const SizedBox(height: 2),

        /// 🔹 Gradient "New Account" Button
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
  );
}

Widget visCustomerNameNoAutoComplete(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
  bool bShort,
) {
  return Container(
    padding: const EdgeInsets.all(1),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
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
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 Label
        Text(
          "     Customer",
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),

        const SizedBox(height: 2),

        /// 🔹 Content Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withOpacity(0.15),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: Text(
            bShort
                ? '${jobRepo.processStep.isEmpty ? '' : '#${jobRepo.jobId} '}${jobRepo.customerNameVar.text}'
                : '${jobRepo.processStep.isEmpty ? '' : '#${jobRepo.jobId} '}${jobRepo.customerNameVar.text} '
                    '(${jobRepo.finalLoad})\n'
                    '${textBagDetails(jobRepo.getJobsModel()!)} '
                    '₱ ${jobRepo.finalPrice}.00',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: jobRepo.customerNameVar.text.isEmpty
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget visRiderPickup(
  BuildContext context,
  Function setState,
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
          "     Initial Status",
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
                final isSelected =
                    jobRepo.selectedRiderPickup == listRiderPickup[index];

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        jobRepo.selectedRiderPickup = listRiderPickup[index];
                      });
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
                        index == 0 ? "For Sorting" : "Rider Pickup",
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
      ],
    ),
  );
}

Widget visSelectPackage(
  BuildContext context,
  Function setState,
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
        /// 🔹 Label
        Text(
          "     Package Type",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white.withOpacity(0.75),
          ),
        ),

        const SizedBox(height: 2),

        /// 🔥 Segmented Control
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
              listPackage.length,
              (index) {
                final value = listPackage[index];
                final isSelected = jobRepo.selectedPackage == value;

                return Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      // 🔥 Confirmation logic
                      if (jobRepo.selectedPackagePrev == othersPackage &&
                          jobRepo.listSelectedItemModel.isNotEmpty) {
                        final confirm = await showCoolConfirmDialog(
                          context: context,
                          title: "Change Package?",
                          message: "Items in All Services will be removed.",
                          confirmText: "Change",
                        );

                        if (!confirm) return;

                        setState(() {
                          jobRepo.listSelectedItemModel.clear();
                          jobRepo.totalPriceOthers = 0;
                        });
                      }

                      setState(() {
                        jobRepo.selectedPackage = value;
                        jobRepo.selectedPackagePrev = value;

                        if (value == othersPackage) {
                          jobRepo.selectedItemModel = listOthItems[0];
                        }

                        resetPaymentStatus(jobRepo);
                      });
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
                            ? "Regular"
                            : index == 1
                                ? "Sayo Sabon"
                                : "All Services",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
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
  );
}

Visibility visAmountRegSSPerKg(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
  jobRepo.pricePerSet = prices[jobRepo.selectedPackage] ?? 155;
  jobRepo.maxPartial = maxPartialOptions[jobRepo.selectedPackage] ?? 3;
  // 🧠 UI rules

  final bool showPointOne =
      jobRepo.quantityKg >= 8 && (jobRepo.quantityKg % 8) < jobRepo.maxPartial;

  jobRepo.totalPriceRegSS = computeTotalPrice(jobRepo.quantityKg, jobRepo) +
      jobRepo.totalPriceShortCutRegSS;

  // ➕➖ handlers
  void incrementOne() {
    setState(() {
      jobRepo.quantityKg += 1;
      jobRepo.quantityKg = jobRepo.quantityKg.floorToDouble();
      resetPaymentStatus(jobRepo);
    });
  }

  void incrementPointOne() {
    setState(() {
      jobRepo.quantityKg =
          double.parse((jobRepo.quantityKg + 0.1).toStringAsFixed(1));
      resetPaymentStatus(jobRepo);
    });
  }

  void decrementOne() {
    setState(() {
      jobRepo.quantityKg -= 1;
      if (jobRepo.quantityKg < 1) jobRepo.quantityKg = 1;
      jobRepo.quantityKg = jobRepo.quantityKg.floorToDouble();
      resetPaymentStatus(jobRepo);
    });
  }

  return Visibility(
    visible:
        (jobRepo.selectedPackage == othersPackage ? false : jobRepo.isPerKg),
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
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
            color: Colors.black.withOpacity(0.35),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 💰 TOTAL PRICE
          Column(
            children: [
              Text(
                "TOTAL",
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatter.format(jobRepo.totalPriceRegSS),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 3,
                width: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          /// 📦 QUANTITY DISPLAY
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "${jobRepo.quantityKg.toStringAsFixed(
                    jobRepo.quantityKg % 1 == 0 ? 0 : 1,
                  )} kg",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      jobRepo.isPerKg = false;
                      resetPaymentStatus(jobRepo);
                    });
                  },
                  child: Text(
                    "Switch to Load",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          /// ➖➕ CONTROLS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 42),
              _glassActionButton(
                label: "−1",
                onTap: decrementOne,
                disabled: jobRepo.quantityKg <= 1,
              ),
              const SizedBox(width: 12),
              _glassActionButton(
                label: "+1",
                onTap: incrementOne,
              ),
              const SizedBox(width: 12),
              Visibility(
                visible: showPointOne,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: _glassActionButton(
                  label: "+0.1",
                  onTap: incrementPointOne,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _glassActionButton({
  required String label,
  required VoidCallback onTap,
  bool disabled = false,
}) {
  return GestureDetector(
    onTap: disabled ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: disabled
            ? null
            : const LinearGradient(
                colors: [
                  Colors.blueAccent,
                  Colors.purpleAccent,
                ],
              ),
        color: disabled ? Colors.grey.withOpacity(0.3) : null,
        boxShadow: disabled
            ? []
            : [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: disabled ? Colors.white54 : Colors.white,
        ),
      ),
    ),
  );
}

Visibility visAmountRegSSPerLoad(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
  const prices = {
    regularPackage: 155,
    sayoSabonPackage: 125,
    othersPackage: 0,
  };

  jobRepo.pricePerSet = prices[jobRepo.selectedPackage] ?? 155;

  jobRepo.totalPriceRegSS = (jobRepo.pricePerSet * jobRepo.quantityLoad) +
      jobRepo.totalPriceShortCutRegSS;

  void incrementOne() {
    setState(() {
      jobRepo.quantityLoad += 1;
      resetPaymentStatus(jobRepo);
    });
  }

  void decrementOne() {
    setState(() {
      jobRepo.quantityLoad -= 1;
      if (jobRepo.quantityLoad < 1) jobRepo.quantityLoad = 1;
      resetPaymentStatus(jobRepo);
    });
  }

  return Visibility(
    visible:
        (jobRepo.selectedPackage == othersPackage ? false : !jobRepo.isPerKg),
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28), // ← SAME AS KG
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
            color: Colors.black.withOpacity(0.35),
            blurRadius: 35, // ← SAME DEPTH AS KG
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 💰 TOTAL PRICE (IDENTICAL STYLE)
          Column(
            children: [
              Text(
                "TOTAL",
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatter.format(jobRepo.totalPriceRegSS),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 3,
                width: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          /// 📦 LOAD DISPLAY (MATCHED SIZE)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "${jobRepo.quantityLoad} load",
                  style: const TextStyle(
                    fontSize: 20, // ← SAME AS KG
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      jobRepo.isPerKg = true;
                      resetPaymentStatus(jobRepo);
                    });
                  },
                  child: Text(
                    "Switch to Kg",
                    style: TextStyle(
                      fontSize: 12, // ← SAME AS KG
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          /// ➖➕ CONTROLS (SAME BUTTON STYLE)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _glassActionButton(
                label: "−1",
                onTap: decrementOne,
                disabled: jobRepo.quantityLoad <= 1,
              ),
              const SizedBox(width: 12),
              _glassActionButton(
                label: "+1",
                onTap: incrementOne,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _glassMiniButton({
  required String label,
  required VoidCallback onTap,
  bool disabled = false,
}) {
  return GestureDetector(
    onTap: disabled ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: disabled
            ? null
            : const LinearGradient(
                colors: [
                  Colors.blueAccent,
                  Colors.purpleAccent,
                ],
              ),
        color: disabled ? Colors.grey.withOpacity(0.3) : null,
        boxShadow: disabled
            ? []
            : [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: disabled ? Colors.white54 : Colors.white,
          ),
        ),
      ),
    ),
  );
}

Widget visAmountOthersOnly(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
) {
  void addOtherItem(OtherItemModel item) {
    jobRepo.listSelectedItemModel.add(item);
    jobRepo.totalPriceOthers += item.itemPrice;
  }

  String getShortcutLabel(int value) {
    switch (value) {
      case menuOth155:
        return "155";
      case menuOth125:
        return "125";
      case menuOthXD:
        return "+Dry";
      case menuFabWKLDValAny8ml:
        return "+Fab";
      default:
        return value.toString();
    }
  }

  return Visibility(
    visible: (jobRepo.selectedPackage == othersPackage),
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
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
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 💰 TOTAL
          Column(
            children: [
              Text(
                "ADD-ONS TOTAL",
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatter.format(jobRepo.totalPriceOthers),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Container(
                height: 3,
                width: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pinkAccent, Colors.purpleAccent],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ⚡ SHORTCUT BUTTONS
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: listOthersDropDownShortCuts.map((shortcut) {
              return _glassShortcutButton(
                label: getShortcutLabel(shortcut),
                onTap: () {
                  setState(() {
                    jobRepo.selectedOthersShortCut = shortcut;

                    if (shortcut == menuOth155) {
                      addOtherItem(reg155ItemModel);
                    } else if (shortcut == menuOth125) {
                      addOtherItem(reg125ItemModel);
                    } else if (shortcut == menuOthXD) {
                      addOtherItem(xDItemModel);
                    } else if (shortcut == menuFabWKLDValAny8ml) {
                      addOtherItem(addFabAnyItemModel);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          /// 🧊 DROPDOWN + ADD BUTTON
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: DropdownButton<OtherItemModel>(
                    value: jobRepo.selectedItemModel,
                    isExpanded: true,
                    dropdownColor: Colors.black87,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    items: (jobRepo.selectedOthers == menuOthDVal
                            ? listOthItems
                            : jobRepo.selectedOthers == menuDetDVal
                                ? listDetItems
                                : jobRepo.selectedOthers == menuFabDVal
                                    ? listFabItems
                                    : listBleItems)
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              "${e.itemName}  ₱${e.itemPrice}",
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        jobRepo.selectedItemModel = val!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _glassAddButton(
                onTap: () {
                  setState(() {
                    addOtherItem(jobRepo.selectedItemModel);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// 🧾 SELECTED ITEMS LIST
          Column(
            children: jobRepo.listSelectedItemModel.map((e) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          jobRepo.totalPriceOthers -= e.itemPrice;
                          jobRepo.listSelectedItemModel.remove(e);
                        });
                      },
                      child: const Icon(
                        Icons.remove_circle,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.itemName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      "₱${e.itemPrice}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}

Widget _glassShortcutButton({
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Colors.pinkAccent, Colors.purpleAccent],
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}

Widget _glassAddButton({required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
        ),
      ),
      child: const Text(
        "Add",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}

Visibility visPaidUnPaid(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
  // final List<int> listPaidUnpaid = [
  //   paidCash,
  //   paidGCash,
  // ];

  String returnPaymentStatusDuringToggle() {
    void resetPartialAmount() {
      jobRepo.cashAmountVar.text = '';
      jobRepo.gCashAmountVar.text = '';
    }

    void setPartialAmount(TextEditingController controller) {
      if (jobRepo.finalPrice == 0) {
        if (jobRepo.selectedPackage == othersPackage) {
          controller.text = jobRepo.totalPriceOthers.toString();
        } else {
          controller.text = jobRepo.totalPriceRegSS.toString();
        }
      } else {
        controller.text = jobRepo.finalPrice.toString();
      }
      // if (jobRepo.selectedPackage == othersPackage) {
      //   if ((int.tryParse(controller.text) ?? 0) < jobRepo.totalPriceOthers) {
      //     controller.text = jobRepo.totalPriceOthers.toString();
      //   }
      // } else {
      //   if ((int.tryParse(controller.text) ?? 0) < jobRepo.totalPriceRegSS) {
      //     controller.text = jobRepo.totalPriceRegSS.toString();
      //   }
      // }
    }

    if (jobRepo.paidCash && jobRepo.paidGCash) {
      resetPartialAmount();
      return 'Split payment';
    } else if (jobRepo.paidCash) {
      setPartialAmount(jobRepo.cashAmountVar);
      return 'Paid Cash';
    } else if (jobRepo.paidGCash) {
      setPartialAmount(jobRepo.gCashAmountVar);
      return 'Paid GCash';
    }
    resetPartialAmount();
    return 'Unpaid';
  }

  void validatePaymentWhenVarChange() {
    final int valueCash = int.tryParse(jobRepo.cashAmountVar.text) ?? 0;
    final int valueGCash = int.tryParse(jobRepo.gCashAmountVar.text) ?? 0;
    final int tempFinalPrice = (jobRepo.selectedPackage == othersPackage
        ? jobRepo.totalPriceOthers
        : jobRepo.totalPriceRegSS);

    // debugPrint(
    //     'valueCash=$valueCash valueGCash=$valueGCash finaPrice=$tempFinalPrice');

    int totalPaid = (jobRepo.paidCash ? valueCash : 0) +
        (jobRepo.paidGCash ? valueGCash : 0);

    bool isFullyPaid = totalPaid >= tempFinalPrice;

    actualPaymentStatus = !isFullyPaid
        ? 'Unpaid (Kulang)'
        : (jobRepo.paidCash && jobRepo.paidGCash)
            ? 'Paid (Split)'
            : 'Paid';

    jobRepo.unpaid = !isFullyPaid;
  }

  actualPaymentStatus = returnPaymentStatusDuringToggle();

  return Visibility(
    visible: true,
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
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
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 💰 STATUS BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: jobRepo.unpaid
                    ? [Colors.redAccent, Colors.orangeAccent]
                    : [Colors.greenAccent, Colors.tealAccent],
              ),
            ),
            child: Text(
              actualPaymentStatus,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 💳 PAYMENT METHOD TOGGLES
          Row(
            children: [
              Expanded(
                child: _glassPaymentToggle(
                  label: "Cash",
                  selected: jobRepo.paidCash,
                  onTap: () {
                    setState(() {
                      jobRepo.paidCash = !jobRepo.paidCash;
                      actualPaymentStatus = returnPaymentStatusDuringToggle();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _glassPaymentToggle(
                  label: "GCash",
                  selected: jobRepo.paidGCash,
                  onTap: () {
                    setState(() {
                      jobRepo.paidGCash = !jobRepo.paidGCash;
                      actualPaymentStatus = returnPaymentStatusDuringToggle();
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// 💵 AMOUNT FIELDS
          Row(
            children: [
              if (jobRepo.paidCash)
                Expanded(
                  child: _glassAmountField(
                    label: "Cash Amount",
                    controller: jobRepo.cashAmountVar,
                  ),
                ),
              if (jobRepo.paidCash && jobRepo.paidGCash)
                const SizedBox(width: 12),
              if (jobRepo.paidGCash)
                Expanded(
                  child: _glassAmountField(
                    label: "GCash Amount",
                    controller: jobRepo.gCashAmountVar,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          /// ✅ GCASH VERIFIED
          if (jobRepo.paidGCash)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "GCash Verified",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 6),
                Switch(
                  value: jobRepo.paidGCashVerified,
                  activeColor: Colors.greenAccent,
                  onChanged: (value) {
                    setState(() {
                      jobRepo.paidGCashVerified = value;
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

Widget _glassPaymentToggle({
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: selected
            ? const LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
              )
            : null,
        color: selected ? null : Colors.black.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : Colors.white.withOpacity(0.7),
        ),
      ),
    ),
  );
}

Widget _glassAmountField({
  required String label,
  required TextEditingController controller,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.black.withOpacity(0.25),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
      ),
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
    ),
  );
}

Visibility visFold(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
) {
  return Visibility(
    visible: (jobRepo.selectedPackage != othersPackage),
    child: _glassBinaryToggle(
      title: "Fold Option",
      leftLabel: "Fold",
      rightLabel: "No Fold",
      value: jobRepo.fold,
      onChanged: (val) {
        setState(() {
          jobRepo.fold = val;
        });
      },
    ),
  );
}

Visibility visMix(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
) {
  return Visibility(
    visible: (jobRepo.selectedPackage != othersPackage),
    child: _glassBinaryToggle(
      title: "Mix Option",
      leftLabel: "Mix",
      rightLabel: "Don't Mix",
      value: jobRepo.mix,
      onChanged: (val) {
        setState(() {
          jobRepo.mix = val;
        });
      },
    ),
  );
}

Widget _glassBinaryToggle({
  required String title,
  required String leftLabel,
  required String rightLabel,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Container(
    padding: const EdgeInsets.all(1),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: value
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
                      leftLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: value
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: !value
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
                      rightLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: !value
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget visBasket(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
) {
  return _glassCounterCard(
    label: "Basket",
    count: jobRepo.basket,
    highlight: jobRepo.basket > 0,
    onIncrement: () {
      setState(() => jobRepo.basket++);
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.basket > 0) jobRepo.basket--;
      });
    },
  );
}

Widget visEcoBag(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
) {
  return _glassCounterCard(
    label: "EcoBag",
    count: jobRepo.ebag,
    highlight: jobRepo.ebag > 0,
    onIncrement: () {
      setState(() => jobRepo.ebag++);
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.ebag > 0) jobRepo.ebag--;
      });
    },
  );
}

Widget visSako(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
) {
  return _glassCounterCard(
    label: "Sako",
    count: jobRepo.sako,
    highlight: jobRepo.sako > 0,
    onIncrement: () {
      setState(() => jobRepo.sako++);
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.sako > 0) jobRepo.sako--;
      });
    },
  );
}

Widget visAddFab(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
) {
  return _glassCounterCard(
    label: "+Fab (₱${addFabAnyItemModel.itemPrice})",
    count: jobRepo.addFabCount,
    visible: jobRepo.selectedPackage != othersPackage,
    highlight: jobRepo.addFabCount > 0,
    onIncrement: () {
      setState(() {
        jobRepo.addFabCount++;
        jobRepo.listSelectedItemModel.add(addFabAnyItemModel);
        jobRepo.totalPriceShortCutRegSS += addFabAnyItemModel.itemPrice;
      });
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.addFabCount > 0) {
          jobRepo.addFabCount--;
          jobRepo.listSelectedItemModel.remove(addFabAnyItemModel);
          jobRepo.totalPriceShortCutRegSS -= addFabAnyItemModel.itemPrice;
        }
      });
    },
  );
}

Widget visAddDry(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
) {
  return _glassCounterCard(
    label: "+Dry (₱${xDItemModel.itemPrice})",
    count: jobRepo.addExtraDryCount,
    visible: jobRepo.selectedPackage != othersPackage,
    highlight: jobRepo.addExtraDryCount > 0,
    onIncrement: () {
      setState(() {
        jobRepo.addExtraDryCount++;
        jobRepo.listSelectedItemModel.add(xDItemModel);
        jobRepo.totalPriceShortCutRegSS += xDItemModel.itemPrice;
      });
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.addExtraDryCount > 0) {
          jobRepo.addExtraDryCount--;
          jobRepo.listSelectedItemModel.remove(xDItemModel);
          jobRepo.totalPriceShortCutRegSS -= xDItemModel.itemPrice;
        }
      });
    },
  );
}

Widget visAddWash(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
) {
  return _glassCounterCard(
    label: "+Wash (₱${xWashItemModel.itemPrice})",
    count: jobRepo.addExtraWashCount,
    visible: jobRepo.selectedPackage != othersPackage,
    highlight: jobRepo.addExtraWashCount > 0,
    onIncrement: () {
      setState(() {
        jobRepo.addExtraWashCount++;
        jobRepo.listSelectedItemModel.add(xWashItemModel);
        jobRepo.totalPriceShortCutRegSS += xWashItemModel.itemPrice;
      });
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.addExtraWashCount > 0) {
          jobRepo.addExtraWashCount--;
          jobRepo.listSelectedItemModel.remove(xWashItemModel);
          jobRepo.totalPriceShortCutRegSS -= xWashItemModel.itemPrice;
        }
      });
    },
  );
}

Widget visAddSpin(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
) {
  return _glassCounterCard(
    label: "+Spin (₱${xSpinItemModel.itemPrice})",
    count: jobRepo.addExtraSpinCount,
    visible: jobRepo.selectedPackage != othersPackage,
    highlight: jobRepo.addExtraSpinCount > 0,
    onIncrement: () {
      setState(() {
        jobRepo.addExtraSpinCount++;
        jobRepo.listSelectedItemModel.add(xSpinItemModel);
        jobRepo.totalPriceShortCutRegSS += xSpinItemModel.itemPrice;
      });
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.addExtraSpinCount > 0) {
          jobRepo.addExtraSpinCount--;
          jobRepo.listSelectedItemModel.remove(xSpinItemModel);
          jobRepo.totalPriceShortCutRegSS -= xSpinItemModel.itemPrice;
        }
      });
    },
  );
}

Widget _glassCounterCard({
  required String label,
  required int count,
  required VoidCallback onIncrement,
  required VoidCallback onDecrement,
  bool visible = true,
  bool highlight = false,
}) {
  return Visibility(
    visible: visible,
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: highlight
              ? [
                  Colors.greenAccent.withOpacity(0.4),
                  Colors.tealAccent.withOpacity(0.3),
                ]
              : [
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// ➖
          _glassMiniCounterButton(
            label: "-",
            disabled: count <= 0,
            onTap: onDecrement,
          ),

          /// LABEL + COUNT
          Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$count pc",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          /// ➕
          _glassMiniCounterButton(
            label: "+",
            onTap: onIncrement,
          ),
        ],
      ),
    ),
  );
}

Widget _glassMiniCounterButton({
  required String label,
  required VoidCallback onTap,
  bool disabled = false,
}) {
  return GestureDetector(
    onTap: disabled ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: disabled
            ? null
            : const LinearGradient(
                colors: [
                  Colors.blueAccent,
                  Colors.purpleAccent,
                ],
              ),
        color: disabled ? Colors.grey.withOpacity(0.3) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: disabled ? Colors.white54 : Colors.white,
        ),
      ),
    ),
  );
}

Widget conRemarks(
  BuildContext context,
  Function setState,
  TextEditingController valueController,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 Title
        Text(
          "Remarks / Notes",
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),

        const SizedBox(height: 12),

        /// 🔹 Text Area
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(0.25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: TextFormField(
            controller: valueController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            minLines: 2,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              hintText: "Enter notes here...",
              hintStyle: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget customerAmount(
  BuildContext context,
  Function setState,
  TextEditingController valueController,
) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 LABEL
          Text(
            "Amount",
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 12),

          /// 🔹 AMOUNT FIELD
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                /// ₱ PREFIX
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    "₱",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),

                /// INPUT
                Expanded(
                  child: TextFormField(
                    controller: valueController,
                    textAlign: TextAlign.center,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'\d+(\.\d{0,2})?'),
                      ),
                    ],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: "0.00",
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget customerNumber(
  BuildContext context,
  Function setState,
  TextEditingController valueController,
) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 LABEL
          Text(
            "Mobile Number",
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 12),

          /// 🔹 PHONE FIELD
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                /// 🇵🇭 PREFIX
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    "+63",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),

                /// INPUT
                Expanded(
                  child: TextFormField(
                    controller: valueController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                      PHPhoneFormatter(),
                    ],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: "09XX XXX XXXX",
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget customerNameGCash(
  BuildContext context,
  Function setState,
  TextEditingController valueController,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 LABEL
        Text(
          "GCash Account Name",
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),

        const SizedBox(height: 12),

        /// 🔹 INPUT FIELD
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: TextFormField(
            controller: valueController,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              hintText: "Enter GCash Account Name",
              hintStyle: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
              border: InputBorder.none,
            ),

            /// ✅ Proper validation
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return "Please enter account name";
              }
              return null;
            },
          ),
        ),
      ],
    ),
  );
}

Widget fundTypeToggle(
  Function setState,
  List<int> listIntToSelect,
  GCashRepository gRepo,
) {
  String getFundLabel(int index) {
    const labels = [
      "Cash-in",
      "Load",
      "Cash-Out",
    ];
    return labels[index];
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
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔹 TITLE
          Text(
            "Fund Type",
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 14),

          /// 🔹 SEGMENTED CONTROL
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
                listIntToSelect.length,
                (index) {
                  final fundCode = listIntToSelect[index];
                  final isSelected = gRepo.selectedFundCode == fundCode;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          gRepo.selectedFundCode = fundCode;
                        });
                      },

                      /// 👇 DOUBLE TAP LOGIC CLEANLY HERE
                      onDoubleTap: () {
                        setState(() {
                          if (fundCode == menuOthLaundryPayment) {
                            customerAmountVar.text =
                                (int.tryParse(customerAmountVar.text) ??
                                        0 + 155)
                                    .toString();
                          }
                        });
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

Widget showUploadedImage(
  BuildContext context,
  Function setState,
  GCashRepository gRepo,
) {
  final bool isCashOut = gRepo.itemUniqueId == menuOthUniqIdCashOut;

  final String imageUrl =
      isCashOut ? gRepo.cashOutImageUrl : gRepo.cashInImageUrl;

  final IconData fallbackIcon = isCashOut ? Icons.logout : Icons.login;

  return Visibility(
    visible: true,
    child: GestureDetector(
      onTap: () {
        debugPrint(
            'itemUniqueId: ${gRepo.itemUniqueId} / ${gRepo.cashInImageUrl} / ${gRepo.cashOutImageUrl}');

        if (imageUrl.isEmpty) {
          callPickImageUniversal(context, gRepo.getModel()!, !isCashOut);
        } else {
          showImagePreview(context, imageUrl);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// 🖼 IMAGE PREVIEW
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _uploadPlaceholder(fallbackIcon),
                    )
                  : _uploadPlaceholder(fallbackIcon),
            ),

            /// 📷 Overlay when image exists
            if (imageUrl.isNotEmpty)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: const Icon(
                    Icons.visibility,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

Widget _uploadPlaceholder(IconData icon) {
  return Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.black.withOpacity(0.25),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 30,
          color: Colors.white70,
        ),
        const SizedBox(height: 6),
        const Text(
          "Upload Receipt",
          style: TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
      ],
    ),
  );
}

Widget visOnGoingStatus(
  BuildContext context,
  Function setState,
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
                  final isSelected = jobRepo.processStep == step;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          jobRepo.processStep = step;
                        });
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

InkWell visIconArea(BuildContext context, JobModelRepository jobRepo,
    JobModel job, bool isSelected, bool isRunning, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 38,
          height: 38,
          child: CircularProgressIndicator(
            value: jobRepo.allStatus,
            strokeWidth: 6,
            backgroundColor: backGroundStatusColor(job),
            color: isSelected ? Colors.deepPurple : Colors.deepPurple.shade300,
          ),
        ),
        AnimatedRotation(
          turns: jobRepo.allStatus,
          duration: const Duration(seconds: 2),
          curve: Curves.linear,
          child: Text(
            jobRepo.processStep.isNotEmpty
                ? '#${jobRepo.jobId}'
                : jobRepo.forSorting
                    ? '🔃'
                    : jobRepo.riderPickup
                        ? '🚲'
                        : '',
            style: const TextStyle(
              color: Colors.deepPurple,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 0,
                  color: Colors.blueGrey,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Expanded visNameArea(JobModel job, bool isSelected) {
  final primaryColor = isSelected ? Colors.deepPurple : Colors.black87;

  final secondaryColor =
      isSelected ? Colors.deepPurple.shade300 : Colors.grey.shade700;

  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// 🔹 CUSTOMER NAME + LOAD
        Row(
          children: [
            Flexible(
              child: Text(
                '${displayCustomerName(job.customerName)} '
                '(${job.finalLoad})',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              textBagDetails(job),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: secondaryColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 2),

        /// 🔹 SHORTCUT EXTRAS
        if (job.items.isNotEmpty)
          Text(
            textDetFabBleExtras(job.items),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: secondaryColor,
            ),
          ),

        const SizedBox(height: 2),

        /// 🔹 STATUS
        Text(
          textJobStatus(job),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: job.forSorting
                ? Colors.deepPurple.shade400
                : Colors.redAccent.shade200,
          ),
        ),

        /// 🔹 PRICING / REMARKS
        if (job.pricingSetup.isNotEmpty || job.remarks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${job.pricingSetup} ${job.remarks}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.deepPurple.shade300,
              ),
            ),
          ),
      ],
    ),
  );
}

InkWell visPaidUnpaidArea(
  BuildContext context,
  JobModelRepository jobRepo,
  bool isSelected,
  JobModel job,
) {
  final bool isPaid = !job.unpaid;

  final Color paidColor = isSelected ? Colors.deepPurple : Colors.black87;

  final Color unpaidColor = Colors.redAccent;

  final Color statusColor = isPaid ? paidColor : unpaidColor;

  final String statusText = job.unpaid
      ? "Unpaid"
      : job.paidCash
          ? "Paid • Cash"
          : job.paidGCash
              ? "Paid • GCash"
              : "Paid";

  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () {
      showPaidUnpaid(context, jobRepo);
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// 💰 AMOUNT
        Text(
          "₱ ${job.finalPrice}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: statusColor,
          ),
        ),

        const SizedBox(height: 2),

        /// 🔹 STATUS BADGE
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isPaid
                ? Colors.greenAccent.withOpacity(0.15)
                : Colors.redAccent.withOpacity(0.15),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

Future<bool> showCoolConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = "Confirm",
  String cancelText = "Cancel",
  bool isDanger = false,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Confirm",
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) {
      final width = MediaQuery.of(context).size.width;

      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: width > 600 ? 420 : width * 0.92,
              ),
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with glow accent
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: isDanger
                                ? [Colors.redAccent, Colors.red]
                                : [Colors.blueAccent, Colors.purpleAccent],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withOpacity(0.8),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(cancelText),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: isDanger
                                ? [Colors.redAccent, Colors.red]
                                : [Colors.blueAccent, Colors.purple],
                          ),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 26, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            confirmText,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
          child: child,
        ),
      );
    },
  );

  return result ?? false;
}
