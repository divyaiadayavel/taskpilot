import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import '../data/models/task_model.dart';
import 'activity_provider.dart'; // ✅ ADD THIS

class TaskProvider extends ChangeNotifier {
  final Box<TaskModel> box = Hive.box<TaskModel>('tasks');

  // 📋 ALL TASKS
  List<TaskModel> get tasks => box.values.toList();

  // ➕ ADD TASK
  void addTask(String title, String userId, BuildContext context) {
    if (title.trim().isEmpty) return;

    final task = TaskModel(
      id: const Uuid().v4(),
      title: title.trim(),
      userId: userId,
      createdAt: DateTime.now(),
      isDone: false,
    );

    box.add(task);

    /// 🔥 ADD ACTIVITY
    Provider.of<ActivityProvider>(
      context,
      listen: false,
    ).addActivity(userId: userId, action: "added", taskTitle: title.trim());

    notifyListeners();
  }

  // ✅ TOGGLE TASK STATUS
  void toggleTask(TaskModel task, BuildContext context) {
    task.isDone = !task.isDone;
    task.save();

    /// 🔥 ADD ACTIVITY (ONLY WHEN COMPLETED)
    if (task.isDone) {
      Provider.of<ActivityProvider>(context, listen: false).addActivity(
        userId: task.userId,
        action: "completed",
        taskTitle: task.title,
      );
    }

    notifyListeners();
  }

  // ❌ DELETE TASK
  void deleteTask(TaskModel task, BuildContext context) {
    /// 🔥 ADD ACTIVITY BEFORE DELETE
    Provider.of<ActivityProvider>(context, listen: false).addActivity(
      userId: task.userId,
      action: "deleted",
      taskTitle: task.title,
    );

    task.delete();
    notifyListeners();
  }

  // ============================
  // 📊 DASHBOARD STATS
  // ============================

  int get totalTasks => box.length;

  int get completedTasks => box.values.where((task) => task.isDone).length;

  int get pendingTasks => box.values.where((task) => !task.isDone).length;

  int get deletedTasks => 0; // future feature

  // ============================
  // 🧑 USER TASKS WITH FILTER
  // ============================

  List<TaskModel> getUserTasks(String userId, String filter) {
    List<TaskModel> userTasks = box.values
        .where((task) => task.userId == userId)
        .toList();

    if (filter == "Pending") {
      return userTasks.where((task) => !task.isDone).toList();
    } else if (filter == "Completed") {
      return userTasks.where((task) => task.isDone).toList();
    }

    return userTasks;
  }

  // ============================
  // 🕒 RECENT TASKS (OPTIONAL)
  // ============================

  List<TaskModel> get recentTasks {
    final list = box.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(5).toList();
  }
}
