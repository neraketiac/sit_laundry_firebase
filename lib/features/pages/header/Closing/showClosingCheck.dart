import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/services/database_closing_check.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/features/pages/header/Funds/showFundCheck.dart';
import 'package:laundry_firebase/features/pages/header/Items/showItemsInOut.dart';
import 'package:laundry_firebase/features/pages/header/Employee/showCalendarDialog.dart';

void showClosingCheck(BuildContext context) {
  final outerContext = context;
  final db = DatabaseClosingCheck();
  bool lpg = false;
  bool fuse = false;
  bool fundCheck = false;
  bool inventory = false;
  bool schedule = false;
  bool isLoading = true;
  List<Map<String, dynamic>> history = [];

  // Capture dark mode from calling context BEFORE showDialog
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        if (isLoading) {
          db.getHistory().then((hist) {
            final now = DateTime.now();
            if (hist.isNotEmpty) {
              final latest = hist.first;
              final ts = latest['logDate'] as Timestamp?;
              final latestDate = ts?.toDate();
              final isToday = latestDate != null &&
                  latestDate.year == now.year &&
                  latestDate.month == now.month &&
                  latestDate.day == now.day;
              lpg = isToday ? (latest['lpg'] ?? false) : false;
              fuse = isToday ? (latest['fuse'] ?? false) : false;
              fundCheck = isToday ? (latest['fundCheck'] ?? false) : false;
              inventory = isToday ? (latest['inventory'] ?? false) : false;
              schedule = isToday ? (latest['schedule'] ?? false) : false;
            } else {
              lpg = fuse = fundCheck = inventory = schedule = false;
            }
            setState(() {
              history = hist;
              isLoading = false;
            });
          });
        }

        final dialogBg =
            isDarkMode ? const Color(0xFF0D1117) : Colors.deepPurple.shade50;
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final subTextColor = isDarkMode ? Colors.white60 : Colors.grey;
        final histRowBg = isDarkMode ? const Color(0xFF1A2535) : Colors.white;
        final histRowBorder =
            isDarkMode ? const Color(0xFF2A3F5F) : Colors.grey.shade300;

        return AlertDialog(
          title: Text('Closing Check',
              textAlign: TextAlign.center, style: TextStyle(color: textColor)),
          backgroundColor: dialogBg,
          contentPadding: const EdgeInsets.all(16),
          content: isLoading
              ? const SizedBox(
                  height: 80, child: Center(child: CircularProgressIndicator()))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _toggleRow(
                          label: '💵 Funds Check',
                          value: fundCheck,
                          onChanged: (v) => setState(() => fundCheck = v),
                          trueLabel: 'Done',
                          falseLabel: 'Not Done',
                          isDark: isDarkMode,
                          onTap: () => showFundCheck(outerContext)),
                      const SizedBox(height: 8),
                      _toggleRow(
                          label: '📦 Inventory Check',
                          value: inventory,
                          onChanged: (v) => setState(() => inventory = v),
                          trueLabel: 'Done',
                          falseLabel: 'Not Done',
                          isDark: isDarkMode,
                          onTap: () => showItemsInOut(outerContext)),
                      const SizedBox(height: 8),
                      _toggleRow(
                          label: '📅 Staff Schedule',
                          value: schedule,
                          onChanged: (v) => setState(() => schedule = v),
                          trueLabel: 'Done',
                          falseLabel: 'Not Done',
                          isDark: isDarkMode,
                          onTap: () => showCalendarDialog(outerContext)),
                      const SizedBox(height: 8),
                      _toggleRow(
                          label: '🔥 LPG',
                          value: lpg,
                          onChanged: (v) => setState(() => lpg = v),
                          trueLabel: 'Close',
                          falseLabel: 'Open',
                          isDark: isDarkMode),
                      const SizedBox(height: 8),
                      _toggleRow(
                          label: '⚡ Fuse',
                          value: fuse,
                          onChanged: (v) => setState(() => fuse = v),
                          trueLabel: 'Close',
                          falseLabel: 'Open',
                          isDark: isDarkMode),
                      const SizedBox(height: 8),
                      Text('By: $empIdGlobal',
                          style: TextStyle(fontSize: 11, color: subTextColor)),
                      const SizedBox(height: 20),
                      Divider(
                          color: isDarkMode
                              ? Colors.white24
                              : Colors.grey.shade300),
                      Text('Last 10 History',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      const SizedBox(height: 8),
                      if (history.isEmpty)
                        Text('No history yet.',
                            style: TextStyle(fontSize: 11, color: subTextColor))
                      else
                        ...history.map((r) {
                          final ts = r['logDate'] as Timestamp?;
                          final dateStr = ts != null
                              ? DateFormat('MMM dd, yyyy hh:mm a')
                                  .format(ts.toDate())
                              : '—';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: histRowBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: histRowBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(dateStr,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: textColor))),
                                    Text(r['empName'] ?? '',
                                        style: TextStyle(
                                            fontSize: 10, color: subTextColor)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  children: [
                                    _chip('Funds', r['fundCheck'] == true,
                                        'Done', 'Not Done'),
                                    _chip('Inv', r['inventory'] == true, 'Done',
                                        'Not Done'),
                                    _chip('Sched', r['schedule'] == true,
                                        'Done', 'Not Done'),
                                    _chip('LPG', r['lpg'] == true, 'Close',
                                        'Open'),
                                    _chip('Fuse', r['fuse'] == true, 'Close',
                                        'Open'),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: textColor)),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirm Save'),
                          content: Text(
                            'Funds Check: ${fundCheck ? "Done" : "Not Done"}\n'
                            'Inventory Check: ${inventory ? "Done" : "Not Done"}\n'
                            'Staff Schedule: ${schedule ? "Done" : "Not Done"}\n'
                            'LPG: ${lpg ? "Close" : "Open"}\n'
                            'Fuse: ${fuse ? "Close" : "Open"}\n\n'
                            'Save closing check?',
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Save')),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      await db.save(
                        lpg: lpg,
                        fuse: fuse,
                        fundCheck: fundCheck,
                        inventory: inventory,
                        schedule: schedule,
                        empId: empIdGlobal,
                        empName: empIdGlobal,
                      );

                      final newHistory = await db.getHistory();
                      if (context.mounted) {
                        setState(() => history = newHistory);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Closing check saved.')),
                        );
                      }
                    },
              child: const Text('Save'),
            ),
          ],
        );
      });
    },
  );
}

