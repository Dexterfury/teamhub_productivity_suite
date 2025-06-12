import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _projectsCollection = FirebaseFirestore.instance
      .collection(AppStrings.collectionProjects);

  /// Fetches a single project by its ID.
  Future<ProjectModel?> getProject(String projectId) async {
    try {
      DocumentSnapshot doc = await _projectsCollection.doc(projectId).get();
      if (doc.exists) {
        return ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print("Error fetching project: $e");
      return null;
    }
  }

  /// Fetches a list of projects with filters matching the projects screen.
  ///
  /// [currentUserId]: Required. The ID of the current user.
  /// [filter]: The filter to apply (All, Recent, My Projects).
  /// [searchQuery]: Optional. Searches projects by name or description using search tokens.
  /// [recentDays]: Number of days to consider as "recent" (default: 14).
  Future<List<ProjectModel>> getProjects({
    required String currentUserId,
    ProjectFilter filter = ProjectFilter.all,
    String? searchQuery,
    int recentDays = 14,
  }) async {
    try {
      Query<Object?> query = _projectsCollection;

      // Apply base filter based on the selected filter type
      switch (filter) {
        case ProjectFilter.all:
          // Show all projects where currentUserId is in memberIds
          query = query.where(
            AppStrings.fieldMemberIds,
            arrayContains: currentUserId,
          );
          break;

        case ProjectFilter.recent:
          // Show recent projects where currentUserId is in memberIds
          final recentDate = DateTime.now().subtract(
            Duration(days: recentDays),
          );
          query = query
              .where(AppStrings.fieldMemberIds, arrayContains: currentUserId)
              .where(
                AppStrings.fieldCreatedAt,
                isGreaterThan: Timestamp.fromDate(recentDate),
              );
          break;

        case ProjectFilter.myProjects:
          // Show projects created by currentUserId
          query = query.where(
            AppStrings.fieldCreatedById,
            isEqualTo: currentUserId,
          );
          break;
      }

      // Order by creation date (newest first)
      query = query.orderBy(AppStrings.fieldCreatedAt, descending: true);

      QuerySnapshot snapshot = await query.get();
      List<ProjectModel> projects =
          snapshot.docs
              .map(
                (doc) => ProjectModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        projects = _filterProjectsBySearch(projects, searchQuery);
      }

      return projects;
    } catch (e) {
      print("Error fetching projects: $e");
      return [];
    }
  }

  /// Filters projects by search query using search tokens for better performance.
  List<ProjectModel> _filterProjectsBySearch(
    List<ProjectModel> projects,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return projects;

    final searchLower = searchQuery.toLowerCase().trim();

    return projects.where((project) {
      // Check if any search token starts with the search query
      for (final token in project.searchTokens) {
        if (token.contains(searchLower)) {
          return true;
        }
      }

      // Fallback to direct text matching
      return project.projectName.toLowerCase().contains(searchLower) ||
          project.projectDescription.toLowerCase().contains(searchLower);
    }).toList();
  }

  /// Alternative method for direct search without pre-filtering by user
  /// Useful for admin views or global search
  Future<List<ProjectModel>> searchProjects({
    String? searchQuery,
    String? createdById,
  }) async {
    try {
      Query<Object?> query = _projectsCollection;

      if (createdById != null && createdById.isNotEmpty) {
        query = query.where(
          AppStrings.fieldCreatedById,
          isEqualTo: createdById,
        );
      }

      // If we have search tokens in Firestore, we can use array-contains-any for better performance
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTokens = ProjectModel.generateSearchTokens(searchQuery, '');
        if (searchTokens.isNotEmpty) {
          // Use the first few tokens for Firestore query (Firestore has limits on array-contains-any)
          final queryTokens = searchTokens.take(10).toList();
          query = query.where(
            AppStrings.fieldSearchTokens,
            arrayContainsAny: queryTokens,
          );
        }
      }

      query = query.orderBy(AppStrings.fieldCreatedAt, descending: true);

      QuerySnapshot snapshot = await query.get();
      List<ProjectModel> projects =
          snapshot.docs
              .map(
                (doc) => ProjectModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

      // Additional client-side filtering for more precise search
      if (searchQuery != null && searchQuery.isNotEmpty) {
        projects = _filterProjectsBySearch(projects, searchQuery);
      }

      return projects;
    } catch (e) {
      print("Error searching projects: $e");
      return [];
    }
  }

  /// Creates a new project in Firestore.
  Future<void> createProject(ProjectModel project) async {
    try {
      await _projectsCollection.doc(project.projectId).set(project.toMap());
      print('Project created successfully: ${project.projectName}');
    } catch (e) {
      print("Error creating project: $e");
      rethrow;
    }
  }

  /// Updates an existing project in Firestore.
  /// Automatically regenerates search tokens if name or description changed.
  Future<void> updateProject(ProjectModel project) async {
    try {
      // Ensure search tokens are up to date
      final updatedProject = ProjectModel(
        projectId: project.projectId,
        projectName: project.projectName,
        projectDescription: project.projectDescription,
        memberIds: project.memberIds,
        createdById: project.createdById,
        createdAt: project.createdAt,
      );

      await _projectsCollection
          .doc(project.projectId)
          .update(updatedProject.toMap());
      print('Project updated successfully: ${project.projectName}');
    } catch (e) {
      print("Error updating project: $e");
      rethrow;
    }
  }

  /// Deletes a project from Firestore by its ID.
  Future<void> deleteProject(String projectId) async {
    try {
      await _projectsCollection.doc(projectId).delete();
      print('Project deleted successfully: $projectId');
    } catch (e) {
      print("Error deleting project: $e");
      rethrow;
    }
  }

  /// Updates the member list of a project
  Future<void> updateProjectMembers(
    String projectId,
    List<String> memberIds,
  ) async {
    try {
      await _projectsCollection.doc(projectId).update({
        AppStrings.fieldMemberIds: memberIds,
      });
      print('Project members updated successfully: $projectId');
    } catch (e) {
      print("Error updating project members: $e");
      rethrow;
    }
  }

  /// Gets projects where the user is a member (for notifications, etc.)
  Future<List<ProjectModel>> getProjectsForUser(String userId) async {
    try {
      QuerySnapshot snapshot =
          await _projectsCollection
              .where(AppStrings.fieldMemberIds, arrayContains: userId)
              .orderBy(AppStrings.fieldCreatedAt, descending: true)
              .get();

      return snapshot.docs
          .map(
            (doc) => ProjectModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print("Error fetching user projects: $e");
      return [];
    }
  }
}
