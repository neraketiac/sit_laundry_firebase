import 'package:flutter/material.dart';

Widget conRemarks(
  BuildContext context,
  VoidCallback dialogSetState,
  TextEditingController valueController,
) {
  return Container(
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 Title
        Text(
          "Remarks / Notes",
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),

        const SizedBox(height: 12),

        /// 🔹 Text Area
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(0.25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: TextFormField(
            controller: valueController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            minLines: 2,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              hintText: "Enter notes here...",
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
  );
}
