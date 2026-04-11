import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final box = Hive.box<UserModel>('users');

  // ✅ ACTIVE USERS ONLY
  List<UserModel> get users =>
      box.values.where((u) => u.isDeleted == false).toList();

  // ♻️ RECYCLE BIN USERS
  List<UserModel> get deletedUsers =>
      box.values.where((u) => u.isDeleted == true).toList();

  // ➕ ADD USER
  void addUser(String name, String email, String password, String role) {
    final user = UserModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      password: password,
      role: role,
      createdAt: DateTime.now(),
      isDeleted: false, // ✅ always active
    );

    box.add(user);
    notifyListeners();
  }

  // ♻️ SOFT DELETE (MOVE TO RECYCLE BIN)
  void deleteUser(UserModel user) {
    user.isDeleted = true;
    user.save(); // 🔥 important for Hive
    notifyListeners();
  }

  // 🔄 RESTORE USER
  void restoreUser(UserModel user) {
    user.isDeleted = false;
    user.save();
    notifyListeners();
  }

  // ❌ PERMANENT DELETE
  void permanentDelete(UserModel user) {
    user.delete(); // Hive permanent delete
    notifyListeners();
  }
}
