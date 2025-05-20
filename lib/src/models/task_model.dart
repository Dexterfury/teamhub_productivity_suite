import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamhub_productivity_suite/src/utils/appstrings.dart';

enum TaskStatus {
  todo,
  inProgress,
  completed,
}

class TaskModel {
  final String taskId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskStatus status;
  final String assigneeId;
  final String projectId;
  final String createdById;
  final DateTime createdAt;

  TaskModel({
    required this.taskId,
    required this.title,
    required this.description,
    this.dueDate,
    this.status = TaskStatus.todo,
    required this.assigneeId,
    required this.projectId,
    required this.createdById,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String taskId) {
    DateTime? dueDate;
    if (map[AppStrings.fieldDueDate] is Timestamp) {
      dueDate = (map[AppStrings.fieldDueDate] as Timestamp).toDate();
    } else if (map[AppStrings.fieldDueDate] is String) {
      dueDate = DateTime.tryParse(map[AppStrings.fieldDueDate] as String);
    }

    DateTime createdAt;
     if (map[AppStrings.fieldCreatedAtTask] == null) {
      createdAt = DateTime.now();
    } else if (map[AppStrings.fieldCreatedAtTask] is Timestamp) {
      createdAt = (map[AppStrings.fieldCreatedAtTask] as Timestamp).toDate();
    } else if (map[AppStrings.fieldCreatedAtTask] is String) {
      createdAt = DateTime.tryParse(map[AppStrings.fieldCreatedAtTask] as String) ?? DateTime.now();
    }
     else {
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
      createdById: map[AppStrings.fieldCreatedById] ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppStrings.fieldTaskId: taskId, // Often not stored in the doc itself if taskId is doc ID
      AppStrings.fieldTitle: title,
      AppStrings.fieldDescription: description,
      AppStrings.fieldDueDate: dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      AppStrings.fieldStatus: status.toString().split('.').last,
      AppStrings.fieldAssigneeId: assigneeId,
      AppStrings.fieldTaskProjectId: projectId,
      AppStrings.fieldCreatedById: createdById,
      AppStrings.fieldCreatedAtTask: Timestamp.fromDate(createdAt),
    };
  }
}
