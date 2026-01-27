//floating button done jobs  ###########################################################
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/sharedMethodAndVariable.dart';
import 'package:laundry_firebase/variables/updatedvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';

void showFundCheck(BuildContext context) {
  void resetAllQty() {
    qtyMap.updateAll((key, value) => 0);
  }

  Visibility countBills(Function setState) {
    Widget denominationRow(int denom, Function setState) {
      final qty = qtyMap[denom]!;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 0),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(6),
          color: const Color.fromARGB(255, 124, 213, 255),
        ),
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🔹 Denomination (left)
            SizedBox(
              width: 60,
              child: Text(
                '$denom',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 4),
            // 🔹 Qty box
            Container(
              width: 40,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: Text(
                '$qty',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(width: 4),

            // 🔹 -1 button
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              onPressed: qty > 0
                  ? () {
                      setState(() {
                        qtyMap[denom] = qty - 1;
                      });
                    }
                  : null,
            ),

            // 🔹 +1 button
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              onPressed: () {
                setState(() {
                  qtyMap[denom] = qty + 1;
                });
              },
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
                child: denominationRow(d, setState),
              ),
            ),

            const Divider(height: 10),

            // 🔹 TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Current Funds:\n₱ ${pesoFormat.format(alwaysTheLatestFunds)}',
                    style: TextStyle(fontSize: 8)),
                const Text(
                  'TOTAL: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₱ ${pesoFormat.format(grandTotal)}',
                  style: const TextStyle(
                    fontSize: 16,
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
                    // ((alwaysTheLatestFunds - grandTotal) <= 0
                    //     ? ('sakto:\n₱ ${pesoFormat.format(alwaysTheLatestFunds - grandTotal)}')
                    //     : 'kulang:\n₱ ${pesoFormat.format(alwaysTheLatestFunds - grandTotal)}'),
                    style: TextStyle(
                        fontSize: 8,
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

  Future<void> saveButtonProcessEOD() async {
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
    SuppliesHistRepository.instance.setItemUniqueId(menuOthUniqIdFundsEOD);
    SuppliesHistRepository.instance.setRemarks(buildSelectedMoneyText());
    SuppliesHistRepository.instance.setCurrentCounter(grandTotal);

    await insertToFB(context);
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
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Funds Maintenance\n",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "Bilangain ang kasalukuyang funds\n",
                  style: TextStyle(
                    fontSize: 10, // 👈 smaller
                  ),
                ),
                TextSpan(
                  text: "tuwing 9am / 12nn / 7pm",
                  style: TextStyle(
                    fontSize: 10, // 👈 smaller
                  ),
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
                    countBills(setState),
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
                });
                Navigator.pop(context); // close popup
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () async {
                saveButtonProcessEOD();
                setState(() {
                  resetAllQty();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      });
    },
  );
}
