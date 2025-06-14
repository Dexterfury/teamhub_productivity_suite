import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';

enum TaskStatus { todo, inProgress, completed }

class TaskModel {
  final String taskId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskStatus status;
  final String assigneeId;
  final String projectId;
  final String? createdById;
  final DateTime? createdAt;

  TaskModel({
    required this.taskId,
    required this.title,
    required this.description,
    this.dueDate,
    this.status = TaskStatus.todo,
    required this.assigneeId,
    required this.projectId,
    this.createdById,
    this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String taskId) {
    DateTime? dueDate;
    if (map[AppStrings.fieldDueDate] is Timestamp) {
      dueDate = (map[AppStrings.fieldDueDate] as Timestamp).toDate();
    } else if (map[AppStrings.fieldDueDate] is String) {
      dueDate = DateTime.tryParse(map[AppStrings.fieldDueDate] as String);
    }

    DateTime createdAt;
    if (map[AppStrings.fieldCreatedAt] == null) {
      createdAt = DateTime.now();
    } else if (map[AppStrings.fieldCreatedAt] is Timestamp) {
      createdAt = (map[AppStrings.fieldCreatedAt] as Timestamp).toDate();
    } else if (map[AppStrings.fieldCreatedAt] is String) {
      createdAt =
          DateTime.tryParse(map[AppStrings.fieldCreatedAt] as String) ??
          DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return TaskModel(
      taskId: taskId,
      title: map[AppStrings.fieldTitle] ?? '',
      description: map[AppStrings.fieldDescription] ?? '',
      dueDate: dueDate,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map[AppStrings.fieldStatus],
        orElse: () => TaskStatus.todo,
      ),
      assigneeId: map[AppStrings.fieldAssigneeId] ?? '',
      projectId: map[AppStrings.fieldTaskProjectId] ?? '',
      createdById: map[AppStrings.fieldCreatedById],
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      AppStrings.fieldTaskId:
          taskId, // Often not stored in the doc itself if taskId is doc ID
      AppStrings.fieldTitle: title,
      AppStrings.fieldDescription: description,
      AppStrings.fieldDueDate:
          dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      AppStrings.fieldStatus: status.toString().split('.').last,
      AppStrings.fieldAssigneeId: assigneeId,
      AppStrings.fieldTaskProjectId: projectId,
    };

    if (createdById != null) {
      map[AppStrings.fieldCreatedById] = createdById;
    }
    if (createdAt != null) {
      map[AppStrings.fieldCreatedAt] = Timestamp.fromDate(createdAt!);
    }
    return map;
  }

  // Copy with method to create a new instance with some fields modified
  TaskModel copyWith({
    String? taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    String? assigneeId,
    String? projectId,
    String? createdById,
    DateTime? createdAt,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      assigneeId: assigneeId ?? this.assigneeId,
      projectId: projectId ?? this.projectId,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