Widget _toggleRow({
  required String label,
  required bool value,
  required ValueChanged<bool> onChanged,
  String trueLabel = 'ON',
  String falseLabel = 'OFF',
  bool isDark = false,
  VoidCallback? onTap,
}) {
  final bg = value
      ? (isDark ? Colors.green.shade900 : Colors.green.shade100)
      : (isDark ? const Color(0xFF2A1A1A) : Colors.red.shade50);
  final border = value
      ? (isDark ? Colors.green.shade700 : Colors.green)
      : (isDark ? Colors.red.shade900 : Colors.red.shade200);
  final labelColor = isDark ? Colors.white : Colors.black87;
  final valueColor = value
      ? (isDark ? Colors.green.shade300 : Colors.green.shade800)
      : (isDark ? Colors.red.shade300 : Colors.red.shade700);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: labelColor)),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.open_in_new,
                    size: 14,
                    color: isDark ? Colors.white38 : Colors.grey.shade500),
              ],
            ],
          ),
          Row(
            children: [
              Text(
                value ? trueLabel : falseLabel,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valueColor),
              ),
              const SizedBox(width: 8),
              Switch(
                  value: value,
                  activeThumbColor: Colors.green,
                  onChanged: onChanged),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _chip(String label, bool on,
    [String trueLabel = 'ON', String falseLabel = 'OFF']) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: on ? Colors.green.shade100 : Colors.red.shade50,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: on ? Colors.green : Colors.red.shade200),
    ),
    child: Text(
      '$label: ${on ? trueLabel : falseLabel}',
      style: TextStyle(
        fontSize: 10,
        color: on ? Colors.green.shade800 : Colors.red.shade700,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
