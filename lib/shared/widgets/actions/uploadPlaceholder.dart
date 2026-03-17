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
    child: Center(
      child: Icon(
        icon,
        size: 12,
        color: Colors.white70,
      ),
    ),
  );
}
