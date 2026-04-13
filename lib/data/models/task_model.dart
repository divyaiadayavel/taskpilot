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
  String? description;

  /// 🔥 PRIORITY
  @HiveField(6)
  String? priority;

  /// 📅 DUE DATE
  @HiveField(7)
  DateTime? dueDate;

  /// 📎 ATTACHMENT FILE NAME
  @HiveField(8)
  String? fileName;

  /// 📎 ATTACHMENT FILE PATH / URL
  @HiveField(9)
  String? fileUrl;

  /// ✅ COMPLETION TIME
  @HiveField(10)
  DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    this.isDone = false,
    this.description,
    this.priority,
    this.dueDate,
    this.fileName,
    this.fileUrl,
    this.completedAt,
  });
}
