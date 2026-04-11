import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../data/models/activity_model.dart';

class ActivityProvider extends ChangeNotifier {
  final Box<ActivityModel> box = Hive.box<ActivityModel>('activities');

  List<ActivityModel> get activities {
    final list = box.values.toList();
    list.sort((a, b) => b.time.compareTo(a.time));
    return list;
  }

  void addActivity({
    required String userId,
    required String action,
    required String taskTitle,
  }) {
    final activity = ActivityModel(
      id: const Uuid().v4(),
      userId: userId,
      action: action,
      taskTitle: taskTitle,
      time: DateTime.now(),
    );

    box.add(activity);
    notifyListeners();
  }
}
