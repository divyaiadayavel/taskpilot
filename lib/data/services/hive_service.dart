import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/activity_model.dart';

class HiveService {
  // 🔥 INIT HIVE
  static Future<void> init() async {
    await Hive.initFlutter();

    /// 🔥 REGISTER ADAPTERS

    // ✅ UserModel → typeId: 1
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // ✅ TaskModel → typeId: 2
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TaskModelAdapter());
    }

    // ✅ ActivityModel → typeId: 3 (NEW)
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ActivityModelAdapter());
    }

    /// 🔥 OPEN BOXES

    if (!Hive.isBoxOpen('users')) {
      await Hive.openBox<UserModel>('users');
    }

    if (!Hive.isBoxOpen('tasks')) {
      await Hive.openBox<TaskModel>('tasks');
    }

    if (!Hive.isBoxOpen('activities')) {
      await Hive.openBox<ActivityModel>('activities'); // ✅ NEW
    }

    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
  }

  // 🔥 SAFE CLEAR (RESET APP DATA)
  static Future<void> clearAll() async {
    if (Hive.isBoxOpen('users')) await Hive.box('users').close();
    if (Hive.isBoxOpen('tasks')) await Hive.box('tasks').close();
    if (Hive.isBoxOpen('activities'))
      await Hive.box('activities').close(); // ✅ NEW
    if (Hive.isBoxOpen('settings')) await Hive.box('settings').close();

    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('tasks');
    await Hive.deleteBoxFromDisk('activities'); // ✅ NEW
    await Hive.deleteBoxFromDisk('settings');
  }

  // 🚪 CLOSE ALL
  static Future<void> close() async {
    await Hive.close();
  }
}
