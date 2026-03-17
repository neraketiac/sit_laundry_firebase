//########################### Supplies History ###############################
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/services/database_funds_history.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

/// STATE
List<SuppliesModelHist> sortedSuppliesHistory = [];
DocumentSnapshot? lastSuppliesHistoryDoc;
bool loadingSuppliesHistory = false;
bool hasMoreSuppliesHistory = true;

final DatabaseFundsHist dbFundsHist = DatabaseFundsHist();

/// LOAD PAGE
Future<void> loadMoreSuppliesHistory(VoidCallback refresh) async {
  if (loadingSuppliesHistory || !hasMoreSuppliesHistory) return;

  loadingSuppliesHistory = true;

  final snapshot = await dbFundsHist.getSuppliesHistoryPaginated(false, lastDoc: lastSuppliesHistoryDoc);

  if (snapshot.docs.isEmpty) {
    hasMoreSuppliesHistory = false;
  } else {
    final supplies = snapshot.docs.map((doc) {
      return doc.data() as SuppliesModelHist;
    }).toList();

    sortedSuppliesHistory.addAll(supplies);
    lastSuppliesHistoryDoc = snapshot.docs.last;
  }

  loadingSuppliesHistory = false;
  refresh();
}

Widget _buildSupplyRow(SuppliesModelHist sMH) {
  bool bNegative = (sMH.currentCounter < 0 ? true : false);
  bool bNegativePCF = (sMH.currentStocks < 0 ? true : false);

  if (ifMenuUniqueIsEOD(sMH)) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: cFundsEOD,
        border: Border(
          bottom: BorderSide(
            color: const Color.fromARGB(255, 89, 89, 89),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            DateFormat('MM/dd hh:mm a').format(sMH.logDate.toDate()),
            style: TextStyle(
              fontSize: 9,
              color: const Color.fromARGB(255, 68, 68, 68),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "₱${value.format(sMH.currentCounter)}",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: (bNegative
                  ? Color.fromARGB(255, 185, 57, 48)
                  : Color(0xFF0D47A1)),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              "${sMH.itemName} by ${sMH.empId} : ${sMH.remarks}",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),
          ),
          Text(
            " pCF ₱${value.format(sMH.currentStocks)}",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: (bNegativePCF
                  ? Color.fromARGB(255, 185, 57, 48)
                  : Color(0xFF0D47A1)),
            ),
          ),
        ],
      ),
    );
  }

  return Container(
    height: 22,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: Colors.grey[400],
      border: Border(
        bottom: BorderSide(
          color: const Color.fromARGB(255, 89, 89, 89),
          width: 0.6,
        ),
      ),
    ),
    child: Row(
      children: [
        Text(
          DateFormat('MM/dd hh:mm a').format(sMH.logDate.toDate()),
          style: TextStyle(
            fontSize: 9,
            color: const Color.fromARGB(255, 68, 68, 68),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          "₱${value.format(sMH.currentCounter)}",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: (bNegative
                ? Color.fromARGB(255, 185, 57, 48)
                : Color(0xFF0D47A1)),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            "${sMH.itemName} ${ifMenuUniqueIsCashIn(sMH) ? 'to' : 'by'} ${sMH.customerName} : ${sMH.remarks}",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
        ),
        Text(
          sMH.empId,
          style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800]),
        ),
        Text(
          "pCF ₱${value.format(sMH.currentStocks)}",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: (bNegativePCF
                ? Color.fromARGB(255, 185, 57, 48)
                : Color(0xFF0D47A1)),
          ),
        ),
      ],
    ),
  );
}

Widget readDataSuppliesHistory() {
  return StatefulBuilder(
    builder: (context, setState) {
      /// load first page
      if (sortedSuppliesHistory.isEmpty && !loadingSuppliesHistory) {
        loadMoreSuppliesHistory(() => setState(() {}));
      }

      if (sortedSuppliesHistory.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("📊💰 FUNDS HISTORY", style: TextStyle(color: Colors.white)),
            ],
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sortedSuppliesHistory.length + (hasMoreSuppliesHistory ? 1 : 0),
              itemBuilder: (context, index) {
                /// pagination trigger
                if (index == sortedSuppliesHistory.length - 1) {
                  loadMoreSuppliesHistory(() => setState(() {}));
                }

                if (index == sortedSuppliesHistory.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                }

                final sMH = sortedSuppliesHistory[index];
                return SizedBox(
                  height: 24,
                  child: _buildSupplyRow(sMH),
                );
              },
            ),
          ),
          if (loadingSuppliesHistory)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),
        ],
      );
    },
  );
}
