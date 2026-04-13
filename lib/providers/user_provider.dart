import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final box = Hive.box<UserModel>('users');

  List<UserModel> get users =>
      box.values.where((u) => u.isDeleted == false).toList();

  List<UserModel> get deletedUsers =>
      box.values.where((u) => u.isDeleted == true).toList();

  /// ✅ UPDATED: Accepts optional profileImage and RETURNS the user object
  UserModel addUser(
    String name,
    String email,
    String password,
    String role, {
    String? profileImage,
  }) {
    final user = UserModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      password: password,
      role: role,
      createdAt: DateTime.now(),
      isDeleted: false,
      profileImage: profileImage, // ✅ Set the image path here
    );

    box.add(user);
    notifyListeners();

    return user; // ✅ Return the user so we can pass it to the success screen
  }

  void deleteUser(UserModel user) {
    user.isDeleted = true;
    user.save();
    notifyListeners();
  }

  void restoreUser(UserModel user) {
    user.isDeleted = false;
    user.save();
    notifyListeners();
  }

  void permanentDelete(UserModel user) {
    user.delete();
    notifyListeners();
  }

  /// ✅ UPDATE PROFILE IMAGE
  Future<void> updateProfileImage(UserModel user, String imagePath) async {
    user.profileImage = imagePath;
    await user.save();
    notifyListeners();
  }
}
