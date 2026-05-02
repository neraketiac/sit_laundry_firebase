import 'package:flutter/material.dart';

/// Overlay widget that displays child without version checking
/// Version checking is now done only on login and main button click
/// (see ProjectVersionManager for details)
class VersionCheckOverlay extends StatefulWidget {
  final Widget child;

  const VersionCheckOverlay({
    super.key,
    required this.child,
  });

  @override
  State<VersionCheckOverlay> createState() => _VersionCheckOverlayState();
}

class _VersionCheckOverlayState extends State<VersionCheckOverlay> {
  @override
  Widget build(BuildContext context) {
    // Simply return the child widget
    // Version checking is handled by ProjectVersionManager on login and main button click
    return widget.child;
  }
}
