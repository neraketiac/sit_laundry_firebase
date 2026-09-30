//########################### Funds Audit ###############################
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/services/database_funds_audit.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

final DatabaseFundsAudit dbFundsAudit = DatabaseFundsAudit();

Widget _buildAuditRow(SuppliesModelHist sMH) {
  bool bNegative = (sMH.currentCounter < 0 ? true : false);
  bool bNegativePCF = (sMH.currentStocks < 0 ? true : false);

  // Determine if this is Funds In transaction
  final isFundsIn = sMH.itemUniqueId == 4403;

  if (ifMenuUniqueIsEOD(sMH)) {
    // Determine if fund check was done in morning (before 12nn) or afternoon
    final logTime = sMH.logDate.toDate();
    final isMorning = logTime.hour < 12;
    final rowColor = isMorning
        ? Colors.purple.shade200 // Light purple for morning
        : cFundsEOD; // Original color for afternoon

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: rowColor,
        border: Border(
          bottom: BorderSide(
            color: const Color.fromARGB(255, 89, 89, 89),
            width: 0.6,
          ),
        ),
      ),
      child: isAdmin
          ? Row(
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
                    color: isFundsIn
                        ? const Color(0xFF0D47A1) // Blue for Funds In
                        : (bNegative
                            ? const Color.fromARGB(
                                255, 185, 57, 48) // Red for negative
                            : const Color(0xFF0D47A1)), // Blue for positive
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "${sMH.itemName} by ${sMH.empId}",
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
            )
          : Row(
              children: [
                Text(
                  DateFormat('MM/dd hh:mm a').format(sMH.logDate.toDate()),
                  style: TextStyle(
                    fontSize: 9,
                    color: const Color.fromARGB(255, 68, 68, 68),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Fund Check by ${sMH.empId}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "₱${value.format(sMH.currentStocks + sMH.currentCounter)}",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D47A1),
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
      color: isFundsIn ? Colors.green.shade100 : Colors.grey[400],
      border: Border(
        bottom: BorderSide(
          color: const Color.fromARGB(255, 89, 89, 89),
          width: 0.6,
        ),
      ),
    ),
    child: isAdmin
        ? Row(
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
                  color: isFundsIn
                      ? const Color(0xFF0D47A1) // Blue for Funds In
                      : (bNegative
                          ? const Color.fromARGB(
                              255, 185, 57, 48) // Red for negative
                          : const Color(0xFF0D47A1)), // Blue for positive
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "${sMH.itemName} ${ifMenuUniqueIsCashIn(sMH) ? 'to' : 'by'} ${sMH.customerName}",
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
          )
        : Row(
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
                  color: isFundsIn
                      ? const Color(0xFF0D47A1) // Blue for Funds In
                      : (bNegative
                          ? const Color.fromARGB(
                              255, 185, 57, 48) // Red for negative
                          : const Color(0xFF0D47A1)), // Blue for positive
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "${sMH.itemName} ${ifMenuUniqueIsCashIn(sMH) ? 'to' : 'by'} ${sMH.customerName}",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
              ),
            ],
          ),
  );
}

Widget readDataFundsAudit() {
  return const _FundsAuditList();
}

class _FundsAuditList extends StatefulWidget {
  const _FundsAuditList();

  @override
  State<_FundsAuditList> createState() => _FundsAuditListState();
}

class _FundsAuditListState extends State<_FundsAuditList> {
  final ScrollController _scroll = ScrollController();

  static const int _nonAdminLimit =
      50; // Non-admin users can only see 50 records

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    // Streams automatically update, just refresh the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📊💼 FUNDS AUDIT', style: TextStyle(color: Colors.white)),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: StreamBuilder<List<SuppliesModelHist>>(
            stream: dbFundsAudit.streamAuditHistory(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data ?? [];

              // Apply non-admin limit
              final displayItems =
                  !isAdmin ? items.take(_nonAdminLimit).toList() : items;

              if (displayItems.isEmpty) {
                return const Center(child: Text('No audit records'));
              }

              debugPrint('📊 Funds Audit Stream: ${displayItems.length} items');

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: displayItems.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 24,
                      child: _buildAuditRow(displayItems[index]),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
