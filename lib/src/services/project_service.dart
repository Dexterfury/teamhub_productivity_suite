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

  /// Fetches a list of projects with optional filters.
  ///
  /// [createdById]: Optional. Filters projects by the ID of the user who created them.
  /// [searchQuery]: Optional. Searches projects by name or description.
  Future<List<ProjectModel>> getProjects({
    String? createdById,
    String? searchQuery,
  }) async {
    try {
      Query<Object?> query = _projectsCollection;

      if (createdById != null && createdById.isNotEmpty) {
        query = query.where(AppStrings.fieldCreatedBy, isEqualTo: createdById);
      }

      // For search, we'll fetch all relevant projects and then filter in-memory
      // or use a more advanced search solution (e.g., Algolia, Cloud Functions)
      // For now, a simple client-side filter for demonstration.
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

      if (searchQuery != null && searchQuery.isNotEmpty) {
        String searchLower = searchQuery.toLowerCase();
        projects =
            projects.where((project) {
              return project.projectName.toLowerCase().contains(searchLower) ||
                  project.projectDescription.toLowerCase().contains(
                    searchLower,
                  );
            }).toList();
      }

      return projects;
    } catch (e) {
      print("Error fetching projects: $e");
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
  Future<void> updateProject(ProjectModel project) async {
    try {
      await _projectsCollection.doc(project.projectId).update(project.toMap());
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
}
