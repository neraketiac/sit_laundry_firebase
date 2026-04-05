import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/features/employees/models/coveragerecordmodel.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/services/database_coverage.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';

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
        child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

Widget _buildDayCell(
  int day,
  DateTime date,
  DaySelection d,
  bool isPastWeek,
  bool isToday,
  bool isLocked,
  StateSetter setState,
  Color? overrideColor,
) {
  final color = overrideColor ??
      (isPastWeek
          ? Colors.grey.shade600
          : isToday
              ? Colors.amber.shade100
              : Colors.blue.shade50);

  return Container(
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      children: [
        Text('$day', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: d.a,
              activeColor: Colors.green,
              onChanged: isLocked ? null : (v) => setState(() => d.a = v ?? false),
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
            Checkbox(
              value: d.b,
              activeColor: Colors.green,
              onChanged: isLocked ? null : (v) => setState(() => d.b = v ?? false),
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
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
}

Future<Map<DateTime, DaySelection>?> showCalendarDialog(BuildContext context) {
  final selections = <DateTime, DaySelection>{};
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

  String? selectedEmp;
  bool initialized = false;
  bool isGenerating = false;
  bool isSaving = false;

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
      bool am = false, pm = false;
      switch (r.absent) {
        case 0: am = true; pm = true; break;
        case 1: pm = true; break;
        case 2: am = true; break;
        case 3: am = false; pm = false; break;
      }
      selections[date] = DaySelection(a: am, b: pm);
    }
    dialogSetState();
  }

  return showDialog<Map<DateTime, DaySelection>>(
    context: context,
    builder: (dialogContext) {
      final size = MediaQuery.of(context).size;
      final bool isSmall = size.width < 500;

      return StatefulBuilder(
        builder: (sfContext, setState) {
          final firstDay = DateTime(month.year, month.month, 1);
          final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
          final offset = firstDay.weekday % 7;

          if (!initialized) {
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
                        onPressed: () => setState(() => month = DateTime(month.year, month.month - 1)),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            DateFormat('MMMM yyyy').format(month),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() => month = DateTime(month.year, month.month + 1)),
                      ),
                    ],
                  ),

                  /// WEEKDAYS
                  const Row(
                    children: [
                      _W('Sun'), _W('Mon'), _W('Tue'), _W('Wed'),
                      _W('Thu'), _W('Fri'), _W('Sat'),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// CALENDAR
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(4),
                      itemCount: ((daysInMonth + offset) / 7).ceil() * 7,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (_, i) {
                        if (i < offset) {
                          final daysInPrevMonth = DateTime(month.year, month.month, 0).day;
                          final day = daysInPrevMonth - offset + i + 1;
                          final date = DateTime(month.year, month.month - 1, day);
                          final now = DateTime.now();
                          final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
                          final isPastWeek = date.isBefore(startOfWeek);
                          final isLocked = !isAdmin && isPastWeek;
                          selections.putIfAbsent(date, () => DaySelection());
                          return _buildDayCell(day, date, selections[date]!, isPastWeek, false, isLocked, setState, Colors.grey.shade300);
                        }

                        final day = i - offset + 1;

                        if (day > daysInMonth) {
                          final nextDay = day - daysInMonth;
                          final date = DateTime(month.year, month.month + 1, nextDay);
                          final now = DateTime.now();
                          final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
                          final isPastWeek = date.isBefore(startOfWeek);
                          final isLocked = !isAdmin && isPastWeek;
                          selections.putIfAbsent(date, () => DaySelection());
                          return _buildDayCell(nextDay, date, selections[date]!, isPastWeek, false, isLocked, setState, Colors.grey.shade300);
                        }

                        final date = DateTime(month.year, month.month, day);
                        final now = DateTime.now();
                        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
                        final isPastWeek = date.isBefore(startOfWeek);
                        final isLocked = !isAdmin && isPastWeek;
                        final today = DateTime.now();
                        final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
                        selections.putIfAbsent(date, () => DaySelection());
                        return _buildDayCell(day, date, selections[date]!, isPastWeek, isToday, isLocked, setState, null);
                      },
                    ),
                  ),

                  /// DROPDOWN + GENERATE (generate only for admin)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: (selectedEmp == null || selectedEmp == 'ALL' ||
                                    !mapEmpId.keys.where((k) => k != '1313#' && k != '1616#').contains(selectedEmp))
                                ? null
                                : selectedEmp,
                            hint: const Text('Select Employee'),
                            items: [
                              if (isAdmin)
                                const DropdownMenuItem(value: 'ALL', child: Text('All')),
                              ...mapEmpId.entries
                                  .where((e) => e.key != '1313#' && e.key != '1616#')
                                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
                            ],
                            onChanged: (v) async {
                              if (v == 'ALL') {
                                setState(() => selectedEmp = 'ALL');
                                return;
                              }
                              await queryDropDown(() => setState(() {}), v!);
                              setState(() {});
                            },
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: isGenerating
                                ? null
                                : () async {
                                    if (selectedEmp == null) return;
                                    final empKeys = selectedEmp == 'ALL'
                                        ? mapEmpId.keys.where((k) => k != '1313#' && k != '1616#').toList()
                                        : [selectedEmp!];

                                    if (!sfContext.mounted) return;
                                    setState(() => isGenerating = true);

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const PopScope(
                                        canPop: false,
                                        child: Center(
                                          child: Card(
                                            child: Padding(
                                              padding: EdgeInsets.all(24),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CircularProgressIndicator(),
                                                  SizedBox(height: 12),
                                                  Text('Generating...'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );

                                    final firestore = FirebaseFirestore.instance;
                                    final List<CoverageRecordModel> allChangedDays = [];

                                    for (final empKey in empKeys) {
                                      final empName = mapEmpId[empKey]!;
                                      final rate = mapEmpIdRates[empKey] ?? 0;
                                      final db = DatabaseCoverage();
                                      final existing = await db.getAll(empName);

                                      final Set<int> alreadyGenerated = {
                                        for (var r in existing) if (r.isGenerated) r.coverageDate
                                      };
                                      final Map<int, int> firestoreMap = {
                                        for (var r in existing) r.coverageDate: r.absent
                                      };

                                      final sourceEntries = selectedEmp == 'ALL'
                                          ? existing.map((r) {
                                              final ds = r.coverageDate.toString();
                                              final date = DateTime(
                                                int.parse(ds.substring(0, 4)),
                                                int.parse(ds.substring(4, 6)),
                                                int.parse(ds.substring(6, 8)),
                                              );
                                              bool am = false, pm = false;
                                              switch (r.absent) {
                                                case 0: am = true; pm = true; break;
                                                case 1: pm = true; break;
                                                case 2: am = true; break;
                                              }
                                              return MapEntry(date, DaySelection(a: am, b: pm));
                                            }).toList()
                                          : selections.entries.toList();

                                      final batch = firestore.batch();
                                      final List<CoverageRecordModel> changedDays = [];

                                      for (final entry in sourceEntries) {
                                        final date = entry.key;
                                        final sel = entry.value;

                                        int absent;
                                        if (sel.a && sel.b) absent = 0;
                                        else if (!sel.a && sel.b) absent = 1;
                                        else if (sel.a && !sel.b) absent = 2;
                                        else absent = 3;

                                        final coverageDate = int.parse(DateFormat('yyyyMMdd').format(date));
                                        final oldAbsent = firestoreMap[coverageDate];
                                        final wasGenerated = alreadyGenerated.contains(coverageDate);

                                        if (absent == 3 && oldAbsent == null) continue;
                                        if (absent == 3 && !wasGenerated) continue;
                                        if (wasGenerated && oldAbsent == absent) continue;

                                        int previousEarned = 0;
                                        if (wasGenerated && oldAbsent != null) {
                                          if (oldAbsent == 0) previousEarned = rate;
                                          else if (oldAbsent == 1 || oldAbsent == 2) previousEarned = rate ~/ 2;
                                        }

                                        int newEarned = 0;
                                        if (absent == 0) newEarned = rate;
                                        else if (absent == 1 || absent == 2) newEarned = rate ~/ 2;

                                        final earned = newEarned - previousEarned;

                                        final record = CoverageRecordModel(
                                          docId: '',
                                          coverageDate: coverageDate,
                                          amountEarned: earned,
                                          absent: absent,
                                          empId: empName,
                                          remarks: '',
                                          isGenerated: absent != 3,
                                        );

                                        changedDays.add(record);
                                        batch.set(
                                          firestore.collection('coverage_records').doc(empName).collection('dates').doc(coverageDate.toString()),
                                          record.toMap(),
                                        );
                                      }

                                      if (changedDays.isNotEmpty) {
                                        await batch.commit();
                                        for (final r in changedDays) {
                                          if (r.amountEarned != 0) {
                                            final ds = r.coverageDate.toString();
                                            final coverageDateTime = DateTime(
                                              int.parse(ds.substring(0, 4)),
                                              int.parse(ds.substring(4, 6)),
                                              int.parse(ds.substring(6, 8)),
                                            );
                                            SuppliesHistRepository.instance.clear();
                                            SuppliesHistRepository.instance.setItemName(getItemNameOnly(menuOthCashInOutFunds, menuOthSalaryPayment));
                                            SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
                                            SuppliesHistRepository.instance.setItemUniqueId(menuOthSalaryPayment);
                                            SuppliesHistRepository.instance.setRemarks('Auto generated ${r.coverageDate}${r.amountEarned < 0 ? ' reverted' : ''}');
                                            SuppliesHistRepository.instance.setCurrentCounter(r.amountEarned);
                                            SuppliesHistRepository.instance.setCustomerName(r.empId);
                                            SuppliesHistRepository.instance.setEmpId(empNameToId[r.empId]!);
                                            await setSuppliesRepository(context, autoSalaryDate: Timestamp.fromDate(coverageDateTime));
                                          }
                                        }
                                        allChangedDays.addAll(changedDays);
                                      }
                                    }

                                    Navigator.of(context, rootNavigator: true).pop();
                                    if (sfContext.mounted) setState(() => isGenerating = false);

                                    if (allChangedDays.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No changes detected')),
                                      );
                                      return;
                                    }

                                    final affectedDays = allChangedDays.where((r) => r.amountEarned != 0).toList();
                                    final formattedDays = affectedDays.map((r) {
                                      final ds = r.coverageDate.toString();
                                      return '${r.empId} ${DateFormat('MMM dd').format(DateTime(
                                        int.parse(ds.substring(0, 4)),
                                        int.parse(ds.substring(4, 6)),
                                        int.parse(ds.substring(6, 8)),
                                      ))}';
                                    }).join('\n');

                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Done'),
                                        content: SingleChildScrollView(
                                          child: Text('Updated ${affectedDays.length} day(s):\n$formattedDays'),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            child: isGenerating
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Generate'),
                          ),
                        ],
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
                            onPressed: () => Navigator.pop(sfContext),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    final empId = selectedEmp;
                                    if (empId == null || empId == 'ALL') {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please select an employee')),
                                      );
                                      return;
                                    }

                                    if (sfContext.mounted) setState(() => isSaving = true);

                                    final empName = mapEmpId[empId]!;
                                    final db = DatabaseCoverage();
                                    final existing = await db.getAll(empName);
                                    final existingDates = {for (var r in existing) r.coverageDate};
                                    final toSave = <CoverageRecordModel>[];

                                    for (final entry in selections.entries) {
                                      final date = entry.key;
                                      final sel = entry.value;
                                      final coverageDate = int.parse(DateFormat('yyyyMMdd').format(date));

                                      if (!sel.a && !sel.b && !existingDates.contains(coverageDate)) continue;

                                      int absent;
                                      if (sel.a && sel.b) absent = 0;
                                      else if (!sel.a && sel.b) absent = 1;
                                      else if (sel.a && !sel.b) absent = 2;
                                      else absent = 3;

                                      toSave.add(CoverageRecordModel(
                                        docId: '',
                                        coverageDate: coverageDate,
                                        amountEarned: 0,
                                        absent: absent,
                                        empId: empName,
                                        remarks: '',
                                        isGenerated: false,
                                      ));
                                    }

                                    if (toSave.isEmpty) {
                                      if (sfContext.mounted) setState(() => isSaving = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Nothing to save')),
                                      );
                                      return;
                                    }

                                    await db.batchSave(empName, toSave);

                                    if (sfContext.mounted) setState(() => isSaving = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Saved ${toSave.length} day(s)')),
                                    );
                                  },
                            child: isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Save'),
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
