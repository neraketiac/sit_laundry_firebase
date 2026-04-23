//floating button done jobs  ###########################################################
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

void showFundCheck(BuildContext context) {
  final s = AppScale.of(context);

  // Controllers created once — persist across rebuilds
  final controllers = {
    for (final d in denominations)
      d: TextEditingController(text: qtyMap[d]!.toString())
  };

  void syncControllers() {
    for (final d in denominations) {
      final newText = qtyMap[d]!.toString();
      final c = controllers[d]!;
      if (c.text != newText) {
        c.value = c.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
  }

  void resetAllQty() {
    qtyMap.updateAll((key, value) => 0);
  }

  Visibility countBills(
    VoidCallback dialogSetState,
  ) {
    Widget denominationRow(int denom) {
      final qty = qtyMap[denom]!;
      final controller = controllers[denom]!;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 0),
        padding: EdgeInsets.symmetric(horizontal: s.gap + 2, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '   ₱$denom',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: s.bodyLarge),
            ),

            // Group for buttons + qty
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(2),
                    constraints: BoxConstraints(
                        minWidth: s.iconLarge, minHeight: s.iconLarge),
                    icon: Icon(Icons.remove_circle,
                        color: Colors.blue, size: s.iconLarge),
                    onPressed: qty > 0
                        ? () {
                            qtyMap[denom] = qty - 1;
                            syncControllers();
                            dialogSetState();
                          }
                        : null,
                  ),
                  SizedBox(
                    width: s.isTablet ? 64 : 48,
                    height: s.isTablet ? 44 : 36,
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: s.body),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: s.gapSmall + 4),
                        border: const OutlineInputBorder(),
                      ),
                      onTap: () => controller.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: controller.text.length,
                      ),
                      onChanged: (val) {
                        final intVal = int.tryParse(val) ?? 0;
                        qtyMap[denom] = intVal;
                        dialogSetState();
                      },
                    ),
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    constraints: BoxConstraints(
                        minWidth: s.iconLarge, minHeight: s.iconLarge),
                    icon: Icon(Icons.add_circle,
                        color: Colors.blue, size: s.iconLarge),
                    onPressed: () {
                      qtyMap[denom] = qty + 1;
                      syncControllers();
                      dialogSetState();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Visibility(
      visible: true,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: decoLightBlue(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 All denomination inputs
            ...denominations.map(
              (d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: denominationRow(d),
              ),
            ),

            const Divider(height: 10),

            // 🔹 TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Current Funds:\n₱ ${pesoFormat.format(alwaysTheLatestFunds)}',
                    style: TextStyle(fontSize: s.tiny + 1)),
                Text(
                  'TOTAL: ',
                  style: TextStyle(
                    fontSize: s.body,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₱ ${pesoFormat.format(grandTotal)}',
                  style: TextStyle(
                    fontSize: s.bodyLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                    ((alwaysTheLatestFunds - grandTotal) == 0
                        ? ('sakto: ₱ ${pesoFormat.format(alwaysTheLatestFunds - grandTotal)}')
                        : ((alwaysTheLatestFunds - grandTotal) < 0)
                            ? ('sobra: ₱ ${pesoFormat.format((alwaysTheLatestFunds - grandTotal) * -1)}')
                            : ('kulang: ₱ ${pesoFormat.format((alwaysTheLatestFunds - grandTotal) * -1)}')),
                    style: TextStyle(
                        fontSize: s.tiny + 1,
                        color: ((alwaysTheLatestFunds - grandTotal) == 0
                            ? Colors.green
                            : ((alwaysTheLatestFunds - grandTotal) < 0)
                                ? Colors.black
                                : Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveButtonSetRepository() async {
    String buildSelectedMoneyText() {
      final List<String> parts = [];

      String formatDenom(int denom) {
        if (denom >= 1000) {
          return '${denom ~/ 1000}k';
        } else if (denom >= 100) {
          return '${denom ~/ 100}h';
        } else {
          return denom.toString();
        }
      }

      qtyMap.forEach((denom, qty) {
        if (qty > 0) {
          //parts.add('₱$denom=$qty');
          parts.add('${formatDenom(denom)}*$qty');
        }
      });

      return parts.join(',');
    }

    SuppliesHistRepository.instance.setItemName(
        getItemNameOnly(menuOthCashInOutFunds, menuOthUniqIdFundsEOD));
    SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
    SuppliesHistRepository.instance.setItemUniqueId(menuOthUniqIdFundsEOD);
    SuppliesHistRepository.instance.setRemarks(buildSelectedMoneyText());
    SuppliesHistRepository.instance.setCurrentCounter(grandTotal);

    await setSuppliesRepository(context);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(2),
          titlePadding: const EdgeInsets.only(
            top: 5,
            left: 5,
            right: 5,
            bottom: 2,
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          backgroundColor: cFundsEOD,
          insetPadding: s.isTablet
              ? const EdgeInsets.symmetric(horizontal: 80, vertical: 40)
              : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Funds Maintenance\n",
                  style: TextStyle(
                    fontSize: s.headline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "Bilangain ang kasalukuyang funds\n",
                  style: TextStyle(fontSize: s.small),
                ),
                TextSpan(
                  text: "tuwing 9am / 12nn / 7pm",
                  style: TextStyle(fontSize: s.small),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                //key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    countBills(() => setState(() {})),
                  ],
                ),
              ),
            ),
          ),
          // 👇 Bottom buttons
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  resetAllQty();
                  syncControllers();
                });
              },
              child: const Text('Reset'),
            ),
            boxButtonElevated(
                context: context,
                label: 'Save',
                onPressed: () async {
                  saveButtonSetRepository();
                  setState(() {
                    resetAllQty();
                    syncControllers();
                  });
                  return true;
                }),
          ],
        );
      });
    },
  );
}
