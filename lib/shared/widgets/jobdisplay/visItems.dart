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
        return "-1 SOF";
      case menuDetWKL15:
        return "-1 DET";
      case menuDetArielDVal:
        return "-1 Ariel(15)";
      case menuFabDowny36mlDVal:
        return "-1 Downy";
      default:
        return value.toString();
    }
  }

  List<OtherItemModel> getCurrentDropdownItems() {
    if (jobRepo.selectedOthers == menuOthDVal) {
      return listOtherItemsFB;
    } else if (jobRepo.selectedOthers == menuDetDVal) {
      return listDetItems;
    } else if (jobRepo.selectedOthers == menuFabDVal) {
      return listFabItems;
    } else {
      return listBleItems;
    }
  }

  final currentItems = getCurrentDropdownItems();

  if (!currentItems.contains(jobRepo.repoVarSelectedItem)) {
    jobRepo.repoVarSelectedItem = currentItems.first;
  }

  return Visibility(
    visible: true,
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
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          /// SHORTCUTS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: listOthersItems.map((shortcut) {
              return glassShortcutButton(
                label: getShortcutLabel(shortcut),
                onTap: () {
                  if (shortcut == menuFabWKLDValAny8ml) {
                    addOtherItem(jobRepo, addFabAnyItemModel);
                  } else if (shortcut == menuDetWKL15) {
                    addOtherItem(jobRepo, detWKL15);
                  } else if (shortcut == menuDetArielDVal) {
                    addOtherItem(jobRepo, detAriel15);
                  } else if (shortcut == menuFabDowny36mlDVal) {
                    addOtherItem(jobRepo, addFabDowny36mlModel);
                  }

                  dialogSetState();
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          /// CATEGORY TOGGLE
          ToggleButtons(
            isSelected: List.generate(
              listOthersDropDown.length,
              (i) => jobRepo.selectedOthers == listOthersDropDown[i],
            ),
            onPressed: (index) {
              jobRepo.selectedOthers = listOthersDropDown[index];

              final newItems = getCurrentDropdownItems();
              jobRepo.repoVarSelectedItem = newItems.first;

              dialogSetState();
            },
            borderRadius: BorderRadius.circular(14),
            selectedColor: Colors.black,
            fillColor: Colors.cyanAccent,
            color: Colors.white70,
            borderColor: Colors.white24,
            selectedBorderColor: Colors.cyanAccent,
            children: const [
              Text('Oth'),
              Text('Det'),
              Text('Fab'),
              Text('Ble'),
            ],
          ),

          const SizedBox(height: 24),

          /// DROPDOWN + ADD BUTTON
          Row(
            children: [
              Expanded(
                child: DropdownButton<OtherItemModel>(
                  value: jobRepo.repoVarSelectedItem,
                  isExpanded: true,
                  items: currentItems
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text("${e.itemName}  ₱${e.itemPrice}"),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    jobRepo.repoVarSelectedItem = val!;
                    dialogSetState();
                  },
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  addOtherItem(jobRepo, jobRepo.repoVarSelectedItem!);
                  dialogSetState();
                },
              )
            ],
          ),

          const SizedBox(height: 24),

          /// SELECTED ITEMS WITH PCS INPUT
          Column(
            children: jobRepo.selectedItems.map((e) {
              jobRepo.itemQtyControllers.putIfAbsent(
                e.itemId,
                () => TextEditingController(text: "-1"),
              );

              final controller = jobRepo.itemQtyControllers[e.itemId]!;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.25),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        removeOtherItem(jobRepo, e);
                        jobRepo.itemQtyControllers.remove(e.itemId);
                        dialogSetState();
                      },
                      child: const Icon(
                        Icons.remove_circle,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// ITEM NAME
                    Expanded(
                      child: Text(
                        e.itemName,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    /// PCS INPUT
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "1",
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.35),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// PRICE
                    Text(
                      e.stocksType,
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
