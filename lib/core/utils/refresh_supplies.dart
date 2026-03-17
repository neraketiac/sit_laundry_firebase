import 'package:laundry_firebase/features/pages/body/Supplies/readSuppliesHist.dart';

// Global function to refresh supplies data
void refreshSuppliesData() {
  // Reset supplies history state
  sortedSuppliesHistory.clear();
  lastSuppliesHistoryDoc = null;
  hasMoreSuppliesHistory = true;
  loadingSuppliesHistory = false;
}