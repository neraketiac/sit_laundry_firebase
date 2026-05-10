import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

Widget visItemsOnly(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  String getShortcutLabel(int value) {
    switch (value) {
      case menuFabWKLDValAny8ml:
        return "SOF";
      case menuDetWKL15:
        return "DET";
      case menuDetArielDVal:
        return "Ariel";
      case menuFabDowny36mlDVal:
        return "Downy";
      default:
        return value.toString();
    }
  }

  List<OtherItemModel> getCurrentDropdownItems() {
    if (jobRepo.selectedOthers == menuOthDVal) {
      return listOthItemsFB;
    } else if (jobRepo.selectedOthers == menuDetDVal) {
      return listDetItemsFB;
    } else if (jobRepo.selectedOthers == menuFabDVal) {
      return listFabItemsFB;
    } else {
      return listBleItems;
    }
  }

  final currentItems = getCurrentDropdownItems();

  if (currentItems.isNotEmpty &&
      !currentItems.contains(jobRepo.repoVarSelectedItem)) {
    jobRepo.repoVarSelectedItem = currentItems.first;
  }

  return Visibility(
    visible: true,
    child: Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          /// SHORTCUTS
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: listOthersItems.map((shortcut) {
              return glassShortcutButton(
                label: getShortcutLabel(shortcut),
                onTap: () {
                  if (shortcut == menuFabWKLDValAny8ml) {
                    addOtherItem(jobRepo, addFabAnyItemModel, context: context);
                  } else if (shortcut == menuDetWKL15) {
                    addOtherItem(jobRepo, detWKL15, context: context);
                  } else if (shortcut == menuDetArielDVal) {
                    addOtherItem(jobRepo, detAriel15, context: context);
                  } else if (shortcut == menuFabDowny36mlDVal) {
                    addOtherItem(jobRepo, addFabDowny36mlModel,
                        context: context);
                  }
                  dialogSetState();
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          /// CATEGORY TOGGLE
          ToggleButtons(
            isSelected: List.generate(
              listOthersDropDown.length,
              (i) => jobRepo.selectedOthers == listOthersDropDown[i],
            ),
            onPressed: (index) {
              jobRepo.selectedOthers = listOthersDropDown[index];
              final newItems = getCurrentDropdownItems();
              if (newItems.isNotEmpty) {
                jobRepo.repoVarSelectedItem = newItems.first;
              }
              dialogSetState();
            },
            borderRadius: BorderRadius.circular(10),
            selectedColor: Colors.white,
            fillColor: Colors.blueGrey.shade600,
            color: Colors.blueGrey.shade700,
            borderColor: Colors.blueGrey.shade200,
            selectedBorderColor: Colors.blueGrey.shade600,
            constraints: const BoxConstraints(minWidth: 56, minHeight: 36),
            children: const [
              Text('Oth', style: TextStyle(fontSize: 13)),
              Text('Det', style: TextStyle(fontSize: 13)),
              Text('Fab', style: TextStyle(fontSize: 13)),
              Text('Ble', style: TextStyle(fontSize: 13)),
            ],
          ),

          const SizedBox(height: 16),

          /// DROPDOWN + ADD BUTTON
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueGrey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<OtherItemModel>(
                      value: jobRepo.repoVarSelectedItem,
                      isExpanded: true,
                      items: currentItems
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text('${e.itemName}  ₱${e.itemPrice}',
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        jobRepo.repoVarSelectedItem = val!;
                        dialogSetState();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  addOtherItem(jobRepo, jobRepo.repoVarSelectedItem,
                      context: context);
                  dialogSetState();
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// SELECTED ITEMS
          Column(
            children: jobRepo.selectedItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final e = entry.value;
              final key = '${e.itemId}_$idx';

              jobRepo.itemQtyControllers.putIfAbsent(
                key,
                () => TextEditingController(text: "1"),
              );
              jobRepo.itemExpenseControllers.putIfAbsent(
                key,
                () => TextEditingController(text: "0"),
              );
              jobRepo.itemRemarksControllers.putIfAbsent(
                key,
                () => TextEditingController(text: ""),
              );

              // Add checkbox states for negative values (stored separately)
              final qtyNegativeKey = '${key}_qty_neg';
              final expenseNegativeKey = '${key}_exp_neg';

              if (!jobRepo.itemNegativeFlags.containsKey(qtyNegativeKey)) {
                jobRepo.itemNegativeFlags[qtyNegativeKey] =
                    true; // default checked = negative
              }
              if (!jobRepo.itemNegativeFlags.containsKey(expenseNegativeKey)) {
                jobRepo.itemNegativeFlags[expenseNegativeKey] =
                    false; // default unchecked = positive
              }

              final controller = jobRepo.itemQtyControllers[key]!;
              final expenseController = jobRepo.itemExpenseControllers[key]!;
              final remarksController = jobRepo.itemRemarksControllers[key]!;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: Colors.blueGrey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        removeOtherItem(jobRepo, e);
                        jobRepo.itemQtyControllers.remove(key);
                        jobRepo.itemExpenseControllers.remove(key);
                        jobRepo.itemRemarksControllers.remove(key);
                        jobRepo.itemNegativeFlags.remove(qtyNegativeKey);
                        jobRepo.itemNegativeFlags.remove(expenseNegativeKey);
                        dialogSetState();
                      },
                      child: const Icon(Icons.remove_circle_outline,
                          color: Colors.redAccent, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.itemName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Builder(builder: (context) {
                            // Get current values
                            final isQtyNegative =
                                jobRepo.itemNegativeFlags[qtyNegativeKey] ??
                                    true;
                            final expenseValue =
                                int.tryParse(expenseController.text.trim()) ??
                                    0;
                            final isExpenseNegative =
                                jobRepo.itemNegativeFlags[expenseNegativeKey] ??
                                    false;
                            final canCheckExpense = expenseValue != 0;

                            // Qty field with dynamic label showing negative indicator
                            final qtyField = SizedBox(
                              width: 80,
                              child: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*$')),
                                ],
                                onTap: () {
                                  controller.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: controller.text.length,
                                  );
                                },
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  labelText: isQtyNegative
                                      ? '-${e.stocksType}'
                                      : e.stocksType,
                                  labelStyle: TextStyle(
                                      fontSize: 11,
                                      color: isQtyNegative
                                          ? Colors.red.shade600
                                          : Colors.blueGrey.shade500),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.blueGrey.shade400),
                                  ),
                                ),
                              ),
                            );

                            // Qty checkbox
                            final qtyCheckbox = Checkbox(
                              value: isQtyNegative,
                              onChanged: (val) {
                                jobRepo.itemNegativeFlags[qtyNegativeKey] =
                                    val ?? true;
                                dialogSetState();
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );

                            // Expense field with dynamic label showing negative indicator
                            final expenseField = SizedBox(
                              width: 80,
                              child: TextField(
                                controller: expenseController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*$')),
                                ],
                                onTap: () {
                                  expenseController.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: expenseController.text.length,
                                  );
                                },
                                onChanged: (val) {
                                  // If expense becomes 0, uncheck the checkbox
                                  final newValue =
                                      int.tryParse(val.trim()) ?? 0;
                                  if (newValue == 0 && isExpenseNegative) {
                                    jobRepo.itemNegativeFlags[
                                        expenseNegativeKey] = false;
                                  }
                                  dialogSetState();
                                },
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  labelText:
                                      (canCheckExpense && isExpenseNegative)
                                          ? '-Exp'
                                          : 'Exp',
                                  labelStyle: TextStyle(
                                      fontSize: 11,
                                      color:
                                          (canCheckExpense && isExpenseNegative)
                                              ? Colors.red.shade600
                                              : Colors.blueGrey.shade500),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.blueGrey.shade400),
                                  ),
                                ),
                              ),
                            );

                            // Expense checkbox
                            final expenseCheckbox = Checkbox(
                              value: canCheckExpense && isExpenseNegative,
                              onChanged: canCheckExpense
                                  ? (val) {
                                      jobRepo.itemNegativeFlags[
                                          expenseNegativeKey] = val ?? false;
                                      dialogSetState();
                                    }
                                  : null,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );

                            // Remarks field
                            final remarksField = Expanded(
                              child: TextField(
                                controller: remarksController,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  labelText: 'Remarks',
                                  labelStyle: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blueGrey.shade500),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.blueGrey.shade400),
                                  ),
                                ),
                                maxLines: 1,
                              ),
                            );

                            // Two-row layout:
                            // Row 1: QTY Input Box + Checkbox
                            // Row 2: EXPENSE Input Box + Checkbox + Remarks
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row 1: QTY Field + Checkbox
                                Row(children: [
                                  qtyField,
                                  const SizedBox(width: 8),
                                  qtyCheckbox,
                                ]),
                                const SizedBox(height: 8),
                                // Row 2: EXPENSE Field + Checkbox + Remarks
                                Row(children: [
                                  expenseField,
                                  const SizedBox(width: 8),
                                  expenseCheckbox,
                                  const SizedBox(width: 8),
                                  remarksField,
                                ]),
                              ],
                            );
                          }),
                        ],
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
