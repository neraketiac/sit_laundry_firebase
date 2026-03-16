import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/global/variables_ble.dart';
import 'package:laundry_firebase/core/global/variables_det.dart';
import 'package:laundry_firebase/core/global/variables_fab.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/actions/glassShortcutButton.dart';

Widget visAmountOthersOnly(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
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

  String getOtherShortCutLabel(int value) {
    switch (value) {
      case menuOthNF155:
        return "NF155";
      case menuOthNF125:
        return "NF125";
      case menuOthWD98:
        return "WD98";
      default:
        return value.toString();
    }
  }

  List<OtherItemModel> getCurrentDropdownItems() {
    if (jobRepo.selectedOthers == menuOthDVal) {
      return listOthItems;
    } else if (jobRepo.selectedOthers == menuDetDVal) {
      return listDetItems;
    } else if (jobRepo.selectedOthers == menuFabDVal) {
      return listFabItems;
    } else {
      return listBleItems;
    }
  }

  final currentItems = getCurrentDropdownItems();

  // 🔐 SAFETY: ensure selected item always exists in current list
  if (!currentItems.contains(jobRepo.repoVarSelectedItem)) {
    // if (currentItems.isNotEmpty) {
    jobRepo.repoVarSelectedItem = currentItems.first;
    // } else {
    //   jobRepo.repoVarSelectedItem = null;
    // }
  }

  return Visibility(
    visible: jobRepo.selectedPackage == intOthersPackage,
    child: Container(
      padding: const EdgeInsets.all(16),
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
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ================= TOTAL =================

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
                  fontSize: fontSizeTotalPrice,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 3,
                width: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.cyanAccent, Colors.purpleAccent],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================= SHORTCUTS =================

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: listOthersDropDownShortCuts.map((shortcut) {
              return glassShortcutButton(
                label: getShortcutLabel(shortcut),
                onTap: () {
                  if (shortcut == menuOth155) {
                    addOtherItem(jobRepo, reg155ItemModel);
                  } else if (shortcut == menuOth125) {
                    addOtherItem(jobRepo, reg125ItemModel);
                  } else if (shortcut == menuOthXD) {
                    addOtherItem(jobRepo, xDItemModel);
                  } else if (shortcut == menuFabWKLDValAny8ml) {
                    addOtherItem(jobRepo, addFabAnyItemModel);
                  }

                  dialogSetState();
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: listOthersShort2DropDownShortCuts.map((shortcut) {
              return glassShortcutButton(
                label: getOtherShortCutLabel(shortcut),
                onTap: () {
                  if (shortcut == menuOthNF155) {
                    addOtherItem(jobRepo, nf155ItemModel);
                  } else if (shortcut == menuOthNF125) {
                    addOtherItem(jobRepo, nf125ItemModel);
                  } else if (shortcut == menuOthWD98) {
                    addOtherItem(jobRepo, washDryOnlytemModel);
                  } else if (shortcut == menuOthFree) {
                    addOtherItem(jobRepo, promoFree);
                  }
                  dialogSetState();
                },
              );
            }).toList(),
          ),
          if (autocompleteSelected.loyaltyCount >= 10)
            const SizedBox(height: 14),
          if (autocompleteSelected.loyaltyCount >= 10)
            glassShortcutButton(
                label: "Free",
                onTap: () {
                  addOtherItem(jobRepo, reg155ItemModel);
                  addOtherItem(jobRepo, promoFree);

                  dialogSetState();
                }),

          const SizedBox(height: 14),
          // ================= ALL ITEMS CATEGORY =================

          Column(
            children: [
              Text(
                'ALL ITEMS',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.black.withOpacity(0.25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
                child: ToggleButtons(
                  isSelected: List.generate(
                    listOthersDropDown.length,
                    (i) => jobRepo.selectedOthers == listOthersDropDown[i],
                  ),
                  onPressed: (index) {
                    jobRepo.selectedOthers = listOthersDropDown[index];

                    final newItems = getCurrentDropdownItems();
                    jobRepo.repoVarSelectedItem =
                        (newItems.isNotEmpty ? newItems.first : null)!;

                    dialogSetState();
                  },
                  borderRadius: BorderRadius.circular(14),
                  selectedColor: Colors.black,
                  fillColor: Colors.cyanAccent,
                  color: Colors.white70,
                  borderColor: Colors.white24,
                  selectedBorderColor: Colors.cyanAccent,
                  constraints: const BoxConstraints(
                    minWidth: 60,
                    minHeight: 32,
                  ),
                  children: const [
                    Text('Oth'),
                    Text('Det'),
                    Text('Fab'),
                    Text('Ble'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================= DROPDOWN + ADD =================

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.25),
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
                    items: currentItems
                        .map(
                          (e) => DropdownMenuItem<OtherItemModel>(
                            value: e,
                            child: Text(
                              "${e.itemName}  ₱${e.itemPrice}",
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: currentItems.isEmpty
                        ? null
                        : (val) {
                            jobRepo.repoVarSelectedItem = val!;

                            dialogSetState();
                          },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: jobRepo.repoVarSelectedItem == null
                    ? null
                    : () {
                        addOtherItem(jobRepo, jobRepo.repoVarSelectedItem!);

                        dialogSetState();
                      },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: jobRepo.repoVarSelectedItem == null
                        ? Colors.grey
                        : Colors.cyanAccent,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================= SELECTED ITEMS =================

          Column(
            children: jobRepo.selectedItems.map((e) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        removeOtherItem(jobRepo, e);

                        dialogSetState();
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
