import 'package:cloud_firestore/cloud_firestore.dart';

/// Processes supplies summary data from SuppliesHist.
class SuppliesData {
  Map<String, int> data = {
    'Funds In': 0,
    'Funds Out': 0,
    'Laundry Payment': 0,
    'Cash In/Load': 0,
    'Cash Out': 0,
  };

  void process(List<QueryDocumentSnapshot> docs) {
    data = {
      'Funds In': 0,
      'Funds Out': 0,
      'Laundry Payment': 0,
      'Cash In/Load': 0,
      'Cash Out': 0,
    };

    for (final doc in docs) {
      final d = doc.data() as Map<String, dynamic>;
      final itemId = d['ItemUniqueId'] ?? 0;
      final raw = d['CurrentCounter'] ?? 0;
      final counter = raw is int ? raw : (raw as double).toInt();

      if (counter > 0) data['Funds In'] = data['Funds In']! + counter;
      if (counter < 0) data['Funds Out'] = data['Funds Out']! + counter.abs();
      if (itemId == 4405) {
        data['Laundry Payment'] = data['Laundry Payment']! + counter;
      }
      if (itemId == 4401 || itemId == 431) {
        data['Cash In/Load'] = data['Cash In/Load']! + counter;
      }
      if (itemId == 4402) {
        data['Cash Out'] = data['Cash Out']! + counter;
      }
    }
  }
}
