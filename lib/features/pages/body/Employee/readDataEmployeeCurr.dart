import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/employees/models/employeemodel.dart';
import 'package:laundry_firebase/core/services/database_employee_current.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

Widget readDataEmployeeCurr() => const _EmployeeCurrWidget();

class _EmployeeCurrWidget extends StatefulWidget {
  const _EmployeeCurrWidget();

  @override
  State<_EmployeeCurrWidget> createState() => _EmployeeCurrWidgetState();
}

class _EmployeeCurrWidgetState extends State<_EmployeeCurrWidget> {
  Widget _buildRow(BuildContext context, EmployeeModel eM) {
    final bNegative = eM.currentStocks < 0;
    return Container(
      height: 22,
      color: cSalaryCurrent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            ' ${eM.empName}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          if (isAdmin)
            Text(
              eM.empId,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          Text(
            '₱ ${value.format(eM.currentStocks)}  ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: bNegative
                  ? const Color.fromARGB(255, 185, 57, 48)
                  : const Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = DatabaseEmployeeCurrent();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: db.get(),
          builder: (context, snapshot) {
            final listEM = snapshot.data?.docs ?? [];
            if (listEM.isEmpty) return const SizedBox();

            final rows = <TableRow>[
              const TableRow(
                decoration: BoxDecoration(color: Colors.lightBlueAccent),
                children: [
                  Text('Current Balance', style: TextStyle(fontSize: 10)),
                ],
              ),
              ...listEM.map((doc) {
                final eM = doc.data() as EmployeeModel;
                return TableRow(
                  decoration: const BoxDecoration(color: Colors.black),
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
