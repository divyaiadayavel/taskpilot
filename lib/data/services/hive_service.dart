import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';
import '../models/task_model.dart';

class HiveService {
  // 🔥 INIT HIVE
  static Future<void> init() async {
    await Hive.initFlutter();

    // 🔥 REGISTER ADAPTERS (SAFE)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskModelAdapter());
    }

    // 🔥 OPEN BOXES (ONLY IF NOT OPEN)
    if (!Hive.isBoxOpen('users')) {
      await Hive.openBox<UserModel>('users');
    }

    if (!Hive.isBoxOpen('tasks')) {
      await Hive.openBox<TaskModel>('tasks');
    }

    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
  }

  // 🔥 SAFE CLEAR (USE FOR RESET ONLY)
  static Future<void> clearAll() async {
    // ❗ Close boxes before deleting
    if (Hive.isBoxOpen('users')) await Hive.box('users').close();
    if (Hive.isBoxOpen('tasks')) await Hive.box('tasks').close();
    if (Hive.isBoxOpen('settings')) await Hive.box('settings').close();

    // ❗ Delete from disk (safe reset)
    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('tasks');
    await Hive.deleteBoxFromDisk('settings');
  }

  // 🚪 CLOSE ALL
  static Future<void> close() async {
    await Hive.close();
  }
}
