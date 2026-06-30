import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/fund_check/models/fund_check_model.dart';
import 'package:laundry_firebase/features/fund_check/services/fund_check_service.dart';

/// Widget that displays fund check validation status and blocks actions if needed
class FundCheckValidator extends StatelessWidget {
  final FundCheckModel fundCheck;
  final VoidCallback? onValidationPassed;

  const FundCheckValidator({
    Key? key,
    required this.fundCheck,
    this.onValidationPassed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Validate time-based fund check
    final errorMessage = FundCheckService.validateTimeBasedFundCheck(fundCheck);
    final currentPeriod = FundCheckService.getCurrentTimePeriod();
    final isCheckRequired =
        FundCheckService.isCurrentPeriodCheckRequired(fundCheck);

    return Column(
      children: [
        // Status Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCheckRequired ? Colors.red.shade50 : Colors.green.shade50,
            border: Border.all(
              color: isCheckRequired ? Colors.red : Colors.green,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isCheckRequired ? Icons.warning : Icons.check_circle,
                color: isCheckRequired ? Colors.red : Colors.green,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPeriod.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FundCheckService.getCurrentPeriodMessage(fundCheck),
                      style: TextStyle(
                        fontSize: 13,
                        color: isCheckRequired
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Error message if validation failed
        if (errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              border: Border.all(color: Colors.red, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Static method to show validation dialog if needed
  static Future<bool> showValidationDialog(
    BuildContext context,
    FundCheckModel fundCheck, {
    String? title,
    String? actionLabel,
  }) async {
    final errorMessage = FundCheckService.validateTimeBasedFundCheck(fundCheck);

    if (errorMessage != null) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title ?? 'Fund Check Required'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Go to Fund Check'),
              ),
            ],
          );
        },
      );
      return result ?? false;
    }

    return true; // Validation passed
  }
}

/// Helper function to use in any action that requires fund check
Future<bool> checkFundCheckBeforeAction(
  BuildContext context,
  FundCheckModel fundCheck,
) async {
  final result =
      await FundCheckValidator.showValidationDialog(context, fundCheck);
  return result;
}
