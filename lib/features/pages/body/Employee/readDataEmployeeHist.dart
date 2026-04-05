import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/features/employees/models/employeemodel.dart';
import 'package:laundry_firebase/core/services/database_employee_hist.dart';

Widget readDataEmployeeHist() => const _EmployeeHistWidget();

class _EmployeeHistWidget extends StatefulWidget {
  const _EmployeeHistWidget();

  @override
  State<_EmployeeHistWidget> createState() => _EmployeeHistWidgetState();
}

class _EmployeeHistWidgetState extends State<_EmployeeHistWidget> {
  String? _selectedEmpId; // null = ALL

  Widget _buildRow(EmployeeModel eM) {
    final bNegative = eM.currentCounter < 0;
    final bNegativePCF = eM.currentStocks < 0;
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        border: const Border(
          bottom: BorderSide(color: Color.fromARGB(255, 89, 89, 89), width: 0.6),
        ),
      ),
      child: Row(
        children: [
          Text(
            DateFormat('MM/dd hh:mm a').format(eM.logDate.toDate()),
            style: const TextStyle(fontSize: 9, color: Color.fromARGB(255, 68, 68, 68)),
          ),
          const SizedBox(width: 4),
          Text(
            '₱${value.format(eM.currentCounter)}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: bNegative
                  ? const Color.fromARGB(255, 185, 57, 48)
                  : const Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${eM.itemName} ${ifMenuUniqueIsCashInEmp(eM) ? 'to' : 'by'} ${eM.empName} : ${eM.remarks}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
            ),
          ),
          Text(
            eM.logBy,
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.grey[800]),
          ),
          Text(
            'pCF ₱${value.format(eM.currentStocks)}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: bNegativePCF
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
    final db = DatabaseEmployeeHist();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('👤📊 EMPLOYEE HISTORY', style: TextStyle(color: Colors.white)),
          ],
        ),
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: DropdownButtonFormField<String>(
              value: _selectedEmpId,
              hint: const Text('All', style: TextStyle(fontSize: 12)),
              isDense: true,
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...mapEmpId.entries
                    .where((e) => e.key != '1313#' && e.key != '1616#')
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
              ],
              onChanged: (v) => setState(() => _selectedEmpId = v),
            ),
          ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: StreamBuilder(
            stream: db.getEmployeeHistory(filterEmpId: _selectedEmpId),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final employees = snapshot.data!.docs
                  .map((doc) => doc.data() as EmployeeModel)
                  .toList();

              if (employees.isEmpty) return const Center(child: Text('No employee history'));

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: employees.length,
                itemBuilder: (context, index) => SizedBox(
                  height: 24,
                  child: _buildRow(employees[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
