import 'package:flutter/services.dart';

class PHPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all spaces
    String digits = newValue.text.replaceAll(' ', '');

    // Allow digits only
    digits = digits.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 11 digits
    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    String formatted = '';

    for (int i = 0; i < digits.length; i++) {
      formatted += digits[i];

      // Add spaces after 2, 4, and 7 digits
      if (i == 1 || i == 3 || i == 6) {
        if (i != digits.length - 1) {
          formatted += ' ';
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
