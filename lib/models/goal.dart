import 'package:flexplan/models/micro_task.dart';
import 'package:uuid/uuid.dart';

class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<MicroTask> tasks;
  final String userId;

  Goal({
    String? id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.tasks,
    required this.userId,
  }) : id = id ?? const Uuid().v4();

  double get progress {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((t) => t.status == TaskStatus.done).length;
    return completed / tasks.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'userId': userId,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      tasks: (map['tasks'] as List).map((t) => MicroTask.fromMap(t)).toList(),
      userId: map['userId'],
    );
  }
}
