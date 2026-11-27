import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/features/employees/models/coveragerecordmodel.dart';
import 'package:laundry_firebase/features/employees/models/employeemodel.dart';
import 'package:laundry_firebase/features/employees/models/task_rate_model.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/services/database_coverage.dart';
import 'package:laundry_firebase/core/services/database_employee_current.dart';
import 'package:laundry_firebase/core/services/task_rates_service.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

class TaskItem {
  int taskId;
  bool selected;
  int amount;

  TaskItem({
    required this.taskId,
    this.selected = false,
    this.amount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'selected': selected,
      'amount': amount,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      taskId: map['taskId'] ?? 0,
      selected: map['selected'] ?? false,
      amount: map['amount'] ?? 0,
    );
  }
}

class DaySelection {
  bool a;
  bool b;
  Map<int, TaskItem> tasks;

  DaySelection({
    this.a = false,
    this.b = false,
    Map<int, TaskItem>? tasks,
  }) : tasks = tasks ?? {};
}

class _W extends StatelessWidget {
  final String t;
  const _W(this.t);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(t,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// Helper function to get task label
String _getTaskLabel(int taskId) {
  const labels = {
    1: 'Sundo c-anne sa school',
    2: 'Sundo caito sa school',
    3: 'Hatid c-anne kay titser noreen',
    4: 'Hatid caito kay titser noreen',
    5: 'Sundo c-anne kay titser noreen',
    6: 'Sundo caito kay titser noreen',
    7: 'Pickup/Delivery',
  };
  return labels[taskId] ?? 'Task $taskId';
}

// Task Tracking Dialog
Future<void> _showTaskTrackingDialog(
  BuildContext context,
  DaySelection daySelection,
  Map<int, TaskRate> currentRates,
  StateSetter setState,
  bool isLocked,
) async {
  Map<int, TaskItem> tempTasks = Map.from(daySelection.tasks);

  // Initialize any missing tasks
  for (int i = 1; i <= 7; i++) {
    tempTasks.putIfAbsent(i, () => TaskItem(taskId: i));
  }

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (innerContext, innerSetState) {
          return Dialog(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Daily Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(7, (index) {
                        final taskId = index + 1;
                        final task = tempTasks[taskId]!;
                        final rate = currentRates[taskId]?.rate ?? 0;
                        final label = _getTaskLabel(taskId);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Checkbox(
                                value: task.selected,
                                onChanged: isLocked
                                    ? null
                                    : (value) {
                                        innerSetState(() {
                                          if (value == true) {
                                            // Fetch current rate when checked
                                            task.selected = true;
                                            task.amount = rate;
                                          } else {
                                            task.selected = false;
                                            task.amount = 0;
                                          }
                                        });
                                      },
                              ),
                              Expanded(
                                child: Text(label),
                              ),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  enabled: false,
                                  textAlign: TextAlign.right,
                                  controller: TextEditingController(
                                    text: task.selected
                                        ? task.amount.toString()
                                        : '',
                                  ),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  // Update the day selection with temporary tasks
  setState(() {
    daySelection.tasks = tempTasks;
  });
}

// Task Rates Dialog (Admin only)
Future<void> _showTaskRatesDialog(
  BuildContext context,
  Map<int, TaskRate> currentRates,
) async {
  // Ensure rates are loaded
  Map<int, TaskRate> ratesToEdit = currentRates.isNotEmpty
      ? currentRates
      : TaskRatesService.getDefaultRates();

  final tempRates = Map<int, int>.from(
    ratesToEdit.map((k, v) => MapEntry(k, v.rate)),
  );

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (innerContext, innerSetState) {
          return Dialog(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Task Default Rates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(7, (index) {
                        final taskId = index + 1;
                        final label = _getTaskLabel(taskId);
                        final controller = TextEditingController(
                          text: tempRates[taskId]!.toString(),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  label,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 10),
                                    hintText: '0',
                                  ),
                                  onChanged: (value) {
                                    tempRates[taskId] =
                                        int.tryParse(value) ?? 0;
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                final service = TaskRatesService();
                                for (int i = 1; i <= 7; i++) {
                                  final oldRate = ratesToEdit[i]?.rate ?? 0;
                                  if (tempRates[i] != oldRate) {
                                    await service.updateTaskRate(
                                        i, tempRates[i]!);
                                  }
                                }
                                Navigator.pop(dialogContext);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error saving rates: $e'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
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
  VoidCallback? onTaskButtonPressed,
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
        Text('$day',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: d.a,
              activeColor: Colors.green,
              onChanged:
                  isLocked ? null : (v) => setState(() => d.a = v ?? false),
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
            Checkbox(
              value: d.b,
              activeColor: Colors.green,
              onChanged:
                  isLocked ? null : (v) => setState(() => d.b = v ?? false),
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
        // Task tracking button
        SizedBox(
          height: 20,
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.local_shipping,
                size: 14,
                color: (isLocked || onTaskButtonPressed == null)
                    ? Colors.grey
                    : Colors.blue,
              ),
              onPressed: onTaskButtonPressed,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ),
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
  Map<int, TaskRate> currentRates = {};
  bool ratesLoaded = false;

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

      // Initialize tasks from coverage record
      final daySelection = DaySelection(a: am, b: pm);
      if (r.tasks != null) {
        for (int i = 1; i <= 7; i++) {
          final taskData = r.tasks![i.toString()];
          if (taskData != null) {
            daySelection.tasks[i] = TaskItem(
              taskId: i,
              selected: taskData['selected'] ?? false,
              amount: taskData['amount'] ?? 0,
            );
          }
        }
      }
      selections[date] = daySelection;
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
            Future.microtask(() async {
              queryDropDown(() => setState(() {}), empNameToId[empIdGlobal]!);
              // Load task rates
              if (!ratesLoaded) {
                ratesLoaded = true;
                final service = TaskRatesService();

                // Initialize default rates if they don't exist
                try {
                  await service.initializeDefaultRates();
                } catch (e) {
                  print('Error initializing rates: $e');
                }

                final rates = await service.loadAllTaskRates();
                setState(() {
                  currentRates = rates;
                });
              }
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
                        onPressed: () => setState(() =>
                            month = DateTime(month.year, month.month - 1)),
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
                        onPressed: () => setState(() =>
                            month = DateTime(month.year, month.month + 1)),
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
                      itemCount: ((daysInMonth + offset) / 7).ceil() * 7,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (_, i) {
                        if (i < offset) {
                          final daysInPrevMonth =
                              DateTime(month.year, month.month, 0).day;
                          final day = daysInPrevMonth - offset + i + 1;
                          final date =
                              DateTime(month.year, month.month - 1, day);
                          final now = DateTime.now();
                          final startOfWeek =
                              DateTime(now.year, now.month, now.day)
                                  .subtract(Duration(days: now.weekday - 1));
                          final isPastWeek = date.isBefore(startOfWeek);
                          final isLocked = !isAdmin && isPastWeek;
                          selections.putIfAbsent(date, () => DaySelection());
                          return _buildDayCell(
                            day,
                            date,
                            selections[date]!,
                            isPastWeek,
                            false,
                            isLocked,
                            setState,
                            Colors.grey.shade300,
                            selectedEmp == null || selectedEmp == 'ALL'
                                ? null
                                : () => _showTaskTrackingDialog(
                                      context,
                                      selections[date]!,
                                      currentRates,
                                      setState,
                                      isLocked,
                                    ),
                          );
                        }

                        final day = i - offset + 1;

                        if (day > daysInMonth) {
                          final nextDay = day - daysInMonth;
                          final date =
                              DateTime(month.year, month.month + 1, nextDay);
                          final now = DateTime.now();
                          final startOfWeek =
                              DateTime(now.year, now.month, now.day)
                                  .subtract(Duration(days: now.weekday - 1));
                          final isPastWeek = date.isBefore(startOfWeek);
                          final isLocked = !isAdmin && isPastWeek;
                          selections.putIfAbsent(date, () => DaySelection());
                          return _buildDayCell(
                            nextDay,
                            date,
                            selections[date]!,
                            isPastWeek,
                            false,
                            isLocked,
                            setState,
                            Colors.grey.shade300,
                            selectedEmp == null || selectedEmp == 'ALL'
                                ? null
                                : () => _showTaskTrackingDialog(
                                      context,
                                      selections[date]!,
                                      currentRates,
                                      setState,
                                      isLocked,
                                    ),
                          );
                        }

                        final date = DateTime(month.year, month.month, day);
                        final now = DateTime.now();
                        final startOfWeek =
                            DateTime(now.year, now.month, now.day)
                                .subtract(Duration(days: now.weekday - 1));
                        final isPastWeek = date.isBefore(startOfWeek);
                        final isLocked = !isAdmin && isPastWeek;
                        final today = DateTime.now();
                        final isToday = date.year == today.year &&
                            date.month == today.month &&
                            date.day == today.day;
                        selections.putIfAbsent(date, () => DaySelection());
                        return _buildDayCell(
                          day,
                          date,
                          selections[date]!,
                          isPastWeek,
                          isToday,
                          isLocked,
                          setState,
                          null,
                          selectedEmp == null || selectedEmp == 'ALL'
                              ? null
                              : () => _showTaskTrackingDialog(
                                    context,
                                    selections[date]!,
                                    currentRates,
                                    setState,
                                    isLocked,
                                  ),
                        );
                      },
                    ),
                  ),

                  /// DROPDOWN + GENERATE (generate only for admin)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: (selectedEmp == null ||
                                    selectedEmp == 'ALL' ||
                                    !mapEmpId.keys
                                        .where(
                                            (k) => k != '1313#' && k != '1616#')
                                        .contains(selectedEmp))
                                ? null
                                : selectedEmp,
                            hint: const Text('Select Employee'),
                            items: [
                              if (isAdmin)
                                const DropdownMenuItem(
                                    value: 'ALL', child: Text('All')),
                              ...mapEmpId.entries
                                  .where((e) =>
                                      e.key != '1313#' && e.key != '1616#')
                                  .map((e) => DropdownMenuItem(
                                      value: e.key, child: Text(e.value))),
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

                                    // Show confirmation dialog
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (dialogCtx) => AlertDialog(
                                        title: const Text('Generate Salary?'),
                                        content: const Text(
                                          'Are you sure you want to generate?\n\n'
                                          'Please note: You need to move all ongoing jobs to done first. '
                                          'If not, they will not be counted for loads bonus.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(dialogCtx, false),
                                            child: const Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(dialogCtx, true),
                                            child: const Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed != true) return;

                                    final empKeys = selectedEmp == 'ALL'
                                        ? mapEmpId.keys
                                            .where((k) =>
                                                k != '1313#' && k != '1616#')
                                            .toList()
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

                                    final firestore =
                                        FirebaseFirestore.instance;
                                    final List<CoverageRecordModel>
                                        allChangedDays = [];

                                    // Fetch current utang for all employees BEFORE generation
                                    final Map<String, int> currentUtangPerEmp =
                                        {};
                                    for (final empKey in empKeys) {
                                      final empName = mapEmpId[empKey]!;
                                      final empId = empKey;

                                      try {
                                        final querySnapshot =
                                            await FirebaseService
                                                .employeeFirestore
                                                .collection('EmployeeCurr')
                                                .where('EmpId',
                                                    isEqualTo: empId)
                                                .orderBy('LogDate',
                                                    descending: true)
                                                .limit(1)
                                                .get();

                                        if (querySnapshot.docs.isNotEmpty) {
                                          final doc = querySnapshot.docs.first;
                                          currentUtangPerEmp[empName] =
                                              doc['CurrentStocks'] as int? ?? 0;
                                        } else {
                                          currentUtangPerEmp[empName] = 0;
                                        }
                                      } catch (e) {
                                        currentUtangPerEmp[empName] = 0;
                                      }
                                    }

                                    for (final empKey in empKeys) {
                                      final empName = mapEmpId[empKey]!;
                                      final rate = mapEmpIdRates[empKey] ?? 0;
                                      final db = DatabaseCoverage();
                                      final existing = await db.getAll(empName);

                                      final Set<int> alreadyGenerated = {
                                        for (var r in existing)
                                          if (r.isGenerated) r.coverageDate
                                      };
                                      final Map<int, int> firestoreMap = {
                                        for (var r in existing)
                                          r.coverageDate: r.absent
                                      };

                                      final sourceEntries = selectedEmp == 'ALL'
                                          ? existing.map((r) {
                                              final ds =
                                                  r.coverageDate.toString();
                                              final date = DateTime(
                                                int.parse(ds.substring(0, 4)),
                                                int.parse(ds.substring(4, 6)),
                                                int.parse(ds.substring(6, 8)),
                                              );
                                              bool am = false, pm = false;
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
                                              }
                                              return MapEntry(date,
                                                  DaySelection(a: am, b: pm));
                                            }).toList()
                                          : selections.entries.toList();

                                      final batch = firestore.batch();
                                      final List<CoverageRecordModel>
                                          changedDays = [];

                                      for (final entry in sourceEntries) {
                                        final date = entry.key;
                                        final sel = entry.value;

                                        int absent;
                                        if (sel.a && sel.b)
                                          absent = 0;
                                        else if (!sel.a && sel.b)
                                          absent = 1;
                                        else if (sel.a && !sel.b)
                                          absent = 2;
                                        else
                                          absent = 3;

                                        final coverageDate = int.parse(
                                            DateFormat('yyyyMMdd')
                                                .format(date));
                                        final oldAbsent =
                                            firestoreMap[coverageDate];
                                        final wasGenerated = alreadyGenerated
                                            .contains(coverageDate);

                                        if (absent == 3 && oldAbsent == null)
                                          continue;
                                        if (absent == 3 && !wasGenerated)
                                          continue;
                                        if (wasGenerated && oldAbsent == absent)
                                          continue;

                                        int previousEarned = 0;
                                        if (wasGenerated && oldAbsent != null) {
                                          if (oldAbsent == 0)
                                            previousEarned = rate;
                                          else if (oldAbsent == 1 ||
                                              oldAbsent == 2)
                                            previousEarned = rate ~/ 2;
                                        }

                                        int newEarned = 0;
                                        if (absent == 0)
                                          newEarned = rate;
                                        else if (absent == 1 || absent == 2)
                                          newEarned = rate ~/ 2;

                                        final earned =
                                            newEarned - previousEarned;

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
                                          firestore
                                              .collection('coverage_records')
                                              .doc(empName)
                                              .collection('dates')
                                              .doc(coverageDate.toString()),
                                          record.toMap(),
                                        );
                                      }

                                      if (changedDays.isNotEmpty) {
                                        await batch.commit();
                                        for (final r in changedDays) {
                                          if (r.amountEarned != 0) {
                                            final ds =
                                                r.coverageDate.toString();
                                            final coverageDateTime = DateTime(
                                              int.parse(ds.substring(0, 4)),
                                              int.parse(ds.substring(4, 6)),
                                              int.parse(ds.substring(6, 8)),
                                            );

                                            // Create EmployeeHist record (not SuppliesHist)
                                            final employeeModel = EmployeeModel(
                                              docId: '',
                                              countId: 0,
                                              empId: empNameToId[r.empId]!,
                                              empName: r.empId,
                                              itemId: menuOthCashInOutFunds,
                                              itemUniqueId:
                                                  menuOthSalaryPayment,
                                              itemName: getItemNameOnly(
                                                  menuOthCashInOutFunds,
                                                  menuOthSalaryPayment),
                                              currentCounter: r.amountEarned,
                                              currentStocks: 0,
                                              logDate: Timestamp.now(),
                                              logBy: empIdGlobal,
                                              remarks:
                                                  'Auto generated ${r.coverageDate}${r.amountEarned < 0 ? ' reverted' : ''}',
                                              autoSalaryDate:
                                                  Timestamp.fromDate(
                                                      coverageDateTime),
                                            );

                                            // Add to EmployeeCurr (which also creates EmployeeHist internally)
                                            final dbEmployeeCurrent =
                                                DatabaseEmployeeCurrent();
                                            await dbEmployeeCurrent
                                                .addEmployeeCurr(employeeModel);

                                            // Compute and record bonus only if full day (absent == 0)
                                            if (r.absent == 0) {
                                              await computeBonus(
                                                  empNameToId[r.empId]!,
                                                  r.coverageDate.toString(),
                                                  coverageDateTime);
                                            }
                                          }
                                        }
                                        allChangedDays.addAll(changedDays);

                                        // ════════════════════════════════════════════════════════════════
                                        // GENERATE TASK ENTRIES FROM TASK TRACKING DATA
                                        // ════════════════════════════════════════════════════════════════
                                        if (selectedEmp != 'ALL') {
                                          final allRecords =
                                              await db.getAll(empName);
                                          for (final record in allRecords) {
                                            if (record.tasks == null ||
                                                record.tasks!.isEmpty) {
                                              continue;
                                            }

                                            final ds =
                                                record.coverageDate.toString();
                                            final coverageDateTime = DateTime(
                                              int.parse(ds.substring(0, 4)),
                                              int.parse(ds.substring(4, 6)),
                                              int.parse(ds.substring(6, 8)),
                                            );

                                            // Process each task
                                            for (int taskId = 1;
                                                taskId <= 7;
                                                taskId++) {
                                              final taskKey = taskId.toString();
                                              final taskData =
                                                  record.tasks![taskKey];

                                              if (taskData != null &&
                                                  (taskData['selected'] ??
                                                      false) &&
                                                  (taskData['amount'] ?? 0) >
                                                      0) {
                                                final taskAmount =
                                                    taskData['amount'] as int;
                                                final taskLabel =
                                                    _getTaskLabel(taskId);

                                                final taskEmployeeModel =
                                                    EmployeeModel(
                                                  docId: '',
                                                  countId: 0,
                                                  empId: empNameToId[empName]!,
                                                  empName: empName,
                                                  itemId: menuOthCashInOutFunds,
                                                  itemUniqueId: 100 + taskId,
                                                  itemName: taskLabel,
                                                  currentCounter: taskAmount,
                                                  currentStocks: 0,
                                                  logDate: Timestamp.now(),
                                                  logBy: empIdGlobal,
                                                  remarks:
                                                      'Task: $taskLabel - $taskAmount',
                                                  autoSalaryDate:
                                                      Timestamp.fromDate(
                                                          coverageDateTime),
                                                );

                                                final dbEmployeeCurrent =
                                                    DatabaseEmployeeCurrent();
                                                await dbEmployeeCurrent
                                                    .addEmployeeCurr(
                                                        taskEmployeeModel);
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }

                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    if (sfContext.mounted)
                                      setState(() => isGenerating = false);

                                    if (allChangedDays.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('No changes detected')),
                                      );
                                      return;
                                    }

                                    // Build summary: calculate total earned per employee
                                    final Map<String, int> totalEarnedPerEmp =
                                        {};

                                    // Calculate total earned per employee
                                    for (final record in allChangedDays) {
                                      if (record.amountEarned != 0) {
                                        totalEarnedPerEmp.update(
                                          record.empId,
                                          (val) => val + record.amountEarned,
                                          ifAbsent: () => record.amountEarned,
                                        );
                                      }
                                    }

                                    // Build summary text
                                    final List<String> summaryLines = [];
                                    for (final empName
                                        in totalEarnedPerEmp.keys) {
                                      final utang =
                                          currentUtangPerEmp[empName] ?? 0;
                                      final earned =
                                          totalEarnedPerEmp[empName] ?? 0;
                                      summaryLines.add(
                                        '$empName - Current utang (₱$utang) / Kinita ngayon (₱$earned)',
                                      );
                                    }

                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Done'),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ...summaryLines.map((line) {
                                                // Check if this line has negative utang
                                                final parts = line.split(' - ');
                                                if (parts.length == 2) {
                                                  final empName = parts[0];
                                                  final detailsPart = parts[1];

                                                  // Extract utang value
                                                  final utangMatch = RegExp(
                                                          r'₱(-?\d+)')
                                                      .firstMatch(detailsPart);
                                                  final isNegativeUtang =
                                                      utangMatch != null &&
                                                          int.tryParse(utangMatch
                                                                      .group(
                                                                          1) ??
                                                                  '') !=
                                                              null &&
                                                          int.parse(utangMatch
                                                                  .group(1)!) <
                                                              0;

                                                  return RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: '$empName - ',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        if (isNegativeUtang)
                                                          TextSpan(
                                                            text:
                                                                'Current utang (',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                          )
                                                        else
                                                          TextSpan(
                                                            text:
                                                                'Current utang (',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                        TextSpan(
                                                          text: utangMatch
                                                                  ?.group(0) ??
                                                              '₱0',
                                                          style: TextStyle(
                                                            color:
                                                                isNegativeUtang
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .black,
                                                            fontWeight:
                                                                isNegativeUtang
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              ') / ${detailsPart.substring(detailsPart.indexOf('/') + 1)}',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }
                                                return Text(line);
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
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
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Generate'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              await _showTaskRatesDialog(
                                context,
                                currentRates,
                              );
                              // Reload rates after saving
                              if (sfContext.mounted) {
                                final service = TaskRatesService();
                                final rates = await service.loadAllTaskRates();
                                setState(() {
                                  currentRates = rates;
                                });
                              }
                            },
                            child: const Text('Change Rates'),
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Please select an employee')),
                                      );
                                      return;
                                    }

                                    if (sfContext.mounted)
                                      setState(() => isSaving = true);

                                    final empName = mapEmpId[empId]!;
                                    final db = DatabaseCoverage();
                                    final existing = await db.getAll(empName);
                                    final existingDates = {
                                      for (var r in existing) r.coverageDate
                                    };
                                    final toSave = <CoverageRecordModel>[];

                                    for (final entry in selections.entries) {
                                      final date = entry.key;
                                      final sel = entry.value;
                                      final coverageDate = int.parse(
                                          DateFormat('yyyyMMdd').format(date));

                                      if (!sel.a &&
                                          !sel.b &&
                                          sel.tasks.isEmpty &&
                                          !existingDates.contains(coverageDate))
                                        continue;

                                      int absent;
                                      if (sel.a && sel.b)
                                        absent = 0;
                                      else if (!sel.a && sel.b)
                                        absent = 1;
                                      else if (sel.a && !sel.b)
                                        absent = 2;
                                      else
                                        absent = 3;

                                      // Convert tasks to map format for storage
                                      final tasksMap = <String, dynamic>{};
                                      for (int i = 1; i <= 7; i++) {
                                        final task = sel.tasks[i];
                                        if (task != null) {
                                          tasksMap[i.toString()] = task.toMap();
                                        }
                                      }

                                      toSave.add(CoverageRecordModel(
                                        docId: '',
                                        coverageDate: coverageDate,
                                        amountEarned: 0,
                                        absent: absent,
                                        empId: empName,
                                        remarks: '',
                                        isGenerated: false,
                                        tasks: tasksMap.isNotEmpty
                                            ? tasksMap
                                            : null,
                                      ));
                                    }

                                    if (toSave.isEmpty) {
                                      if (sfContext.mounted)
                                        setState(() => isSaving = false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Nothing to save')),
                                      );
                                      return;
                                    }

                                    await db.batchSave(empName, toSave);

                                    if (sfContext.mounted)
                                      setState(() => isSaving = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Saved ${toSave.length} day(s)')),
                                    );
                                  },
                            child: isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
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
