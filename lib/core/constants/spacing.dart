import 'package:flutter/material.dart';

class AppSpacing {
  // 🔹 HEIGHT SPACING
  static const h5 = SizedBox(height: 5);
  static const h10 = SizedBox(height: 10);
  static const h15 = SizedBox(height: 15);
  static const h20 = SizedBox(height: 20);
  static const h30 = SizedBox(height: 30);

  // 🔹 WIDTH SPACING
  static const w5 = SizedBox(width: 5);
  static const w10 = SizedBox(width: 10);
  static const w15 = SizedBox(width: 15);

  // 🔹 PADDING
  static const screenPadding = EdgeInsets.all(16);
  static const cardPadding = EdgeInsets.all(16);
  static const inputPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );

  // 🔹 BORDER RADIUS
  static const radiusSmall = 10.0;
  static const radiusMedium = 14.0;
  static const radiusLarge = 20.0;
}
