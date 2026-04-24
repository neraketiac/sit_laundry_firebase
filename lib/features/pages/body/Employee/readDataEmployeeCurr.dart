import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/employees/models/employeemodel.dart';
import 'package:laundry_firebase/core/services/database_employee_current.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';
import 'package:laundry_firebase/core/utils/fs_usage_tracker.dart';

Widget readDataEmployeeCurr() => const _EmployeeCurrWidget();

class _EmployeeCurrWidget extends StatefulWidget {
  const _EmployeeCurrWidget();

  @override
  State<_EmployeeCurrWidget> createState() => _EmployeeCurrWidgetState();
}

class _EmployeeCurrWidgetState extends State<_EmployeeCurrWidget> {
  Widget _buildRow(BuildContext context, EmployeeModel eM) {
    final bNegative = eM.currentStocks < 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final rowBg = isDark ? const Color(0xFF2A2A3E) : cSalaryCurrent;
    final textColor = isDark ? Colors.white : Colors.black87;
    final amountColorPositive =
        isDark ? Colors.green.shade300 : const Color(0xFF0D47A1);
    final amountColorNegative =
        isDark ? Colors.red.shade300 : const Color.fromARGB(255, 185, 57, 48);

    return Container(
      height: 22,
      color: rowBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            ' ${eM.empName}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (isAdmin)
            Text(
              eM.empId,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          Text(
            '₱ ${value.format(eM.currentStocks)}  ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: bNegative ? amountColorNegative : amountColorPositive,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = DatabaseEmployeeCurrent();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final headerBg =
        isDark ? Colors.deepPurple.shade900 : Colors.lightBlueAccent;
    final headerText = isDark ? Colors.white : Colors.black87;
    final rowBg = isDark ? const Color(0xFF1E1E2E) : Colors.black;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: db.get(),
          builder: (context, snapshot) {
            final listEM = snapshot.data?.docs ?? [];
            if (listEM.isEmpty) return const SizedBox();
            FsUsageTracker.instance
                .track('readDataEmployeeCurr', listEM.length);

            final rows = <TableRow>[
              TableRow(
                decoration: BoxDecoration(color: headerBg),
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: headerText,
                    ),
                  ),
                ],
              ),
              ...listEM.map((doc) {
                final eM = doc.data() as EmployeeModel;
                return TableRow(
                  decoration: BoxDecoration(color: rowBg),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: _buildRow(context, eM),
                    ),
                  ],
                );
              }),
            ];

            return Table(children: rows);
          },
        ),
      ],
    );
  }
}
