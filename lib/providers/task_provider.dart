import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../data/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final Box<TaskModel> box = Hive.box<TaskModel>('tasks');

  // 📋 ALL TASKS
  List<TaskModel> get tasks => box.values.toList();

  // ➕ ADD TASK
  void addTask(String title, String userId) {
    if (title.trim().isEmpty) return;

    final task = TaskModel(
      id: const Uuid().v4(),
      title: title.trim(),
      userId: userId,
      createdAt: DateTime.now(),
    );

    box.add(task);
    notifyListeners();
  }

  // ✅ TOGGLE TASK STATUS
  void toggleTask(TaskModel task) {
    task.isDone = !task.isDone;
    task.save();
    notifyListeners();
  }

  // ❌ DELETE TASK
  void deleteTask(TaskModel task) {
    task.delete();
    notifyListeners();
  }

  // ============================
  // 📊 DASHBOARD STATS
  // ============================

  int get totalTasks => box.length;

  int get completedTasks => box.values.where((task) => task.isDone).length;

  int get pendingTasks => box.values.where((task) => !task.isDone).length;

  int get deletedTasks => 0; // (future feature)

  // ============================
  // 🧑 USER TASKS
  // ============================

  List<TaskModel> getUserTasks(String userId) {
    return box.values.where((task) => task.userId == userId).toList();
  }

  // ============================
  // 🕒 RECENT ACTIVITY
  // ============================

  List<TaskModel> get recentTasks {
    final list = box.values.toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list.take(5).toList();
  }
}
