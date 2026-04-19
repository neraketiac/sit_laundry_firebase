import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

/// Firestore collection: promo_days
/// Doc ID: "yyyy-MM-dd"
/// Fields: { date: Timestamp, disabled: bool }
///
/// Usage in promo_counter computation:
///   if (promoEnabled for that day) → compute promo_counter normally
///   else → promo_counter = 0

class ShowEnablePromo extends StatefulWidget {
  const ShowEnablePromo({super.key});

  @override
  State<ShowEnablePromo> createState() => _ShowEnablePromoState();
}

class _ShowEnablePromoState extends State<ShowEnablePromo> {
  late DateTime _focusedMonth;

  /// docId → disabled flag. Only days explicitly disabled are stored here.
  final Map<String, bool> _disabledDays = {};
  bool _loading = true;

  final _col = FirebaseService.primaryFirestore.collection('promo_days');
  final _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_today.year, _today.month);
    _loadMonth();
  }

  String _docId(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<void> _loadMonth() async {
    setState(() => _loading = true);
    final start = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final end = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    final snap = await _col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    _disabledDays.clear();
    for (final doc in snap.docs) {
      final data = doc.data();
      final disabled = data['disabled'] as bool? ?? false;
      if (disabled) _disabledDays[doc.id] = true;
    }
    setState(() => _loading = false);
  }

  bool _isDisabled(DateTime date) => _disabledDays[_docId(date)] == true;

  bool _isToday(DateTime date) =>
      date.year == _today.year &&
      date.month == _today.month &&
      date.day == _today.day;

  Future<void> _toggleDay(DateTime date) async {
    final id = _docId(date);
    final nowDisabled = _isDisabled(date);
    final newDisabled = !nowDisabled;

    // Optimistic update
    setState(() {
      if (newDisabled) {
        _disabledDays[id] = true;
      } else {
        _disabledDays.remove(id);
      }
    });

    try {
      if (newDisabled) {
        await _col.doc(id).set({
          'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
          'disabled': true,
        });
      } else {
        // Re-enable: delete the doc (absence = enabled)
        await _col.doc(id).delete();
      }
    } catch (e) {
      // Revert on error
      setState(() {
        if (nowDisabled) {
          _disabledDays[id] = true;
        } else {
          _disabledDays.remove(id);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
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
        title: const Text('Promo Days'),
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
          .withValues(alpha: 0.3),
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
        childAspectRatio: 0.85,
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
    final today = _isToday(date);
    final disabled = _isDisabled(date);

    Color bgColor;
    Color borderColor;
    if (disabled) {
      bgColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
    } else if (today) {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green;
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: () => _toggleDay(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: today ? 2 : 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: disabled
                    ? Colors.red.shade700
                    : today
                        ? Colors.green.shade700
                        : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              disabled ? Icons.block : Icons.check_circle_outline,
              size: 14,
              color: disabled ? Colors.red.shade400 : Colors.green.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(
              Icons.check_circle_outline, Colors.green.shade400, 'Promo ON'),
          const SizedBox(width: 20),
          _legendItem(Icons.block, Colors.red.shade400, 'Promo OFF'),
          const SizedBox(width: 20),
          Row(children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(3),
                color: Colors.green.shade50,
              ),
            ),
            const SizedBox(width: 4),
            const Text('Today', style: TextStyle(fontSize: 11)),
          ]),
        ],
      ),
    );
  }

  Widget _legendItem(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
