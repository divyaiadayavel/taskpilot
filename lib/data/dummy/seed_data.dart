import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../models/task_model.dart';

class SeedData {
  static final _uuid = Uuid();

  // 🔥 MAIN SEED FUNCTION
  static Future<void> seedAll() async {
    await seedUsers();
    await seedTasks();
  }

  // 👤 SEED USERS
  static Future<void> seedUsers() async {
    final box = Hive.box<UserModel>('users');

    // ❌ Prevent duplicate seeding
    if (box.isNotEmpty) return;

    final admin = UserModel(
      id: _uuid.v4(),
      name: "Divya",
      email: "divyabharathi@catalystack.com",
      password: "Rdivya@0108",
      role: "admin",
      createdAt: DateTime.now(),
    );

    final user1 = UserModel(
      id: _uuid.v4(),
      name: "Sarah Green",
      email: "sarah@mail.com",
      password: "123456",
      role: "user",
      createdAt: DateTime.now(),
    );

    final user2 = UserModel(
      id: _uuid.v4(),
      name: "Michael Turner",
      email: "michael@mail.com",
      password: "123456",
      role: "user",
      createdAt: DateTime.now(),
    );

    await box.addAll([admin, user1, user2]);
  }

  // 📋 SEED TASKS
  static Future<void> seedTasks() async {
    final taskBox = Hive.box<TaskModel>('tasks');
    final userBox = Hive.box<UserModel>('users');

    // ❌ Prevent duplicate seeding
    if (taskBox.isNotEmpty) return;

    // 👉 Get first normal user
    final users = userBox.values.where((u) => u.role == 'user').toList();

    if (users.isEmpty) return;

    final userId = users.first.id;

    final tasks = [
      TaskModel(
        id: _uuid.v4(),
        title: "Weekly grocery shopping",
        isDone: false,
        userId: userId,
        createdAt: DateTime.now(),
      ),
      TaskModel(
        id: _uuid.v4(),
        title: "Prepare for meeting",
        isDone: true,
        userId: userId,
        createdAt: DateTime.now(),
      ),
      TaskModel(
        id: _uuid.v4(),
        title: "Walk the dog",
        isDone: false,
        userId: userId,
        createdAt: DateTime.now(),
      ),
      TaskModel(
        id: _uuid.v4(),
        title: "Doctor appointment",
        isDone: true,
        userId: userId,
        createdAt: DateTime.now(),
      ),
    ];

    await taskBox.addAll(tasks);
  }
}
