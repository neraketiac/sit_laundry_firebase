import 'package:flutter/material.dart';
import 'package:laundry_firebase/shared/widgets/actions/glassMiniCounterButton.dart';

Widget glassCounterCard({
  required String label,
  required int count,
  required VoidCallback onIncrement,
  required VoidCallback onDecrement,
  bool visible = true,
  bool highlight = false,
}) {
  return Visibility(
    visible: visible,
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: highlight
              ? [
                  Colors.greenAccent.withOpacity(0.4),
                  Colors.tealAccent.withOpacity(0.3),
                ]
              : [
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// ➖
          glassMiniCounterButton(
            label: "-",
            disabled: count <= 0,
            onTap: onDecrement,
          ),

          /// LABEL + COUNT
          Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$count pc",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          /// ➕
          glassMiniCounterButton(
            label: "+",
            onTap: onIncrement,
          ),
        ],
      ),
    ),
  );
}
