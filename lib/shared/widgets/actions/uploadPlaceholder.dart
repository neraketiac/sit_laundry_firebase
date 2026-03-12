import 'package:flutter/material.dart';

Widget uploadPlaceholder(IconData icon) {
  return Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.black.withOpacity(0.25),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 30,
          color: Colors.white70,
        ),
        const SizedBox(height: 6),
        const Text(
          "Upload Receipt",
          style: TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
      ],
    ),
  );
}
