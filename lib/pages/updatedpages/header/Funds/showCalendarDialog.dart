import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        child: Text(t,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

Future<Map<DateTime, DaySelection>?> showCalendarDialog(BuildContext context) {
  final selections = <DateTime, DaySelection>{};
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

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

          return Dialog(
            insetPadding: isSmall ? EdgeInsets.zero : const EdgeInsets.all(24),
            child: SizedBox(
              width: isSmall ? double.infinity : 460,
              height: isSmall ? size.height : size.height * 0.7,
              child: Column(
                children: [
                  // 🔹 Header
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

                  // 🔹 Weekdays
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

                  // 🔹 Calendar
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
                        selections.putIfAbsent(date, () => DaySelection());
                        final d = selections[date]!;

                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            children: [
                              Text('$day',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: d.a,
                                    onChanged: (v) =>
                                        setState(() => d.a = v ?? false),
                                    visualDensity: const VisualDensity(
                                        horizontal: -4, vertical: -4),
                                  ),
                                  Checkbox(
                                    value: d.b,
                                    onChanged: (v) =>
                                        setState(() => d.b = v ?? false),
                                    visualDensity: const VisualDensity(
                                        horizontal: -4, vertical: -4),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('am'),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('pm')
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // 🔹 Actions
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, selections),
                            child: const Text('Save'),
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
