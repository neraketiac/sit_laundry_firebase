import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/global/variables_ble.dart';
import 'package:laundry_firebase/core/global/variables_det.dart';
import 'package:laundry_firebase/core/global/variables_fab.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
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
        return "₱155";
      case menuOthW8t9:
        return "₱190";
      case menuOthW9t10:
        return "₱260";
      case menuOth125:
        return "₱125";
      case menuOth150:
        return "₱150";
      case menuOthXD:
        return "XDry";
      case menuOthXW:
        return "XWash";
      case menuFabWKLDValAny8ml:
        return "+Fab8";
      default:
        return value.toString();
    }
  }

  String getOtherShortCutLabel(int value) {
    switch (value) {
      case menuOthNF155:
        return "₱155";
      case menuOthNF125:
        return "₱125";
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
      return listDetItemsFB;
    } else if (jobRepo.selectedOthers == menuFabDVal) {
      return listFabItemsFB;
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
                "Total",
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

          Builder(builder: (ctx) {
            final isTablet = AppScale.of(ctx).isTablet;

            // Shared button builders
            Widget fullServiceRow() => _sectionRow(
                  label: 'Full Service',
                  accentColor: Colors.cyanAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: listOthersDropDownShortCuts.map((shortcut) {
                      return glassShortcutButton(
                        label: getShortcutLabel(shortcut),
                        onTap: () {
                          if (shortcut == menuOth155) {
                            addOtherItem(jobRepo, reg155ItemModel);
                          } else if (shortcut == menuOthW8t9) {
                            addOtherItem(jobRepo, reg155ItemModel);
                            addOtherItem(
                                jobRepo,
                                listOthItems.firstWhere(
                                    (i) => i.itemId == menuOthW8t9));
                          } else if (shortcut == menuOthW9t10) {
                            addOtherItem(jobRepo, reg155ItemModel);
                            addOtherItem(
                                jobRepo,
                                listOthItems.firstWhere(
                                    (i) => i.itemId == menuOthW9t10));
                          }
                          dialogSetState();
                        },
                      );
                    }).toList(),
                  ),
                );

            Widget sayoSabonRow() => _sectionRow(
                  label: 'Sayo Sabon',
                  accentColor: Colors.amberAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: listOthersShortRow2.map((shortcut) {
                      return glassShortcutButton(
                        label: getShortcutLabel(shortcut),
                        onTap: () {
                          if (shortcut == menuOth125) {
                            addOtherItem(jobRepo, reg125ItemModel);
                          } else if (shortcut == menuOth150) {
                            addOtherItem(jobRepo, reg150ItemModel);
                          }
                          dialogSetState();
                        },
                      );
                    }).toList(),
                  ),
                );

            Widget addOnsRow() => _sectionRow(
                  label: 'Add-Ons',
                  accentColor: Colors.greenAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: listOthersShortRow3.map((shortcut) {
                      return glassShortcutButton(
                        label: getShortcutLabel(shortcut),
                        onTap: () {
                          if (shortcut == menuOthXD) {
                            addOtherItem(jobRepo, xDItemModel);
                          } else if (shortcut == menuOthXW) {
                            addOtherItem(jobRepo, xWashItemModel);
                          } else if (shortcut == menuFabWKLDValAny8ml) {
                            addOtherItem(jobRepo, addFabAnyItemModel);
                          }
                          dialogSetState();
                        },
                      );
                    }).toList(),
                  ),
                );

            Widget noFoldRow() => _sectionRow(
                  label: 'No Fold',
                  accentColor: Colors.orangeAccent.shade700,
                  child: Row(
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
                          }
                          dialogSetState();
                        },
                      );
                    }).toList(),
                  ),
                );

            if (isTablet) {
              // iPad: 2-column grid
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: fullServiceRow()),
                      const SizedBox(width: 8),
                      Expanded(child: sayoSabonRow()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: addOnsRow()),
                      const SizedBox(width: 8),
                      Expanded(child: noFoldRow()),
                    ],
                  ),
                ],
              );
            }

            // iPhone: original stacked layout
            return Column(
              children: [
                fullServiceRow(),
                const SizedBox(height: 8),
                sayoSabonRow(),
                const SizedBox(height: 8),
                addOnsRow(),
                const SizedBox(height: 8),
                noFoldRow(),
              ],
            );
          }),
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
          // ================= ALL ITEMS (collapsible) =================

          Theme(
            data: ThemeData(
              dividerColor: Colors.transparent,
              colorScheme: const ColorScheme.dark(),
            ),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              childrenPadding: const EdgeInsets.only(top: 8),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.4)),
              ),
              backgroundColor: Colors.black.withValues(alpha: 0.15),
              collapsedBackgroundColor: Colors.black.withValues(alpha: 0.1),
              leading: const Icon(Icons.inventory_2_outlined,
                  color: Colors.white54, size: 18),
              title: const Text(
                'ALL ITEMS',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              trailing: const Icon(Icons.expand_more,
                  color: Colors.white54, size: 18),
              children: [
                // Category toggle
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.black.withValues(alpha: 0.25),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.25)),
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
                    constraints:
                        const BoxConstraints(minWidth: 60, minHeight: 32),
                    children: const [
                      Text('Oth'),
                      Text('Det'),
                      Text('Fab'),
                      Text('Ble'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Dropdown + Add
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black.withValues(alpha: 0.25),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: DropdownButton<OtherItemModel>(
                          value: jobRepo.repoVarSelectedItem,
                          isExpanded: true,
                          dropdownColor: Colors.black87,
                          underline: const SizedBox(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          items: currentItems
                              .map((e) => DropdownMenuItem<OtherItemModel>(
                                    value: e,
                                    child:
                                        Text("${e.itemName}  ₱${e.itemPrice}"),
                                  ))
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
                      onTap: () {
                        addOtherItem(jobRepo, jobRepo.repoVarSelectedItem!);
                        dialogSetState();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.cyanAccent,
                        ),
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
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
                        size: 25,
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

Widget _sectionRow({
  required String label,
  required Color accentColor,
  required Widget child,
}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: Colors.white.withValues(alpha: 0.05),
      border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            color: accentColor.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}
