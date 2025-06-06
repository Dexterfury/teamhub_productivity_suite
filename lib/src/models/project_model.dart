import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';

enum ProjectFilter { all, recent, myProjects }

enum ProjectStatus { active, archived, completed }

class ProjectModel {
  final String projectId;
  final String projectName;
  final String projectDescription;
  final List<String> memberIds;
  final String createdById;
  final DateTime createdAt;
  final ProjectStatus status;
  final List<String> searchTokens;

  ProjectModel({
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    this.memberIds = const [],
    required this.createdById,
    required this.createdAt,
    this.status = ProjectStatus.active,
    List<String>? searchTokens,
  }) : searchTokens =
           searchTokens ??
           generateSearchTokens(projectName, projectDescription);

  factory ProjectModel.fromMap(Map<String, dynamic> map, String projectId) {
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

    return ProjectModel(
      projectId: projectId,
      projectName: map[AppStrings.fieldProjectName] ?? '',
      projectDescription: map[AppStrings.fieldProjectDescription] ?? '',
      memberIds: List<String>.from(map[AppStrings.fieldMemberIds] ?? []),
      createdById: map[AppStrings.fieldCreatedBy] ?? '',
      createdAt: createdAt,
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString() == map[AppStrings.fieldProjectStatus],
        orElse: () => ProjectStatus.active,
      ),
      searchTokens: List<String>.from(map[AppStrings.fieldSearchTokens] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppStrings.fieldProjectProjectId:
          projectId, // Often not stored in the doc itself if projectId is doc ID
      AppStrings.fieldProjectName: projectName,
      AppStrings.fieldProjectDescription: projectDescription,
      AppStrings.fieldMemberIds: memberIds,
      AppStrings.fieldCreatedBy: createdById,
      AppStrings.fieldCreatedAt: Timestamp.fromDate(createdAt),
      AppStrings.fieldProjectStatus: status.name.toString(),
      AppStrings.fieldSearchTokens: searchTokens,
    };
  }

  // Generate search tokens from project name and description
  static List<String> generateSearchTokens(String name, String description) {
    final tokens = <String>{};

    // Add tokens from project name
    _addTokensFromText(name, tokens);

    // Add tokens from description
    _addTokensFromText(description, tokens);

    return tokens.toList();
  }

  static void _addTokensFromText(String text, Set<String> tokens) {
    if (text.isEmpty) return;

    final cleanText = text.toLowerCase().trim();
    final words = cleanText.split(RegExp(r'\s+'));

    for (final word in words) {
      if (word.isNotEmpty) {
        // Add the full word
        tokens.add(word);

        // Add prefixes for partial matching (minimum 2 characters)
        for (int i = 2; i <= word.length; i++) {
          tokens.add(word.substring(0, i));
        }
      }
    }

    // Add the full cleaned text for phrase matching
    tokens.add(cleanText);
  }
}
