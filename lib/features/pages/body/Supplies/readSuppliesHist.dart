//########################### Supplies History ###############################
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/services/database_funds_history.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

final DatabaseFundsHist dbFundsHist = DatabaseFundsHist();

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
  return Builder(
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("📊💰 FUNDS HISTORY", style: TextStyle(color: Colors.white)),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: StreamBuilder(
              stream: dbFundsHist.getSuppliesHistory(false),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final supplies =
                    docs.map((doc) => doc.data() as SuppliesModelHist).toList();

                if (supplies.isEmpty) {
                  return const Center(child: Text('No supplies history'));
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: supplies.length,
                  itemBuilder: (context, index) {
                    final sMH = supplies[index];
                    return SizedBox(
                      height: 24,
                      child: _buildSupplyRow(sMH),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
