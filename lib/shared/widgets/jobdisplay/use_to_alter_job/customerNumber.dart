import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/core/utils/PHPhoneFormatter.dart';

Widget customerNumber(
  BuildContext context,
  TextEditingController valueController,
) {
  return Visibility(
    visible: true,
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 🔹 LABEL
          Text(
            "Mobile Number",
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 12),

          /// 🔹 PHONE FIELD
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                /// 🇵🇭 PREFIX
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    "",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),

                /// INPUT
                Expanded(
                  child: TextFormField(
                    controller: valueController,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                      PHPhoneFormatter(),
                      _NumericPhoneFormatter(),
                    ],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: "09XX XXX XXXX",
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Custom formatter to ensure only numeric input for phone
class _NumericPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits and spaces (for formatting)
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any non-digit characters
    final filtered = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // If the filtered text is the same as new value text, return as-is
    if (filtered == newValue.text) {
      return newValue;
    }

    // Otherwise return filtered version
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
