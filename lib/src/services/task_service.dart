import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _tasksCollection = FirebaseFirestore.instance
      .collection(AppStrings.collectionTasks);

  /// Fetches a single task by its ID.
  Future<TaskModel?> getTask(String taskId) async {
    try {
      DocumentSnapshot doc = await _tasksCollection.doc(taskId).get();
      if (doc.exists) {
        return TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print("Error fetching task: $e");
      return null;
    }
  }

  /// Fetches a list of tasks with optional filters.
  ///
  /// [projectId]: Optional. Filters tasks by a specific project.
  /// [assigneeId]: Optional. Filters tasks by a specific assignee.
  /// [status]: Optional. Filters tasks by a specific status (e.g., 'todo', 'inProgress', 'completed').
  /// [searchQuery]: Optional. Searches tasks by title or description.
  Future<List<TaskModel>> getTasks({
    String? projectId,
    String? assigneeId,
    String? status,
    String? searchQuery,
  }) async {
    try {
      Query<Object?> query = _tasksCollection;

      if (projectId != null && projectId.isNotEmpty) {
        query = query.where(
          AppStrings.fieldTaskProjectId,
          isEqualTo: projectId,
        );
      }
      if (assigneeId != null && assigneeId.isNotEmpty) {
        query = query.where(AppStrings.fieldAssigneeId, isEqualTo: assigneeId);
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        query = query.where(AppStrings.fieldStatus, isEqualTo: status);
      }

      // For search, we'll fetch all relevant tasks and then filter in-memory
      // or use a more advanced search solution (e.g., Algolia, Cloud Functions)
      // For now, a simple client-side filter for demonstration.
      QuerySnapshot snapshot = await query.get();
      List<TaskModel> tasks =
          snapshot.docs
              .map(
                (doc) => TaskModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        String searchLower = searchQuery.toLowerCase();
        tasks =
            tasks.where((task) {
              return task.title.toLowerCase().contains(searchLower) ||
                  task.description.toLowerCase().contains(searchLower);
            }).toList();
      }

      return tasks;
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

  /// Creates a new task in Firestore.
  Future<void> createTask(TaskModel task) async {
    try {
      await _tasksCollection.doc(task.taskId).set(task.toMap());
      print('Task created successfully: ${task.title}');
    } catch (e) {
      print("Error creating task: $e");
      rethrow;
    }
  }

  /// Updates an existing task in Firestore.
  Future<void> updateTask(TaskModel task) async {
    try {
      await _tasksCollection.doc(task.taskId).update(task.toMap());
      print('Task updated successfully: ${task.title}');
    } catch (e) {
      print("Error updating task: $e");
      rethrow;
    }
  }

  /// Deletes a task from Firestore by its ID.
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
      print('Task deleted successfully: $taskId');
    } catch (e) {
      print("Error deleting task: $e");
      rethrow;
    }
  }
}
