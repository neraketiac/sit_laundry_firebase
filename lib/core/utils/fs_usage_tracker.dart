import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables.dart';

/// Tracks Firestore read counts per UI source.
/// Flushes to `fs_usage_log` every 500 reads or on logout.
/// Counters reset after each flush.
class FsUsageTracker {
  FsUsageTracker._();
  static final FsUsageTracker instance = FsUsageTracker._();

  static const int _threshold = 500;
  static const String _collection = 'fs_usage_log';

  final Map<String, int> _reads = {};
  int _totalReads = 0;

  /// Call this after every paginated load.
  /// [source] = widget/screen name, [count] = number of docs returned.
  void track(String source, int count) {
    if (count <= 0) return;
    _reads[source] = (_reads[source] ?? 0) + count;
    _totalReads += count;
    if (_totalReads >= _threshold) {
      flush(trigger: 'threshold');
    }
  }

  /// Saves current counts to Firestore and resets.
  /// [trigger] = 'threshold' | 'logout'
  Future<void> flush({String trigger = 'logout'}) async {
    if (_totalReads == 0) return;

    final snapshot = Map<String, int>.from(_reads);
    final total = _totalReads;

    // Reset immediately so new reads start fresh
    _reads.clear();
    _totalReads = 0;

    try {
      await FirebaseFirestore.instance.collection(_collection).add({
        'empId': empIdGlobal,
        'date': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        'timestamp': FieldValue.serverTimestamp(),
        'reads': snapshot,
        'totalReads': total,
        'trigger': trigger,
      });
    } catch (e) {
      // Silently fail — don't interrupt the user
    }
  }
}
