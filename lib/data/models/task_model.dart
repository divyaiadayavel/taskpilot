import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 2)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isDone;

  @HiveField(3)
  String userId;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String? description; // ✅ ADD THIS

  TaskModel({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    this.isDone = false,
    this.description,
  });
}
