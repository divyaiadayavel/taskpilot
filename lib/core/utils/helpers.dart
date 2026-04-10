import 'package:flutter/material.dart';

class Helpers {
  // 🔥 SNACKBAR
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // 🔄 NAVIGATION
  static void push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  static void pushReplace(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  // 📅 FORMAT DATE
  static String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
