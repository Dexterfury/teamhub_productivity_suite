import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/task_model.dart';
import 'package:teamhub_productivity_suite/src/models/user_model.dart'; // Added
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart';
import 'package:teamhub_productivity_suite/src/services/task_service.dart';
import 'package:teamhub_productivity_suite/src/services/user_service.dart'; // Added
import 'package:teamhub_productivity_suite/src/features/dashboard/presentation/task_item_card.dart'; // Added

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late Future<List<Map<String, dynamic>>> _tasksFuture; // Changed type
  final TaskService _taskService = TaskService();
  final UserService _userService = UserService(); // Added

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
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
        final filteredTasks = uniqueTasks.values.toList();

        // Collect all unique user IDs (assignees and creators)
        final Set<String> userIds = {};
        for (var task in filteredTasks) {
          userIds.add(task.assigneeId);
          if (task.createdById != null) {
            userIds.add(task.createdById!);
          }
        }

        // Fetch all unique users
        final List<UserModel> users = await _userService.getUsersByIds(
          userIds.toList(),
        );
        final Map<String, UserModel> userMap = {
          for (var user in users) user.uid: user,
        };

        // Combine tasks with their assignee and creator user models
        return filteredTasks.map((task) {
          return {
            'task': task,
            'assignee': userMap[task.assigneeId],
            'creator': userMap[task.createdById],
          };
        }).toList();
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text(AppStrings.noTasksFound));
          } else {
            final tasksWithUsers = snapshot.data!;

            if (tasksWithUsers.isEmpty) {
              return const Center(child: Text(AppStrings.noTasksFound));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: tasksWithUsers.length,
                itemBuilder: (context, index) {
                  final task = tasksWithUsers[index]['task'] as TaskModel;
                  final assignee =
                      tasksWithUsers[index]['assignee'] as UserModel?;
                  final creator =
                      tasksWithUsers[index]['creator'] as UserModel?;

                  return TaskItemCard(
                    task: task,
                    assignee: assignee,
                    currentUser: currentUser,
                    onEdit: () {
                      // Only managers can edit tasks
                      if (isManager) {
                        context.go('/tasks/${task.taskId}/edit');
                      }
                    },
                    onStatusChange: (newStatus) async {
                      // Only assignees can change status
                      if (currentUser?.uid == task.assigneeId) {
                        final updatedTask = task.copyWith(status: newStatus);
                        await _taskService.updateTask(updatedTask);
                        _fetchTasks(); // Refresh tasks after update
                      }
                    },
                    onViewDetails: () {
                      _showTaskDetailsDialog(context, task, assignee, creator);
                    },
                  );
                },
              ),
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

  void _showTaskDetailsDialog(
    BuildContext context,
    TaskModel task,
    UserModel? assignee,
    UserModel? creator,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Description: ${task.description}'),
                const SizedBox(height: 8),
                Text('Status: ${task.status.toString().split('.').last}'),
                const SizedBox(height: 8),
                Text(
                  'Due Date: ${task.dueDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Assignee: ${assignee?.fullName ?? AppStrings.unassigned}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Created By: ${creator?.fullName ?? AppStrings.unassigned}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Created At: ${task.createdAt?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
