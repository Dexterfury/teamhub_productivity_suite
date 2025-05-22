import 'package:flutter/material.dart';
import 'package:teamhub_productivity_suite/src/models/task_model.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';

class TasksScreen extends StatelessWidget {
  TasksScreen({super.key});

  // Placeholder data
  final List<TaskModel> placeholderTasks = [
    TaskModel(
      taskId: '1',
      title: AppStrings.placeholderTaskTitle,
      description: AppStrings.placeholderTaskDescription,
      assigneeId: 'user1',
      projectId: 'project1',
      createdById: 'user2',
      createdAt: DateTime.now(),
    ),
    TaskModel(
      taskId: '2',
      title: 'Implement Registration UI',
      description: 'Create the visual elements for the registration screen.',
      assigneeId: 'user2',
      projectId: 'project1',
      createdById: 'user1',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tasksTitle)),
      body: ListView.builder(
        itemCount: placeholderTasks.length,
        itemBuilder: (context, index) {
          final task = placeholderTasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(
              'Assignee: ${task.assigneeId} | Due: ${task.dueDate?.toLocal().toString().split(' ')[0] ?? 'N/A'} | Status: ${task.status.toString().split('.').last}',
            ),
            onTap: () {
              // TODO: Navigate to TaskDetailsScreen (if needed) or Edit Task screen
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tasksScreenFAB', // Add unique heroTag
        onPressed: () {
          context.go('/tasks/new');
        },
        tooltip: 'Create new task', // Added tooltip for consistency
        child: const Icon(Icons.add),
      ),
    );
  }
}
