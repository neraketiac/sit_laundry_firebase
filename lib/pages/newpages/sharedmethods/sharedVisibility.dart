import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showPaidUnpaid.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedConstantsFinal.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/variables/newvariables/gcash_repository.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_ble.dart';
import 'package:laundry_firebase/variables/newvariables/variables_det.dart';
import 'package:laundry_firebase/variables/newvariables/variables_fab.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';

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
                ? '${jobRepo.selectedProcessStep.isEmpty ? '' : '#${jobRepo.selectedJobId} '}${jobRepo.selectedCustomerNameVar.text}'
                : '${jobRepo.selectedProcessStep.isEmpty ? '' : '#${jobRepo.selectedJobId} '}${jobRepo.selectedCustomerNameVar.text} '
                    '(${jobRepo.selectedFinalLoad})\n'
                    '${textBagDetails(jobRepo.getJobsModel()!)} '
                    '₱ ${jobRepo.selectedFinalPrice}.00',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: jobRepo.selectedCustomerNameVar.text.isEmpty
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
                      setState(() {
                        jobRepo.repoVarSelectedIntRiderPickup =
                            listRiderPickup[index];
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
                    setState(() {
                      jobRepo.selectedIsCustomerPickedUp = value ?? false;
                    });
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
                    setState(() {
                      jobRepo.selectedIsDeliveredToCustomer = value ?? false;
                    });
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
                      if (jobRepo.selectedPackagePrev == intOthersPackage &&
                          jobRepo.selectedItems.isNotEmpty) {
                        final confirm = await showCoolConfirmDialog(
                          context: context,
                          title: "Change Package?",
                          message: "Items in All Services will be removed.",
                          confirmText: "Yes",
                        );

                        if (!confirm) return;

                        setState(() {
                          jobRepo.selectedItems.clear();
                          jobRepo.repoVarTotalPriceOthers = 0;
                        });
                      }

                      setState(() {
                        jobRepo.selectedPackage = value;
                        jobRepo.selectedPackagePrev = value;

                        if (value == intOthersPackage) {
                          jobRepo.repoVarSelectedItem = listOthItems[0];
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
  jobRepo.repoVarBasePriceAmount = prices[jobRepo.selectedPackage] ?? 155;
  jobRepo.maxPartial = maxPartialOptions[jobRepo.selectedPackage] ?? 3;
  // 🧠 UI rules

  final bool showPointOne = jobRepo.selectedFinalKilo >= 8 &&
      (jobRepo.selectedFinalKilo % 8) < jobRepo.maxPartial;

  jobRepo.repoVarTotalPriceRegSS =
      computeTotalPrice(jobRepo.selectedFinalKilo, jobRepo) +
          jobRepo.repoVarTotalPriceShortCutRegSS;

  // ➕➖ handlers
  void incrementOne() {
    setState(() {
      jobRepo.selectedFinalKilo += 1;
      jobRepo.selectedFinalKilo = jobRepo.selectedFinalKilo.floorToDouble();
      resetPaymentStatus(jobRepo);
    });
  }

  void incrementPointOne() {
    setState(() {
      jobRepo.selectedFinalKilo =
          double.parse((jobRepo.selectedFinalKilo + 0.1).toStringAsFixed(1));
      resetPaymentStatus(jobRepo);
    });
  }

  void decrementOne() {
    setState(() {
      jobRepo.selectedFinalKilo -= 1;
      if (jobRepo.selectedFinalKilo < 1) jobRepo.selectedFinalKilo = 1;
      jobRepo.selectedFinalKilo = jobRepo.selectedFinalKilo.floorToDouble();
      resetPaymentStatus(jobRepo);
    });
  }

  return Visibility(
    visible: (jobRepo.selectedPackage == intOthersPackage
        ? false
        : jobRepo.selectedPerKilo),
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
                formatter.format(jobRepo.repoVarTotalPriceRegSS),
                style: const TextStyle(
                  fontSize: fontSizeTotalPrice,
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
                  "${jobRepo.selectedFinalKilo.toStringAsFixed(
                    jobRepo.selectedFinalKilo % 1 == 0 ? 0 : 1,
                  )} kg",
                  style: const TextStyle(
                    fontSize: fontSizeKiloLoad,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        jobRepo.selectedPerKilo = false;
                        resetPaymentStatus(jobRepo);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
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
                      child: const Text(
                        "Switch to Load",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    )),
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
                disabled: jobRepo.selectedFinalKilo <= 1,
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

Visibility visAmountRegSSPerLoad(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
  const prices = {
    intRegularPackage: 155,
    intSayoSabonPackage: 125,
    intOthersPackage: 0,
  };

  jobRepo.repoVarBasePriceAmount = prices[jobRepo.selectedPackage] ?? 155;

  jobRepo.repoVarTotalPriceRegSS =
      (jobRepo.repoVarBasePriceAmount * jobRepo.selectedFinalLoad) +
          jobRepo.repoVarTotalPriceShortCutRegSS;

  void incrementOne() {
    setState(() {
      jobRepo.selectedFinalLoad += 1;
      resetPaymentStatus(jobRepo);
    });
  }

  void decrementOne() {
    setState(() {
      jobRepo.selectedFinalLoad -= 1;
      if (jobRepo.selectedFinalLoad < 1) jobRepo.selectedFinalLoad = 1;
      resetPaymentStatus(jobRepo);
    });
  }

  return Visibility(
    visible: (jobRepo.selectedPackage == intOthersPackage
        ? false
        : !jobRepo.selectedPerKilo),
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
                formatter.format(jobRepo.repoVarTotalPriceRegSS),
                style: const TextStyle(
                  fontSize: fontSizeTotalPrice,
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
                  "${jobRepo.selectedFinalLoad} load",
                  style: const TextStyle(
                    fontSize: fontSizeKiloLoad, // ← SAME AS KG
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        jobRepo.selectedPerKilo = true;
                        resetPaymentStatus(jobRepo);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
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
                      child: const Text(
                        "Switch to Kg",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    )),
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
                disabled: jobRepo.selectedFinalLoad <= 1,
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

Widget visAmountOthersOnly(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
) {
  void addOtherItem(OtherItemModel item) {
    jobRepo.selectedItems.add(item);
    jobRepo.repoVarTotalPriceOthers += item.itemPrice;
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
    visible: (jobRepo.selectedPackage == intOthersPackage),
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
                formatter.format(jobRepo.repoVarTotalPriceOthers),
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
                    value: jobRepo.repoVarSelectedItem,
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
                        jobRepo.repoVarSelectedItem = val!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _glassAddButton(
                onTap: () {
                  setState(() {
                    addOtherItem(jobRepo.repoVarSelectedItem);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// 🧾 SELECTED ITEMS LIST
          Column(
            children: jobRepo.selectedItems.map((e) {
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
                          jobRepo.repoVarTotalPriceOthers -= e.itemPrice;
                          jobRepo.selectedItems.remove(e);
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

Visibility visPaidUnPaid(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
  // final List<int> listPaidUnpaid = [
  //   paidCash,
  //   paidGCash,
  // ];

  String returnPaymentStatusDuringToggle() {
    void resetPartialAmount() {
      jobRepo.repoVarCashAmountVar.text = '';
      jobRepo.repoVarGCashAmountVar.text = '';
    }

    void setPartialAmount(TextEditingController controller) {
      //only changed to final price if still no input
      if (controller.text == '' || controller.text == '0') {
        if (jobRepo.finalPrice == 0) {
          if (jobRepo.selectedPackage == intOthersPackage) {
            controller.text = jobRepo.repoVarTotalPriceOthers.toString();
          } else {
            controller.text = jobRepo.repoVarTotalPriceRegSS.toString();
          }
        } else {
          controller.text = jobRepo.selectedFinalPrice.toString();
        }
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

    if (jobRepo.selectedPaidCash && jobRepo.selectedPaidGCash) {
      resetPartialAmount();
      return 'Split payment';
    } else if (jobRepo.selectedPaidCash) {
      setPartialAmount(jobRepo.repoVarCashAmountVar);
      return 'Paid Cash';
    } else if (jobRepo.selectedPaidGCash) {
      setPartialAmount(jobRepo.repoVarGCashAmountVar);
      return 'Paid GCash';
    }
    resetPartialAmount();
    return 'Unpaid';
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
                colors: jobRepo.selectedUnpaid
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
                  selected: jobRepo.selectedPaidCash,
                  onTap: () {
                    setState(() {
                      jobRepo.selectedPaidCash = !jobRepo.selectedPaidCash;
                      actualPaymentStatus = returnPaymentStatusDuringToggle();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _glassPaymentToggle(
                  label: "GCash",
                  selected: jobRepo.selectedPaidGCash,
                  onTap: () {
                    setState(() {
                      jobRepo.selectedPaidGCash = !jobRepo.selectedPaidGCash;
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
              if (jobRepo.selectedPaidCash)
                Expanded(
                  child: _glassAmountField(
                    label: "Cash Amount",
                    controller: jobRepo.repoVarCashAmountVar,
                  ),
                ),
              if (jobRepo.selectedPaidCash && jobRepo.selectedPaidGCash)
                const SizedBox(width: 12),
              if (jobRepo.selectedPaidGCash)
                Expanded(
                  child: _glassAmountField(
                    label: "GCash Amount",
                    controller: jobRepo.repoVarGCashAmountVar,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          /// ✅ GCASH VERIFIED
          if (jobRepo.selectedPaidGCash)
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
                  value: jobRepo.selectedPaidGCashVerified,
                  activeColor: Colors.greenAccent,
                  onChanged: (value) {
                    setState(() {
                      jobRepo.selectedPaidGCashVerified = value;
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

Visibility visFold(
  BuildContext context,
  Function setState,
  JobModelRepository jobRepo,
) {
  return Visibility(
    visible: (jobRepo.selectedPackage != intOthersPackage),
    child: _glassBinaryToggle(
      title: "Fold Option",
      leftLabel: "Fold",
      rightLabel: "No Fold",
      value: jobRepo.selectedFold,
      onChanged: (val) {
        setState(() {
          jobRepo.selectedFold = val;
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
    visible: (jobRepo.selectedPackage != intOthersPackage),
    child: _glassBinaryToggle(
      title: "Mix Option",
      leftLabel: "Mix",
      rightLabel: "Don't Mix",
      value: jobRepo.selectedMix,
      onChanged: (val) {
        setState(() {
          jobRepo.selectedMix = val;
        });
      },
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
    count: jobRepo.selectedBasket,
    highlight: jobRepo.selectedBasket > 0,
    onIncrement: () {
      setState(() => jobRepo.selectedBasket++);
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.selectedBasket > 0) jobRepo.selectedBasket--;
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
    count: jobRepo.selectedEbag,
    highlight: jobRepo.selectedEbag > 0,
    onIncrement: () {
      setState(() => jobRepo.selectedEbag++);
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.selectedEbag > 0) jobRepo.selectedEbag--;
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
    count: jobRepo.selectedSako,
    highlight: jobRepo.selectedSako > 0,
    onIncrement: () {
      setState(() => jobRepo.selectedSako++);
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.selectedSako > 0) jobRepo.selectedSako--;
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
    count: jobRepo.repoVarAddFabCount,
    visible: jobRepo.selectedPackage != intOthersPackage,
    highlight: jobRepo.repoVarAddFabCount > 0,
    onIncrement: () {
      setState(() {
        jobRepo.repoVarAddFabCount++;
        jobRepo.selectedItems.add(addFabAnyItemModel);
        jobRepo.repoVarTotalPriceShortCutRegSS += addFabAnyItemModel.itemPrice;
      });
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.repoVarAddFabCount > 0) {
          jobRepo.repoVarAddFabCount--;
          jobRepo.selectedItems.remove(addFabAnyItemModel);
          jobRepo.repoVarTotalPriceShortCutRegSS -=
              addFabAnyItemModel.itemPrice;
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
    count: jobRepo.repoVarAddExtraDryCount,
    visible: jobRepo.selectedPackage != intOthersPackage,
    highlight: jobRepo.repoVarAddExtraDryCount > 0,
    onIncrement: () {
      setState(() {
        jobRepo.repoVarAddExtraDryCount++;
        jobRepo.selectedItems.add(xDItemModel);
        jobRepo.repoVarTotalPriceShortCutRegSS += xDItemModel.itemPrice;
      });
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.repoVarAddExtraDryCount > 0) {
          jobRepo.repoVarAddExtraDryCount--;
          jobRepo.selectedItems.remove(xDItemModel);
          jobRepo.repoVarTotalPriceShortCutRegSS -= xDItemModel.itemPrice;
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
    count: jobRepo.repoVarAddExtraWashCount,
    visible: jobRepo.selectedPackage != intOthersPackage,
    highlight: jobRepo.repoVarAddExtraWashCount > 0,
    onIncrement: () {
      setState(() {
        jobRepo.repoVarAddExtraWashCount++;
        jobRepo.selectedItems.add(xWashItemModel);
        jobRepo.repoVarTotalPriceShortCutRegSS += xWashItemModel.itemPrice;
      });
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.repoVarAddExtraWashCount > 0) {
          jobRepo.repoVarAddExtraWashCount--;
          jobRepo.selectedItems.remove(xWashItemModel);
          jobRepo.repoVarTotalPriceShortCutRegSS -= xWashItemModel.itemPrice;
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
    count: jobRepo.repoVarAddExtraSpinCount,
    visible: jobRepo.selectedPackage != intOthersPackage,
    highlight: jobRepo.repoVarAddExtraSpinCount > 0,
    onIncrement: () {
      setState(() {
        jobRepo.repoVarAddExtraSpinCount++;
        jobRepo.selectedItems.add(xSpinItemModel);
        jobRepo.repoVarTotalPriceShortCutRegSS += xSpinItemModel.itemPrice;
      });
    },
    onDecrement: () {
      setState(() {
        if (jobRepo.repoVarAddExtraSpinCount > 0) {
          jobRepo.repoVarAddExtraSpinCount--;
          jobRepo.selectedItems.remove(xSpinItemModel);
          jobRepo.repoVarTotalPriceShortCutRegSS -= xSpinItemModel.itemPrice;
        }
      });
    },
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
                  final isSelected = jobRepo.selectedProcessStep == step;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          jobRepo.selectedProcessStep = step;
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
            value: jobRepo.selectedAllStatus,
            strokeWidth: 6,
            backgroundColor: backGroundStatusColor(job),
            color: isSelected ? Colors.deepPurple : Colors.deepPurple.shade300,
          ),
        ),
        AnimatedRotation(
          turns: jobRepo.selectedAllStatus,
          duration: const Duration(seconds: 2),
          curve: Curves.linear,
          child: Text(
            jobRepo.selectedProcessStep.isNotEmpty
                ? '#${jobRepo.jobId}'
                : jobRepo.repoVarSelectedIntRiderPickup == intForSorting
                    ? '🔃'
                    : jobRepo.repoVarSelectedIntRiderPickup == intRiderPickup
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
        if (job.pricingSetup.isNotEmpty ||
            job.remarks.isNotEmpty ||
            (job.unpaid && job.paidCash || job.unpaid && job.paidGCash))
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              textPricingSetupRemarksUnpaidRemakrs(job),
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
) {
  final bool isPaid = !jobRepo.selectedUnpaid;

  final Color paidColor = isSelected ? Colors.deepPurple : Colors.black87;

  final Color unpaidColor = Colors.redAccent;

  final Color statusColor = isPaid ? paidColor : unpaidColor;

  final String statusText = jobRepo.selectedUnpaid
      ? "Unpaid"
      : jobRepo.selectedPaidCash
          ? "Paid • Cash"
          : jobRepo.selectedPaidGCash
              ? "Paid • GCash"
              : "Paid";

  //prioritize order check
  // unpaid = cash not enough
  // unpaid = gcash not enough
  // unpaid = cash + gcash not enough
  // unpaid = gcash not verified
  // unpaid = cash + gcash + not verified

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
          "₱ ${jobRepo.selectedFinalPrice}",
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

//***************************************************************** */
//                                                                  //
//                           ALERTS                                 //
//                                                                  //
//***************************************************************** */

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
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
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

//***************************************************************** */
//                                                                  //
//                        NON FINAL VIS ITEMS                       //
//                      *being call in here                         //
//***************************************************************** */

Widget _uploadPlaceholder(IconData icon) {
  return Container(
    width: 20,
    height: 20,
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
