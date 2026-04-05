import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/services/database_closing_check.dart';
import 'package:laundry_firebase/core/global/variables.dart';

void showClosingCheck(BuildContext context) {
  final db = DatabaseClosingCheck();
  bool lpg = false;
  bool fuse = false;
  bool isLoading = true;
  List<Map<String, dynamic>> history = [];

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
              lpg = isToday ? (latest['lpg'] ?? false) : true;
              fuse = isToday ? (latest['fuse'] ?? false) : true;
            } else {
              lpg = true;
              fuse = true;
            }
            setState(() {
              history = hist;
              isLoading = false;
            });
          });
        }

        return AlertDialog(
          title: const Text('Closing Check', textAlign: TextAlign.center),
          backgroundColor: Colors.deepPurple.shade50,
          contentPadding: const EdgeInsets.all(16),
          content: isLoading
              ? const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _toggleRow(
                        label: '🔥 LPG',
                        value: lpg,
                        onChanged: (v) => setState(() => lpg = v),
                      ),
                      const SizedBox(height: 12),
                      _toggleRow(
                        label: '⚡ Fuse',
                        value: fuse,
                        onChanged: (v) => setState(() => fuse = v),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By: $empIdGlobal',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const Text(
                        'Last 10 History',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (history.isEmpty)
                        const Text('No history yet.',
                            style: TextStyle(fontSize: 11, color: Colors.grey))
                      else
                        ...history.map((r) {
                          final ts = r['logDate'] as Timestamp?;
                          final dateStr = ts != null
                              ? DateFormat('MMM dd, yyyy hh:mm a').format(ts.toDate())
                              : '—';
                          final empName = r['empName'] ?? '';
                          final rLpg = r['lpg'] == true;
                          final rFuse = r['fuse'] == true;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(dateStr,
                                      style: const TextStyle(fontSize: 10)),
                                ),
                                _chip('LPG', rLpg),
                                const SizedBox(width: 4),
                                _chip('Fuse', rFuse),
                                const SizedBox(width: 6),
                                Text(empName,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey)),
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
              child: const Text('Close'),
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
                            'LPG: ${lpg ? "ON" : "OFF"}\nFuse: ${fuse ? "ON" : "OFF"}\n\nSave closing check?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      await db.save(
                        lpg: lpg,
                        fuse: fuse,
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
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: value ? Colors.green.shade100 : Colors.red.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: value ? Colors.green : Colors.red.shade200),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Switch(
          value: value,
          activeColor: Colors.green,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

Widget _chip(String label, bool on) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: on ? Colors.green.shade100 : Colors.red.shade50,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: on ? Colors.green : Colors.red.shade200),
    ),
    child: Text(
      '$label: ${on ? "ON" : "OFF"}',
      style: TextStyle(
        fontSize: 10,
        color: on ? Colors.green.shade800 : Colors.red.shade700,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
