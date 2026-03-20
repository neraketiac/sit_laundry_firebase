import 'package:intl/intl.dart';

String formatCurrency(int amount) {
  return NumberFormat('#,##0.00').format(amount);
}

int calculateYAxisInterval(int maxValue) {
  if (maxValue <= 100) return 20;
  if (maxValue <= 500) return 100;
  if (maxValue <= 1000) return 200;
  if (maxValue <= 5000) return 500;
  if (maxValue <= 10000) return 1000;
  if (maxValue <= 50000) return 5000;
  return 10000;
}
