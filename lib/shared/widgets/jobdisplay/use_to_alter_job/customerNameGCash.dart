import 'package:flutter/material.dart';

Widget customerNameGCash(
  BuildContext context,
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
        /// 🔹 LABEL
        Text(
          "GCash Account Name",
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),

        const SizedBox(height: 12),

        /// 🔹 INPUT FIELD
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
          child: TextFormField(
            controller: valueController,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              hintText: "Enter GCash Account Name",
              hintStyle: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
              border: InputBorder.none,
            ),

            /// ✅ Proper validation
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return "Please enter account name";
              }
              return null;
            },
          ),
        ),
      ],
    ),
  );
}
