import 'package:flutter/material.dart';

Widget glassActionButton({
  required String label,
  required VoidCallback onTap,
  bool disabled = false,
}) {
  return GestureDetector(
    onTap: disabled ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: disabled
            ? null
            : const LinearGradient(
                colors: [
                  Colors.blueAccent,
                  Colors.purpleAccent,
                ],
              ),
        color: disabled ? Colors.grey.withOpacity(0.3) : null,
        boxShadow: disabled
            ? []
            : [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: disabled ? Colors.white54 : Colors.white,
        ),
      ),
    ),
  );
}
