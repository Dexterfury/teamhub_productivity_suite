import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamhub_productivity_suite/src/utils/appstrings.dart';

class ProjectModel {
  final String projectId;
  final String projectName;
  final String projectDescription;
  final List<String> memberIds;
  final String createdById;
  final DateTime createdAt;

  ProjectModel({
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    this.memberIds = const [],
    required this.createdById,
    required this.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, String projectId) {
     DateTime createdAt;
     if (map[AppStrings.fieldCreatedAtProject] == null) {
      createdAt = DateTime.now();
    } else if (map[AppStrings.fieldCreatedAtProject] is Timestamp) {
      createdAt = (map[AppStrings.fieldCreatedAtProject] as Timestamp).toDate();
    } else if (map[AppStrings.fieldCreatedAtProject] is String) {
      createdAt = DateTime.tryParse(map[AppStrings.fieldCreatedAtProject] as String) ?? DateTime.now();
    }
     else {
      createdAt = DateTime.now();
    }

    return ProjectModel(
      projectId: projectId,
      projectName: map[AppStrings.fieldProjectName] ?? '',
      projectDescription: map[AppStrings.fieldProjectDescription] ?? '',
      memberIds: List<String>.from(map[AppStrings.fieldMemberIds] ?? []),
      createdById: map[AppStrings.fieldCreatedByProjectId] ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppStrings.fieldProjectProjectId: projectId, // Often not stored in the doc itself if projectId is doc ID
      AppStrings.fieldProjectName: projectName,
      AppStrings.fieldProjectDescription: projectDescription,
      AppStrings.fieldMemberIds: memberIds,
      AppStrings.fieldCreatedByProjectId: createdById,
      AppStrings.fieldCreatedAtProject: Timestamp.fromDate(createdAt),
    };
  }
}
