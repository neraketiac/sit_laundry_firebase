import 'package:flutter/material.dart';

Widget glassAmountField({
  required String label,
  required TextEditingController controller,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.black.withOpacity(0.25),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
      ),
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
    ),
  );
}
