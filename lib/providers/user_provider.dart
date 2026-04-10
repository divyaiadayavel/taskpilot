import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final box = Hive.box<UserModel>('users');

  List<UserModel> get users => box.values.toList();

  // ➕ ADD USER
  void addUser(String name, String email, String password, String role) {
    final user = UserModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      password: password,
      role: role,
      createdAt: DateTime.now(), // ✅ REQUIRED FIX
    );

    box.add(user);
    notifyListeners();
  }

  // ❌ DELETE USER (🔥 THIS FIXES YOUR ERROR)
  void deleteUser(UserModel user) {
    user.delete(); // HiveObject method
    notifyListeners();
  }
}
