import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:math';

import '../data/models/user_model.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  bool get isAdmin => _currentUser?.role == 'admin';

  bool get isUser => _currentUser?.role == 'user';

  // 🔐 OTP VARIABLES
  String? _otp;
  String? _otpEmail;

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
  // 🔥 LOGIN WITH REMEMBER ME
  // ============================
  Future<bool> loginWithRemember(
    String email,
    String password,
    bool rememberMe,
  ) async {
    final success = await login(email, password);

    if (success) {
      final settingsBox = Hive.box('settings');

      if (rememberMe) {
        await settingsBox.put('rememberEmail', email);
        await settingsBox.put('rememberPassword', password);
      } else {
        await settingsBox.delete('rememberEmail');
        await settingsBox.delete('rememberPassword');
      }
    }

    return success;
  }

  // ============================
  // 📥 GET REMEMBERED USER
  // ============================
  Map<String, String?> getRememberedUser() {
    final settingsBox = Hive.box('settings');

    return {
      'email': settingsBox.get('rememberEmail'),
      'password': settingsBox.get('rememberPassword'),
    };
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
  // 🔐 SEND OTP (EMAIL)
  // ============================
  Future<bool> sendOtpEmail(String email) async {
    final box = Hive.box<UserModel>('users');

    try {
      final user = box.values.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      // 🔥 GENERATE OTP
      final random = Random();
      _otp = (100000 + random.nextInt(900000)).toString();
      _otpEmail = user.email;

      // 🔐 EMAIL CONFIG
      const username = 'divyaidayavel2001@gmail.com';
      const password = 'dobt wzzc ugli xlum';

      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'TaskPilot App')
        ..recipients.add(email)
        ..subject = 'Password Reset OTP'
        ..text = 'Your OTP is $_otp';

      try {
        await send(message, smtpServer);
        print("OTP sent: $_otp");
        return true;
      } catch (e) {
        print("Email failed: $e");
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // ============================
  // 🔐 VERIFY OTP
  // ============================
  bool verifyOtp(String email, String otp) {
    return _otp == otp && _otpEmail == email;
  }

  // ============================
  // 🔄 RESET PASSWORD
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

      _otp = null;
      _otpEmail = null;

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
