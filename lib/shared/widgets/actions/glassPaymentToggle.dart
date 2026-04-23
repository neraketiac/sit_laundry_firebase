import 'package:flutter/material.dart';

Widget glassPaymentToggle({
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: selected
            ? const LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
              )
            : null,
        color: selected ? null : Colors.black.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : Colors.white.withOpacity(0.7),
        ),
      ),
    ),
  );
}
