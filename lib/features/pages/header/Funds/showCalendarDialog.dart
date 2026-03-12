import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/employees/models/coveragerecordmodel.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/services/database_coverage.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

class DaySelection {
  bool a;
  bool b;
  DaySelection({this.a = false, this.b = false});
}

class _W extends StatelessWidget {
  final String t;
  const _W(this.t);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          t,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

Future<Map<DateTime, DaySelection>?> showCalendarDialog(BuildContext context) {
  final selections = <DateTime, DaySelection>{};
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

  String? selectedEmp;
  bool initialized = false;

  Future<void> queryDropDown(VoidCallback dialogSetState, String v) async {
    selectedEmp = v;

    final empName = mapEmpId[v]!;
    final db = DatabaseCoverage();

    final records = await db.getAll(empName);

    selections.clear();

    for (final r in records) {
      final dateStr = r.coverageDate.toString();

      final date = DateTime(
        int.parse(dateStr.substring(0, 4)),
        int.parse(dateStr.substring(4, 6)),
        int.parse(dateStr.substring(6, 8)),
      );

      bool am = false;
      bool pm = false;

      switch (r.absent) {
        case 0:
          am = true;
          pm = true;
          break;
        case 1:
          pm = true;
          break;
        case 2:
          am = true;
          break;
        case 3:
          am = false;
          pm = false;
          break;
      }

      selections[date] = DaySelection(a: am, b: pm);
    }

    dialogSetState();
  }

  return showDialog<Map<DateTime, DaySelection>>(
    context: context,
    builder: (_) {
      final size = MediaQuery.of(context).size;
      final bool isSmall = size.width < 500;

      return StatefulBuilder(
        builder: (context, setState) {
          final firstDay = DateTime(month.year, month.month, 1);
          final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
          final offset = firstDay.weekday % 7;
          bool isGenerating = false;

          if (!isAdmin && !initialized) {
            initialized = true;

            Future.microtask(() {
              queryDropDown(() => setState(() {}), empNameToId[empIdGlobal]!);
            });
          }
          return Dialog(
            insetPadding: isSmall ? EdgeInsets.zero : const EdgeInsets.all(24),
            child: SizedBox(
              width: isSmall ? double.infinity : 460,
              height: isSmall ? size.height : size.height * 0.75,
              child: Column(
                children: [
                  /// HEADER
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(
                          () => month = DateTime(month.year, month.month - 1),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            DateFormat('MMMM yyyy').format(month),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(
                          () => month = DateTime(month.year, month.month + 1),
                        ),
                      ),
                    ],
                  ),

                  /// WEEKDAYS
                  const Row(
                    children: [
                      _W('Sun'),
                      _W('Mon'),
                      _W('Tue'),
                      _W('Wed'),
                      _W('Thu'),
                      _W('Fri'),
                      _W('Sat'),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// CALENDAR
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(4),
                      itemCount: daysInMonth + offset,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (_, i) {
                        if (i < offset) return const SizedBox();

                        final day = i - offset + 1;
                        final date = DateTime(month.year, month.month, day);

                        final now = DateTime.now();
                        final startOfWeek =
                            DateTime(now.year, now.month, now.day)
                                .subtract(Duration(days: now.weekday - 1));

                        final isPastWeek = date.isBefore(startOfWeek);

                        /// admins can bypass lock
                        final isLocked = !isAdmin && isPastWeek;

                        final today = DateTime.now();
                        final isToday = date.year == today.year &&
                            date.month == today.month &&
                            date.day == today.day;

                        selections.putIfAbsent(date, () => DaySelection());
                        final d = selections[date]!;

                        return Container(
                          decoration: BoxDecoration(
                            color: isPastWeek
                                ? Colors.grey.shade600
                                : isToday
                                    ? Colors.amber.shade100
                                    : Colors.blue.shade50,
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$day',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: d.a,
                                    activeColor: Colors.green,
                                    onChanged: isLocked
                                        ? null
                                        : (v) =>
                                            setState(() => d.a = v ?? false),
                                    visualDensity: const VisualDensity(
                                        horizontal: -4, vertical: -4),
                                  ),
                                  Checkbox(
                                    value: d.b,
                                    activeColor: Colors.green,
                                    onChanged: isLocked
                                        ? null
                                        : (v) =>
                                            setState(() => d.b = v ?? false),
                                    visualDensity: const VisualDensity(
                                        horizontal: -4, vertical: -4),
                                  ),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('am'),
                                  SizedBox(width: 5),
                                  Text('pm'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  /// 🔹 DROPDOWN + GENERATE
                  if (isAdmin)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedEmp,
                              hint: const Text("Select Employee"),
                              items: mapEmpId.entries
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) async {
                                queryDropDown(() => setState(() {}), v!);

                                // setState(() {
                                //   selectedEmp = v;
                                // });

                                // if (v == null) return;

                                // final empName = mapEmpId[v]!;
                                // final db = DatabaseCoverage();

                                // final records = await db.getAll(empName);

                                // setState(() {
                                //   selections.clear();

                                //   for (final r in records) {
                                //     final dateStr = r.coverageDate.toString();

                                //     final date = DateTime(
                                //       int.parse(dateStr.substring(0, 4)),
                                //       int.parse(dateStr.substring(4, 6)),
                                //       int.parse(dateStr.substring(6, 8)),
                                //     );

                                //     bool am = false;
                                //     bool pm = false;

                                //     switch (r.absent) {
                                //       case 0:
                                //         am = true;
                                //         pm = true;
                                //         break;
                                //       case 1:
                                //         pm = true;
                                //         break;
                                //       case 2:
                                //         am = true;
                                //         break;
                                //       case 3:
                                //         am = false;
                                //         pm = false;
                                //         break;
                                //     }

                                //     selections[date] =
                                //         DaySelection(a: am, b: pm);
                                //   }
                                // });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: isGenerating
                                ? null
                                : () async {
                                    if (selectedEmp == null) return;

                                    if (!context.mounted) return;

                                    setState(() {
                                      isGenerating = true;
                                    });

                                    final rate =
                                        mapEmpIdRates[selectedEmp] ?? 0;
                                    final empName = mapEmpId[selectedEmp]!;

                                    final db = DatabaseCoverage();
                                    final firestore =
                                        FirebaseFirestore.instance;

                                    /// Load existing records
                                    final existing = await db.getAll(empName);

                                    final Map<int, int> firestoreMap = {
                                      for (var r in existing)
                                        r.coverageDate: r.absent
                                    };

                                    final batch = firestore.batch();

                                    List<CoverageRecordModel> changedDays = [];

                                    for (final entry in selections.entries) {
                                      final date = entry.key;
                                      final sel = entry.value;

                                      int absent = 0;

                                      if (sel.a && sel.b) {
                                        absent = 0;
                                      } else if (!sel.a && sel.b) {
                                        absent = 1;
                                      } else if (sel.a && !sel.b) {
                                        absent = 2;
                                      } else {
                                        absent = 3;
                                      }

                                      final coverageDate = int.parse(
                                          DateFormat('yyyyMMdd').format(date));

                                      final oldAbsent =
                                          firestoreMap[coverageDate];

                                      /// skip if nothing changed
                                      if (oldAbsent == absent) continue;

                                      int earned = 0;

                                      /// normal earnings
                                      if (absent == 0) {
                                        earned = rate;
                                      } else if (absent == 1 || absent == 2) {
                                        earned = rate ~/ 2;
                                      }

                                      /// REVERSAL LOGIC
                                      if (oldAbsent != null &&
                                          absent == 3 &&
                                          oldAbsent != 3) {
                                        int oldEarned = 0;

                                        if (oldAbsent == 0) {
                                          oldEarned = rate;
                                        } else if (oldAbsent == 1 ||
                                            oldAbsent == 2) {
                                          oldEarned = rate ~/ 2;
                                        }

                                        earned = -oldEarned;
                                      }

                                      final record = CoverageRecordModel(
                                        docId: '',
                                        coverageDate: coverageDate,
                                        amountEarned: earned,
                                        absent: absent,
                                        empId: empName,
                                        remarks: '',
                                      );

                                      changedDays.add(record);

                                      final docRef = firestore
                                          .collection('coverage_records')
                                          .doc(empName)
                                          .collection('dates')
                                          .doc(coverageDate.toString());

                                      batch.set(docRef, record.toMap());
                                    }

                                    /// No changes
                                    if (changedDays.isEmpty) {
                                      if (!context.mounted) return;
                                      setState(() {
                                        isGenerating = false;
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text("No changes detected"),
                                        ),
                                      );

                                      return;
                                    }

                                    /// Commit batch
                                    await batch.commit();

                                    /// Log transactions
                                    for (final r in changedDays) {
                                      if (r.amountEarned != 0) {
                                        SuppliesHistRepository.instance
                                            .setItemName(getItemNameOnly(
                                                menuOthCashInOutFunds,
                                                menuOthSalaryPayment));

                                        SuppliesHistRepository.instance
                                            .setItemId(menuOthCashInOutFunds);
                                        SuppliesHistRepository.instance
                                            .setItemUniqueId(
                                                menuOthSalaryPayment);
                                        SuppliesHistRepository.instance.setRemarks(
                                            "Auto generated ${r.coverageDate} ${r.amountEarned < 0 ? ' reverted' : ''}");

                                        SuppliesHistRepository.instance
                                            .setCurrentCounter(r.amountEarned);

                                        SuppliesHistRepository.instance
                                            .setCustomerName(r.empId);

                                        SuppliesHistRepository.instance
                                            .setEmpId(empNameToId[r.empId]!);

                                        await setSuppliesRepository(context);
                                      }
                                    }

                                    if (!context.mounted) return;
                                    setState(() {
                                      isGenerating = false;
                                    });

                                    final formattedDays = changedDays
                                        .map((r) => DateFormat('MMM dd').format(
                                              DateTime.parse(
                                                  r.coverageDate.toString()),
                                            ))
                                        .join(", ");

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Updated ${changedDays.length} day(s): $formattedDays",
                                        ),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  },
                            child: isGenerating
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Generate"),
                          )
                        ],
                      ),
                    ),

                  /// ACTIONS
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
