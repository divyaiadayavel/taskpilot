import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import '../data/models/task_model.dart';
import 'activity_provider.dart';

class TaskProvider extends ChangeNotifier {
  final Box<TaskModel> box = Hive.box<TaskModel>('tasks');

  /// 🗑 STORE DELETED COUNT
  final Box settingsBox = Hive.box('settings');

  int get _deletedTasks => settingsBox.get('deletedTasks', defaultValue: 0);

  /// 📋 ALL TASKS
  List<TaskModel> get tasks => box.values.toList();

  // ===================================================
  // ➕ ADD TASK
  // ===================================================
  void addTask(
    String title,
    String userId,
    BuildContext context, {
    String? fileName,
    String? fileUrl,
    DateTime? dueDate,
    String? priority,
    String? description,
  }) {
    if (title.trim().isEmpty) return;

    final task = TaskModel(
      id: const Uuid().v4(),
      title: title.trim(),
      userId: userId,
      createdAt: DateTime.now(),
      isDone: false,
      fileName: fileName,
      fileUrl: fileUrl,
      dueDate: dueDate,
      priority: priority,
      description: description,
    );

    box.add(task);

    Provider.of<ActivityProvider>(
      context,
      listen: false,
    ).addActivity(userId: userId, action: "added", taskTitle: title.trim());

    notifyListeners();
  }

  // ===================================================
  // ✅ COMPLETE / PENDING TOGGLE
  // ===================================================
  void toggleTask(TaskModel task, BuildContext context) {
    task.isDone = !task.isDone;
    task.save();

    if (task.isDone) {
      Provider.of<ActivityProvider>(context, listen: false).addActivity(
        userId: task.userId,
        action: "completed",
        taskTitle: task.title,
      );
    }

    notifyListeners();
  }

  // ===================================================
  // ❌ DELETE SINGLE TASK
  // ===================================================
  void deleteTask(TaskModel task, BuildContext context) {
    Provider.of<ActivityProvider>(context, listen: false).addActivity(
      userId: task.userId,
      action: "deleted",
      taskTitle: task.title,
    );

    task.delete();

    settingsBox.put('deletedTasks', _deletedTasks + 1);

    notifyListeners();
  }

  // ===================================================
  // ❌ DELETE ALL TASKS OF USER
  // ===================================================
  void deleteTasksByUser(String userId) {
    final userTasks = box.values
        .where((task) => task.userId == userId)
        .toList();

    for (final task in userTasks) {
      task.delete();
      settingsBox.put('deletedTasks', _deletedTasks + 1);
    }

    notifyListeners();
  }

  // ===================================================
  // 📊 DASHBOARD COUNTS
  // ===================================================

  /// Total active tasks
  int get totalTasks => box.length;

  /// Completed tasks
  int get completedTasks => box.values.where((task) => task.isDone).length;

  /// Pending tasks
  int get pendingTasks => box.values.where((task) => !task.isDone).length;

  /// Deleted tasks count
  int get deletedTasks => _deletedTasks;

  // ===================================================
  // 👤 USER TASK FILTER
  // ===================================================
  List<TaskModel> getUserTasks(String userId, String filter) {
    List<TaskModel> userTasks = box.values
        .where((task) => task.userId == userId)
        .toList();

    if (filter == "Pending") {
      return userTasks.where((task) => !task.isDone).toList();
    }

    if (filter == "Completed") {
      return userTasks.where((task) => task.isDone).toList();
    }

    return userTasks;
  }

  // ===================================================
  // 🕒 RECENT TASKS
  // ===================================================
  List<TaskModel> get recentTasks {
    final list = box.values.toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list.take(5).toList();
  }
}
