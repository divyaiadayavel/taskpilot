import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeProvider() {
    loadTheme();
  }

  void loadTheme() {
    final box = Hive.box('settings');
    _isDark = box.get('isDark', defaultValue: false);
    notifyListeners();
  }

  void toggleTheme() {
    _isDark = !_isDark;

    final box = Hive.box('settings');
    box.put('isDark', _isDark);

    notifyListeners();
  }

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;
}
