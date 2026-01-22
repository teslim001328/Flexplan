import 'package:uuid/uuid.dart';

enum TaskStatus { pending, done, missed }

class MicroTask {
  final String id;
  final String description;
  final DateTime scheduledDate;
  TaskStatus status;

  MicroTask({
    String? id,
    required this.description,
    required this.scheduledDate,
    this.status = TaskStatus.pending,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'status': status.name,
    };
  }

  factory MicroTask.fromMap(Map<String, dynamic> map) {
    return MicroTask(
      id: map['id'],
      description: map['description'],
      scheduledDate: DateTime.parse(map['scheduledDate']),
      status: TaskStatus.values.byName(map['status']),
    );
  }
}
