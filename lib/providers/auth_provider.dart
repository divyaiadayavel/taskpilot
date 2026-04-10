import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  bool get isAdmin => _currentUser?.role == 'admin';

  // ============================
  // 🔐 LOGIN
  // ============================
  Future<bool> login(String email, String password) async {
    final box = Hive.box<UserModel>('users');
    final settingsBox = Hive.box('settings');

    try {
      final user = box.values.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
      );

      _currentUser = user;

      // 🔥 SAVE SESSION
      await settingsBox.put('loggedInUserId', user.id);

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================
  // 🚪 LOGOUT
  // ============================
  Future<void> logout() async {
    final settingsBox = Hive.box('settings');

    await settingsBox.delete('loggedInUserId');

    _currentUser = null;
    notifyListeners();
  }

  // ============================
  // 🔄 LOAD SESSION (AUTO LOGIN)
  // ============================
  Future<void> loadUser() async {
    final box = Hive.box<UserModel>('users');
    final settingsBox = Hive.box('settings');

    final userId = settingsBox.get('loggedInUserId');

    if (userId != null) {
      try {
        final user = box.values.firstWhere((u) => u.id == userId);

        _currentUser = user;
        notifyListeners();
      } catch (e) {
        // user not found
      }
    }
  }

  // ============================
  // 🔄 RESET PASSWORD (BY EMAIL)
  // ============================
  bool resetPassword(String email, String newPassword) {
    final box = Hive.box<UserModel>('users');

    try {
      final user = box.values.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      user.password = newPassword;
      user.save();

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================
  // 🔍 GET USER BY ID
  // ============================
  UserModel? getUserById(String id) {
    final box = Hive.box<UserModel>('users');

    try {
      return box.values.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
}
