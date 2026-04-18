/// Responsive scale utility.
///
/// iPad mini 5 (768pt portrait / 1024pt landscape) gets a larger scale.
/// iPhone stays at 1.0x.
///
/// Usage:
///   final s = AppScale.of(context);
///   Text('Hello', style: TextStyle(fontSize: s.body))
///   SizedBox(height: s.gap)
///   Icon(Icons.star, size: s.icon)
library;

import 'package:flutter/material.dart';

class AppScale {
  /// Scale factor: 1.0 for phone, 1.35 for iPad mini 5+
  final double factor;

  const AppScale._(this.factor);

  factory AppScale.of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // iPad mini 5 portrait = 768, landscape = 1024
    final isTablet = width >= 600;
    return AppScale._(isTablet ? 1.2 : 1.0);
  }

  bool get isTablet => factor > 1.0;

  // ── Font sizes ──────────────────────────────────────────────────────────────
  double get tiny => _s(9);
  double get small => _s(11);
  double get body => _s(13);
  double get bodyLarge => _s(15);
  double get title => _s(16);
  double get headline => _s(18);
  double get display => _s(22);

  // ── Spacing ─────────────────────────────────────────────────────────────────
  double get gap => _s(8);
  double get gapSmall => _s(4);
  double get gapLarge => _s(16);
  double get gapXL => _s(24);
  double get padding => _s(12);
  double get paddingLarge => _s(20);

  // ── Icon sizes ───────────────────────────────────────────────────────────────
  double get iconSmall => _s(16);
  double get icon => _s(20);
  double get iconLarge => _s(28);
  double get iconXL => _s(40);

  // ── Component sizes ──────────────────────────────────────────────────────────
  double get buttonHeight => _s(40);
  double get inputHeight => _s(44);
  double get cardRadius => _s(12);
  double get avatarSize => _s(36);

  double _s(double base) => base * factor;
}
