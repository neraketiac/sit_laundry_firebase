import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/fund_check/models/fund_check_model.dart';
import 'package:laundry_firebase/features/fund_check/services/fund_check_service.dart';

class FundCheckForm extends StatefulWidget {
  final FundCheckModel fundCheck;
  final Function(FundCheckModel) onSave;

  const FundCheckForm({
    Key? key,
    required this.fundCheck,
    required this.onSave,
  }) : super(key: key);

  @override
  State<FundCheckForm> createState() => _FundCheckFormState();
}

class _FundCheckFormState extends State<FundCheckForm> {
  late FundCheckModel _fundCheck;

  @override
  void initState() {
    super.initState();
    _fundCheck = widget.fundCheck;
  }

  @override
  Widget build(BuildContext context) {
    // Get the enabled state based on logDate
    final fieldStates = FundCheckService.getCheckFieldsState(_fundCheck);
    final isDisabled =
        FundCheckService.shouldDisableCheckFields(_fundCheck.logDate);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning message if fields are disabled
          if (isDisabled)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                border: Border.all(color: Colors.orange, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      FundCheckService.getDisabledMessage(_fundCheck.logDate),
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Morning Check
          CheckboxListTile(
            enabled: fieldStates['morningCheckEnabled']!,
            title: const Text('Morning Check'),
            subtitle: _fundCheck.morningEnable
                ? null
                : const Text('(Disabled by admin)',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
            value: _fundCheck.morningCheck,
            onChanged: (value) {
              if (fieldStates['morningCheckEnabled']!) {
                setState(() {
                  _fundCheck =
                      _fundCheck.copyWith(morningCheck: value ?? false);
                });
              }
            },
          ),

          // Lunch Check
          CheckboxListTile(
            enabled: fieldStates['lunchCheckEnabled']!,
            title: const Text('Lunch Check'),
            subtitle: _fundCheck.lunchEnable
                ? null
                : const Text('(Disabled by admin)',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
            value: _fundCheck.lunchCheck,
            onChanged: (value) {
              if (fieldStates['lunchCheckEnabled']!) {
                setState(() {
                  _fundCheck = _fundCheck.copyWith(lunchCheck: value ?? false);
                });
              }
            },
          ),

          // Dinner Check
          CheckboxListTile(
            enabled: fieldStates['dinnerCheckEnabled']!,
            title: const Text('Dinner Check'),
            subtitle: _fundCheck.dinnerEnable
                ? null
                : const Text('(Disabled by admin)',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
            value: _fundCheck.dinnerCheck,
            onChanged: (value) {
              if (fieldStates['dinnerCheckEnabled']!) {
                setState(() {
                  _fundCheck = _fundCheck.copyWith(dinnerCheck: value ?? false);
                });
              }
            },
          ),

          const SizedBox(height: 20),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isDisabled
                  ? null
                  : () {
                      widget.onSave(_fundCheck);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: const Text('Save Fund Check'),
            ),
          ),
        ],
      ),
    );
  }
}
