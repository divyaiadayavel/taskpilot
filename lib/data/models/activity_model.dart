import 'package:hive/hive.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 3)
class ActivityModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String action; // added / completed / deleted

  @HiveField(3)
  String taskTitle;

  @HiveField(4)
  DateTime time;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.taskTitle,
    required this.time,
  });

  /// ✅ Formatted Date
  String get formattedDate {
    return "${time.day}-${time.month}-${time.year}";
  }

  /// ✅ Formatted Time
  String get formattedTime {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  /// ✅ Full Date Time
  String get formattedDateTime {
    return "$formattedDate  $formattedTime";
  }
}
