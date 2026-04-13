import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // 🔥 HEADINGS
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    // Remove color here so it inherits from Theme
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // 📝 BODY
  static const TextStyle body = TextStyle(fontSize: 14);

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // 🔘 BUTTON
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
