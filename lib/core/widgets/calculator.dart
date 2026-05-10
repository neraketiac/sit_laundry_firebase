import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:laundry_firebase/core/widgets/fee_reference_table.dart';

/// Calculator widget for GCash transactions
/// Shows a small dialog with fields for Customer Cash, Amount to Pay, Fee, and auto-calculated Sukli
void showCalculator(
  BuildContext context, {
  required int initialAmount,
  required int initialFee,
  required Function(String customerCash, int amount, int fee) onClose,
  bool showFeeField = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CalculatorDialog(
        initialAmount: initialAmount,
        initialFee: initialFee,
        onClose: onClose,
        showFeeField: showFeeField,
      );
    },
  );
}

class CalculatorDialog extends StatefulWidget {
  final int initialAmount;
  final int initialFee;
  final Function(String customerCash, int amount, int fee) onClose;
  final bool showFeeField;

  const CalculatorDialog({
    Key? key,
    required this.initialAmount,
    required this.initialFee,
    required this.onClose,
    this.showFeeField = true,
  }) : super(key: key);

  @override
  State<CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  late TextEditingController customerCashController;
  late TextEditingController amountToPayController;
  late TextEditingController amountFeeController;
  late FocusNode customerCashFocus;
  late FocusNode amountToPayFocus;
  late FocusNode amountFeeFocus;

  int sukli = 0;

  @override
  void initState() {
    super.initState();
    customerCashController = TextEditingController();
    amountToPayController =
        TextEditingController(text: widget.initialAmount.toString());
    amountFeeController =
        TextEditingController(text: widget.initialFee.toString());

    customerCashFocus = FocusNode();
    amountToPayFocus = FocusNode();
    amountFeeFocus = FocusNode();

    // Add listeners to auto-select all text on focus
    customerCashFocus.addListener(_onCustomerCashFocus);
    amountToPayFocus.addListener(_onAmountToPayFocus);
    amountFeeFocus.addListener(_onAmountFeeFocus);
  }

  void _onCustomerCashFocus() {
    if (customerCashFocus.hasFocus) {
      customerCashController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: customerCashController.text.length,
      );
    }
  }

  void _onAmountToPayFocus() {
    if (amountToPayFocus.hasFocus) {
      amountToPayController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: amountToPayController.text.length,
      );
    }
  }

  void _onAmountFeeFocus() {
    if (amountFeeFocus.hasFocus) {
      amountFeeController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: amountFeeController.text.length,
      );
    }
  }

  void _calculateSukli() {
    final customerCash =
        int.tryParse(customerCashController.text.replaceAll(',', '')) ?? 0;
    final amountToPay =
        int.tryParse(amountToPayController.text.replaceAll(',', '')) ?? 0;
    final amountFee =
        int.tryParse(amountFeeController.text.replaceAll(',', '')) ?? 0;

    setState(() {
      sukli = customerCash - (amountToPay + amountFee);
    });
  }

  @override
  void dispose() {
    customerCashController.dispose();
    amountToPayController.dispose();
    amountFeeController.dispose();
    customerCashFocus.dispose();
    amountToPayFocus.dispose();
    amountFeeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScale.of(context);

    return Dialog(
      backgroundColor: Colors.lightBlue,
      insetPadding: EdgeInsets.symmetric(
        horizontal: s.isTablet ? 40 : 40,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: s.isTablet ? 600 : 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                'Calculator',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.black26),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Cash
                  _buildInputField(
                    label: 'Customer Cash',
                    controller: customerCashController,
                    focusNode: customerCashFocus,
                    onChanged: (_) => _calculateSukli(),
                    s: s,
                  ),
                  const SizedBox(height: 12),
                  // Amount to Pay
                  _buildInputField(
                    label: 'Amount to Pay',
                    controller: amountToPayController,
                    focusNode: amountToPayFocus,
                    onChanged: (_) => _calculateSukli(),
                    s: s,
                  ),
                  const SizedBox(height: 12),
                  // Amount Fee with Fee Reference button
                  if (widget.showFeeField)
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'Amount Fee',
                            controller: amountFeeController,
                            focusNode: amountFeeFocus,
                            onChanged: (_) => _calculateSukli(),
                            s: s,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Fee Reference Table button
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                showFeeReferenceTable(
                                  context,
                                  onFeeSelected: (selectedFee) {
                                    amountFeeController.text = selectedFee;
                                    _calculateSukli();
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.blue.shade700,
                                ),
                                child: const Text(
                                  'Fee',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (widget.showFeeField) const SizedBox(height: 16),
                  // Sukli (Display only)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sukli: ₱${sukli.toString()}',
                        style: TextStyle(
                          fontSize: s.body,
                          fontWeight: FontWeight.w600,
                          color: sukli < 0 ? Colors.red : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Close Button (Bottom Right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Get current values from controllers
                          final sukliValue = sukli;
                          final amount = int.tryParse(amountToPayController.text
                                  .replaceAll(',', '')) ??
                              0;
                          final fee = int.tryParse(amountFeeController.text
                                  .replaceAll(',', '')) ??
                              0;
                          // Transfer values to callback - pass sukli as string
                          widget.onClose(sukliValue.toString(), amount, fee);
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black87,
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String) onChanged,
    required AppScale s,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: s.small,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.black.withOpacity(0.25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              const Text(
                '₱',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'\d')),
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: s.body,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: Colors.white54,
                      fontSize: s.body,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
