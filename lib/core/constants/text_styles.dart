import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // 🔥 HEADINGS
  static const heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const subHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // 📝 BODY
  static const body = TextStyle(fontSize: 14, color: AppColors.textSecondary);

  static const bodyBold = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  // 🔘 BUTTON
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
