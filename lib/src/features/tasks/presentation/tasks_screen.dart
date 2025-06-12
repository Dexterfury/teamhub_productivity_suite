import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/task_model.dart';
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart';
import 'package:teamhub_productivity_suite/src/services/task_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late Future<List<TaskModel>> _tasksFuture;
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() {
    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    final currentUserId = authProvider.appUser?.uid;

    if (currentUserId != null) {
      _tasksFuture = Future.wait([
        _taskService.getTasks(assigneeId: currentUserId),
        _taskService.getTasks(createdById: currentUserId),
      ]).then((lists) {
        final allTasks = [...lists[0], ...lists[1]];
        // Remove duplicates based on taskId
        final uniqueTasks = <String, TaskModel>{};
        for (var task in allTasks) {
          uniqueTasks[task.taskId] = task;
        }
        return uniqueTasks.values.toList();
      });
    } else {
      _tasksFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final currentUser = authProvider.appUser;
    final isManager = currentUser?.roles.isManager ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tasksTitle)),
      body: FutureBuilder<List<TaskModel>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text(AppStrings.noTasksFound));
          } else {
            final tasks = snapshot.data!;
            // Filter tasks where current user is creator or assignee
            final filteredTasks =
                tasks.where((task) {
                  return task.assigneeId == currentUser?.uid ||
                      task.createdById == currentUser?.uid;
                }).toList();

            if (filteredTasks.isEmpty) {
              return const Center(child: Text(AppStrings.noTasksFound));
            }

            return ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(
                    'Assignee: ${task.assigneeId} | Due: ${task.dueDate?.toLocal().toString().split(' ')[0] ?? 'N/A'} | Status: ${task.status.toString().split('.').last}',
                  ),
                  onTap: () {
                    context.go('/tasks/edit/${task.taskId}');
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton:
          isManager
              ? FloatingActionButton(
                heroTag: 'tasks_fab',
                onPressed: () {
                  context.go('/tasks/new');
                },
                tooltip: 'Create new task',
                child: const Icon(Icons.add),
              )
              : null, // Hide FAB if not a manager
    );
  }
}
