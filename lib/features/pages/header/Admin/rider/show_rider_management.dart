import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'model_rider_availability.dart';

class ShowRiderManagement extends StatefulWidget {
  const ShowRiderManagement({super.key});

  @override
  State<ShowRiderManagement> createState() => _ShowRiderManagementState();
}

class _ShowRiderManagementState extends State<ShowRiderManagement> {
  late DateTime _focusedMonth;
  final Map<String, ModelRiderAvailability> _schedule = {};
  bool _loading = true;

  final _col = FirebaseService.secondaryFirestore.collection('Rider_schedule');
  final _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_today.year, _today.month);
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() => _loading = true);
    final start = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final end = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    final snap = await _col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    _schedule.clear();
    for (final doc in snap.docs) {
      final a = ModelRiderAvailability.fromMap(doc.data());
      _schedule[a.docId] = a;
    }
    setState(() => _loading = false);
  }

  ModelRiderAvailability _getOrDefault(DateTime date) {
    final key = ModelRiderAvailability(date: date).docId;
    return _schedule[key] ?? ModelRiderAvailability(date: date);
  }

  bool _isPast(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(_today.year, _today.month, _today.day);
    return d.isBefore(t);
  }

  bool _isToday(DateTime date) =>
      date.year == _today.year &&
      date.month == _today.month &&
      date.day == _today.day;

  void _openDaySheet(DateTime date) {
    if (_isPast(date)) return; // past days are read-only / grayed
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DaySheet(
        date: date,
        initial: _getOrDefault(date),
        onSave: (updated) async {
          final label = DateFormat('MMMM d, yyyy').format(date);
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Save $label?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Save the following schedule to Firestore?'),
                  const SizedBox(height: 12),
                  ...List.generate(7, (i) {
                    final checked = [
                      updated.slot7to9,
                      updated.slot9to10,
                      updated.slot10to12,
                      updated.slot1to3,
                      updated.slot3to5,
                      updated.slot5to7,
                      updated.slot7to9pm,
                    ][i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(children: [
                        Icon(
                          checked
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                          color: checked ? Colors.teal : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(kSlotLabels[i],
                            style: const TextStyle(fontSize: 15)),
                      ]),
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes, Save'),
                ),
              ],
            ),
          );

          if (confirm != true) return;
          await _col.doc(updated.docId).set(updated.toMap());
          setState(() => _schedule[updated.docId] = updated);

          if (!context.mounted) return;
          Navigator.pop(context); // close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved schedule for $label')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Admin access only.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Schedule'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthNav(),
                _buildDayHeaders(),
                const Divider(height: 1),
                Expanded(child: _buildCalendarGrid()),
                _buildLegend(),
              ],
            ),
    );
  }

  Widget _buildMonthNav() {
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month - 1);
              });
              _loadMonth();
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedMonth),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month + 1);
              });
              _loadMonth();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeaders() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Center(
                    child: Text(d,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        )),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7; // Sun = 0
    final totalCells = startOffset + daysInMonth;

    return GridView.builder(
      padding: const EdgeInsets.all(6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.72,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < startOffset) return const SizedBox();
        final day = index - startOffset + 1;
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        return _buildDayCell(date);
      },
    );
  }

  Widget _buildDayCell(DateTime date) {
    final past = _isPast(date);
    final today = _isToday(date);
    final avail = _getOrDefault(date);
    final slots = avail.slotList;
    final hasAny = avail.hasAnySlot;

    Color bgColor;
    Color borderColor;
    if (past) {
      bgColor = Colors.grey.shade200;
      borderColor = Colors.grey.shade300;
    } else if (today) {
      bgColor = Colors.teal.shade50;
      borderColor = Colors.teal;
    } else if (hasAny) {
      bgColor = Colors.cyan.shade50;
      borderColor = Colors.cyan.shade300;
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: past ? null : () => _openDaySheet(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: today ? 2 : 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: past
                    ? Colors.grey.shade400
                    : today
                        ? Colors.teal.shade700
                        : Colors.black87,
              ),
            ),
            const SizedBox(height: 3),
            if (past)
              // just show dots for past saved slots
              Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: List.generate(7, (i) {
                  return Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: slots[i]
                          ? Colors.grey.shade400
                          : Colors.grey.shade200,
                    ),
                  );
                }),
              )
            else
              // future/today: show colored dots indicating saved slots
              Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: List.generate(7, (i) {
                  return Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: slots[i] ? Colors.teal : Colors.grey.shade200,
                      border: Border.all(
                        color: slots[i]
                            ? Colors.teal.shade300
                            : Colors.grey.shade300,
                        width: 0.5,
                      ),
                    ),
                  );
                }),
              ),
            if (!past && hasAny)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.check_circle,
                    size: 10, color: Colors.teal.shade400),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendDot(Colors.teal, 'Slot set'),
          const SizedBox(width: 16),
          _legendDot(Colors.grey.shade300, 'No slot'),
          const SizedBox(width: 16),
          _legendDot(Colors.grey.shade400, 'Past'),
          const SizedBox(width: 16),
          Row(children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal, width: 2),
                borderRadius: BorderRadius.circular(3),
                color: Colors.teal.shade50,
              ),
            ),
            const SizedBox(width: 4),
            const Text('Today', style: TextStyle(fontSize: 11)),
          ]),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

// ── Bottom sheet for editing a single day ──────────────────────────────────

class _DaySheet extends StatefulWidget {
  final DateTime date;
  final ModelRiderAvailability initial;
  final Future<void> Function(ModelRiderAvailability) onSave;

  const _DaySheet({
    required this.date,
    required this.initial,
    required this.onSave,
  });

  @override
  State<_DaySheet> createState() => _DaySheetState();
}

class _DaySheetState extends State<_DaySheet> {
  late ModelRiderAvailability _avail;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _avail = widget.initial;
  }

  void _toggle(int i, bool v) {
    setState(() {
      _avail = switch (i) {
        0 => _avail.copyWith(slot7to9: v),
        1 => _avail.copyWith(slot9to10: v),
        2 => _avail.copyWith(slot10to12: v),
        3 => _avail.copyWith(slot1to3: v),
        4 => _avail.copyWith(slot3to5: v),
        5 => _avail.copyWith(slot5to7: v),
        _ => _avail.copyWith(slot7to9pm: v),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('EEEE, MMMM d yyyy').format(widget.date);
    final slots = _avail.slotList;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Tap slots to toggle availability',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ...List.generate(7, (i) => _slotTile(i, slots[i])),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await widget.onSave(_avail);
                        setState(() => _saving = false);
                      },
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save Schedule'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotTile(int i, bool value) {
    const icons = [
      Icons.wb_twilight, // 7am-9am
      Icons.wb_sunny_outlined, // 9am-10am
      Icons.wb_sunny, // 10am-12pm
      Icons.lunch_dining, // 1pm-3pm
      Icons.wb_cloudy_outlined, // 3pm-5pm
      Icons.wb_cloudy, // 5pm-7pm
      Icons.nights_stay_outlined, // 7pm-9pm
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: value ? Colors.teal.shade50 : null,
      child: ListTile(
        leading:
            Icon(icons[i], color: value ? Colors.teal : Colors.grey.shade400),
        title: Text(kSlotLabels[i],
            style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: value,
          onChanged: (v) => _toggle(i, v),
          activeColor: Colors.teal,
        ),
        onTap: () => _toggle(i, !value),
      ),
    );
  }
}
