import 'package:flutter/material.dart';

Widget glassMiniCounterButton({
  required String label,
  required VoidCallback onTap,
  bool disabled = false,
}) {
  return GestureDetector(
    onTap: disabled ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: disabled
            ? null
            : const LinearGradient(
                colors: [
                  Colors.blueAccent,
                  Colors.purpleAccent,
                ],
              ),
        color: disabled ? Colors.grey.withOpacity(0.3) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: disabled ? Colors.white54 : Colors.white,
        ),
      ),
    ),
  );
}
