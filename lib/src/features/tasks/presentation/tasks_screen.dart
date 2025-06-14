import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/task_model.dart';
import 'package:teamhub_productivity_suite/src/models/user_model.dart';
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart';
import 'package:teamhub_productivity_suite/src/services/task_service.dart';
import 'package:teamhub_productivity_suite/src/services/user_service.dart';
import 'package:teamhub_productivity_suite/src/widgets/task_item.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late Future<List<TaskModel>> _tasksFuture;
  final TaskService _taskService = TaskService();
  final UserService _userService = UserService();
  Map<String, UserModel> _usersCache = {};

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
      ]).then((lists) async {
        final allTasks = [...lists[0], ...lists[1]];
        // Remove duplicates based on taskId
        final uniqueTasks = <String, TaskModel>{};
        for (var task in allTasks) {
          uniqueTasks[task.taskId] = task;
        }

        // load user for assignees
        final assigneeIds =
            uniqueTasks.values.map((task) => task.assigneeId).toSet().toList();

        if (assigneeIds.isNotEmpty) {
          final users = await _userService.getUsersByIds(assigneeIds);

          // Cache users to avoid multiple calls
          _usersCache.clear();
          for (var user in users) {
            _usersCache[user.uid] = user;
          }
        }

        return uniqueTasks.values.toList();
      });
    } else {
      _tasksFuture = Future.value([]);
    }
  }

  void _ontaskUpdated() {
    // Refresh tasks when a task is updated
    setState(() {
      _fetchTasks();
    });
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

            // Sort tasks: overdue first, then by due date, then by status
            filteredTasks.sort((a, b) {
              final now = DateTime.now();
              final aOverdue = a.dueDate != null && a.dueDate!.isBefore(now);
              final bOverdue = b.dueDate != null && b.dueDate!.isBefore(now);

              if (aOverdue && !bOverdue) return -1;
              if (!aOverdue && bOverdue) return 1;

              if (a.dueDate == null && b.dueDate == null) return 0;
              if (a.dueDate == null) return 1;
              if (b.dueDate == null) return -1;

              final dateComparison = a.dueDate!.compareTo(b.dueDate!);
              if (dateComparison != 0) return dateComparison;

              // If due dates are the same, sort by status
              return a.status.index.compareTo(b.status.index);
            });

            return ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                final assignee = _usersCache[task.assigneeId];
                final isAssignee = task.assigneeId == currentUser?.uid;

                return TaskItem(
                  task: task,
                  assignee: assignee,
                  isManager: isManager,
                  isAssignee: isAssignee,
                  onTaskUpdated: _ontaskUpdated,
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
