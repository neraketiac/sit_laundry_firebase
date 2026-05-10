import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';

/// Fee Reference Table widget for GCash transactions
void showFeeReferenceTable(
  BuildContext context, {
  required Function(String) onFeeSelected,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return FeeReferenceTableDialog(
        onFeeSelected: onFeeSelected,
      );
    },
  );
}

class FeeReferenceTableDialog extends StatelessWidget {
  final Function(String) onFeeSelected;

  const FeeReferenceTableDialog({
    Key? key,
    required this.onFeeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = AppScale.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fee reference data
    final feeData = [
      {'amount': '1 - 100', 'fee': '5'},
      {'amount': '101 - 500', 'fee': '10'},
      {'amount': '501 - 750', 'fee': '15'},
      {'amount': '751 - 1000', 'fee': '20'},
      {'amount': '1001 - 1500', 'fee': '30'},
      {'amount': '1501 - 2000', 'fee': '40'},
      {'amount': '2001 - 2500', 'fee': '50'},
      {'amount': '2501 - 3000', 'fee': '60'},
      {'amount': '3001 - 3500', 'fee': '70'},
      {'amount': '3501 - 4000', 'fee': '80'},
      {'amount': '4001 - 4500', 'fee': '90'},
      {'amount': '4501 - 5000', 'fee': '100'},
      {'amount': '5001 - 5500', 'fee': '110'},
      {'amount': '5501 - 6000', 'fee': '120'},
      {'amount': '6001 - 6500', 'fee': '130'},
      {'amount': '6501 - 7000', 'fee': '140'},
      {'amount': '7001 - 7500', 'fee': '150'},
      {'amount': '7501 - 8000', 'fee': '160'},
      {'amount': '8001 - 8500', 'fee': '170'},
      {'amount': '8501 - 9000', 'fee': '180'},
      {'amount': '9001 - 9500', 'fee': '190'},
      {'amount': '9501 - 10000', 'fee': '200'},
    ];

    return Dialog(
      backgroundColor: Colors.lightBlue,
      insetPadding: EdgeInsets.symmetric(
        horizontal: s.isTablet ? 40 : 40,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: s.isTablet ? 600 : 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                'Fee Reference Table',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.black26),
            // Table
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Container(
                      color: Colors.blue.shade700,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Amount',
                                style: TextStyle(
                                  fontSize: s.body,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Fee',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: s.body,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Body rows with alternating colors
                    ...List.generate(
                      feeData.length,
                      (index) {
                        final isEven = index % 2 == 0;
                        final bgColor = isEven
                            ? (isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100)
                            : (isDark ? Colors.grey.shade900 : Colors.white);
                        final textColor =
                            isDark ? Colors.white : Colors.black87;

                        return Material(
                          color: bgColor,
                          child: InkWell(
                            onTap: () {
                              // Pass selected fee to callback and close dialog
                              onFeeSelected(feeData[index]['fee']!);
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      feeData[index]['amount']!,
                                      style: TextStyle(
                                        fontSize: s.body,
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '₱${feeData[index]['fee']}',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: s.body,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.black26),
            // Close Button (Bottom Right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
