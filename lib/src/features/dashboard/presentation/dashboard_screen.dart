import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart';
import 'package:teamhub_productivity_suite/src/widgets/stat_card.dart';
import 'package:teamhub_productivity_suite/src/widgets/profile_image_widget.dart';
import 'package:teamhub_productivity_suite/src/services/task_service.dart'; // Added
import 'package:teamhub_productivity_suite/src/services/user_service.dart'; // Added
import 'package:teamhub_productivity_suite/src/services/project_service.dart'; // Added
import 'package:teamhub_productivity_suite/src/models/task_model.dart'; // Added
import 'package:teamhub_productivity_suite/src/models/user_model.dart'; // Added
import 'package:teamhub_productivity_suite/src/models/project_model.dart'; // Added
import 'package:teamhub_productivity_suite/src/features/dashboard/presentation/task_item_card.dart'; // Added

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TaskService _taskService = TaskService();
  final UserService _userService = UserService();
  final ProjectService _projectService = ProjectService();

  late Future<List<Map<String, dynamic>>> _myTasksFuture;
  late Future<List<ProjectModel>> _recentProjectsFuture;

  int _totalTasks = 0;
  int _inProgressTasks = 0;
  int _completedTasks = 0;
  int _activeProjects = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    final currentUserId = authProvider.appUser?.uid;

    if (currentUserId == null) {
      _myTasksFuture = Future.value([]);
      _recentProjectsFuture = Future.value([]);
      setState(() {
        _totalTasks = 0;
        _inProgressTasks = 0;
        _completedTasks = 0;
        _activeProjects = 0;
      });
      return;
    }

    // Fetch tasks
    _myTasksFuture = Future.wait([
      _taskService.getTasks(assigneeId: currentUserId),
      _taskService.getTasks(createdById: currentUserId),
    ]).then((lists) async {
      final allTasks = [...lists[0], ...lists[1]];
      final uniqueTasks = <String, TaskModel>{};
      for (var task in allTasks) {
        uniqueTasks[task.taskId] = task;
      }
      final filteredTasks = uniqueTasks.values.toList();

      // Update task stats
      setState(() {
        _totalTasks = filteredTasks.length;
        _inProgressTasks =
            filteredTasks
                .where((task) => task.status == TaskStatus.inProgress)
                .length;
        _completedTasks =
            filteredTasks
                .where((task) => task.status == TaskStatus.completed)
                .length;
      });

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

    // Fetch recent projects
    _recentProjectsFuture = _projectService
        .getProjects(currentUserId: currentUserId, filter: ProjectFilter.recent)
        .then((projects) {
          setState(() {
            _activeProjects =
                projects
                    .where((project) => project.status == ProjectStatus.active)
                    .length;
          });
          return projects;
        });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.go('/profile?fromDashboard=true'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData, // Call _fetchDashboardData for refresh
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: ResponsiveContainer(
            maxWidthMedium: 900,
            maxWidthLarge: 1400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(context),

                const SizedBox(height: 24.0),

                // Quick Stats Section - Grid layout for tablet and larger
                Text(
                  AppStrings.quickStatsSection,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                _buildQuickStats(isTabletOrLarger),

                const SizedBox(height: 24.0),

                // My Tasks Section
                Text(
                  AppStrings.myTasksSection,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                _buildTasksList(),

                const SizedBox(height: 24.0),

                // Recent Projects Section
                Text(
                  AppStrings.recentProjectsSection,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                _buildRecentProjects(),
              ],
            ),
          ),
        ),
      ),
      // Add a drawer for mobile view
      drawer: screenWidth < 600 ? _buildDrawer(context) : null,
      floatingActionButton: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, child) {
          final isManager = authProvider.appUser?.roles.isManager ?? false;
          return isManager
              ? FloatingActionButton(
                heroTag: 'dashboard_fab',
                onPressed: () {
                  context.go('/tasks/new');
                },
                tooltip: 'Add Task',
                child: const Icon(Icons.add),
              )
              : const SizedBox.shrink(); // Hide FAB if not manager
        },
      ),
    );
  }

  // Welcome section with user greeting
  Widget _buildWelcomeSection(BuildContext context) {
    final appUser = context.watch<AuthenticationProvider>().appUser;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ProfileImageWidget(imageUrl: appUser?.userPhotoUrl, radius: 24.0),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${appUser?.fullName}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Today is ${_getFormattedDate()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get formatted date
  String _getFormattedDate() {
    final now = DateTime.now();
    // Example: Friday, September 15, 2023
    return DateFormat('EEEE, MMMM d, yyyy').format(now);
  }

  // Quick stats section with responsive grid
  Widget _buildQuickStats(bool isTabletOrLarger) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTabletOrLarger ? 4 : 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: isTabletOrLarger ? 1.5 : 1.3,
      children: [
        StatCard(
          title: 'Total Tasks',
          value: _totalTasks.toString(),
          icon: Icons.task_alt,
          color: Colors.blue,
        ),
        StatCard(
          title: 'In Progress',
          value: _inProgressTasks.toString(),
          icon: Icons.pending_actions,
          color: Colors.orange,
        ),
        StatCard(
          title: 'Completed',
          value: _completedTasks.toString(),
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        StatCard(
          title: 'Active Projects',
          value: _activeProjects.toString(),
          icon: Icons.folder_open,
          color: Colors.purple,
        ),
      ],
    );
  }

  // Tasks list with horizontal scrolling
  Widget _buildTasksList() {
    final currentUser = Provider.of<AuthenticationProvider>(context).appUser;
    final isManager = currentUser?.roles.isManager ?? false;

    return SizedBox(
      height: 200, // Adjust height as needed for TaskItemCard
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _myTasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text(AppStrings.noTasksFound));
          } else {
            final tasksWithUsers = snapshot.data!;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tasksWithUsers.length,
              itemBuilder: (context, index) {
                final task = tasksWithUsers[index]['task'] as TaskModel;
                final assignee =
                    tasksWithUsers[index]['assignee'] as UserModel?;
                final creator = tasksWithUsers[index]['creator'] as UserModel?;

                return Container(
                  width: 280, // Fixed width for horizontal scroll
                  margin: const EdgeInsets.only(right: 16),
                  child: TaskItemCard(
                    task: task,
                    assignee: assignee,
                    currentUser: currentUser,
                    onEdit: () {
                      if (isManager) {
                        context.go('/tasks/${task.taskId}/edit');
                      }
                    },
                    onStatusChange: (newStatus) async {
                      if (currentUser?.uid == task.assigneeId) {
                        final updatedTask = task.copyWith(status: newStatus);
                        await _taskService.updateTask(updatedTask);
                        _fetchDashboardData(); // Refresh dashboard after update
                      }
                    },
                    onViewDetails: () {
                      _showTaskDetailsDialog(context, task, assignee, creator);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Recent projects with horizontal scrolling
  Widget _buildRecentProjects() {
    return SizedBox(
      height: 180,
      child: FutureBuilder<List<ProjectModel>>(
        future: _recentProjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recent projects found.'));
          } else {
            final projects = snapshot.data!;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: () => context.go('/projects/${project.projectId}'),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.folder_outlined,
                                    color: Colors.purple[700],
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getProjectStatusColor(
                                      project.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    project.status.toString().split('.').last,
                                    style: TextStyle(
                                      color: _getProjectStatusColor(
                                        project.status,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              project.projectName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                project.projectDescription,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                // TODO: Fetch actual task count for project
                                Flexible(
                                  child: Text(
                                    '${project.memberIds.length} Members', // Placeholder for task count
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Spacer(),
                                // TODO: Display actual member avatars
                                SizedBox(
                                  width: 64.0,
                                  height: 24.0,
                                  child: Stack(
                                    children: [
                                      for (
                                        var i = 0;
                                        i < project.memberIds.length && i < 3;
                                        i++
                                      )
                                        Positioned(
                                          right: i * 20.0,
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.white,
                                            child: CircleAvatar(
                                              radius: 11,
                                              backgroundImage: NetworkImage(
                                                'https://i.pravatar.cc/300?img=${i + 1}',
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (project.memberIds.length > 3)
                                        Positioned(
                                          right: 3 * 20.0,
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            child: Text(
                                              '+${project.memberIds.length - 3}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Color _getProjectStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.archived:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.blue;
      default:
        return Colors.grey;
    }
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

  // Navigation drawer for mobile view
  Widget _buildDrawer(BuildContext context) {
    final appUser = Provider.of<AuthenticationProvider>(context).appUser;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileImageWidget(imageUrl: appUser?.userPhotoUrl, radius: 30),
                const SizedBox(height: 10),
                Text(
                  appUser?.fullName ?? 'User Name',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                Text(
                  appUser?.email ?? 'user@example.com',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
            selected:
                GoRouter.of(
                  context,
                ).routerDelegate.currentConfiguration.uri.toString() ==
                '/dashboard',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.task_alt_outlined,
            title: 'Tasks',
            onTap: () {
              Navigator.pop(context);
              context.go('/tasks');
            },
            selected:
                GoRouter.of(
                  context,
                ).routerDelegate.currentConfiguration.uri.toString() ==
                '/tasks',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.folder_outlined,
            title: 'Projects',
            onTap: () {
              Navigator.pop(context);
              context.go('/projects');
            },
            selected:
                GoRouter.of(
                  context,
                ).routerDelegate.currentConfiguration.uri.toString() ==
                '/projects',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'Inventory',
            onTap: () {
              Navigator.pop(context);
              context.go('/inventory');
            },
            selected:
                GoRouter.of(
                  context,
                ).routerDelegate.currentConfiguration.uri.toString() ==
                '/inventory',
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              // context.go('/settings'); // Assuming a settings route
            },
            // selected: GoRouter.of(context).currentConfiguration.uri.toString() == '/settings',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
              Navigator.pop(context);
              await Provider.of<AuthenticationProvider>(
                context,
                listen: false,
              ).signOut();
              context.go('/login');
            },
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  // Helper method to build drawer items
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            selected
                ? Theme.of(context).primaryColor
                : textColor ?? Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color:
              selected
                  ? Theme.of(context).primaryColor
                  : textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: selected ? FontWeight.bold : null,
        ),
      ),
      onTap: onTap,
      selected: selected,
    );
  }
}

  // Color _getProjectStatusColor(ProjectStatus status) {
  //   switch (status) {
  //     case ProjectStatus.active:
  //       return Colors.green;
  //     case ProjectStatus.archived:
  //       return Colors.orange;
  //     case ProjectStatus.completed:
  //       return Colors.blue;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  // void _showTaskDetailsDialog(
  //   BuildContext context,
  //   TaskModel task,
  //   UserModel? assignee,
  //   UserModel? creator,
  // ) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(task.title),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text('Description: ${task.description}'),
  //               const SizedBox(height: 8),
  //               Text('Status: ${task.status.toString().split('.').last}'),
  //               const SizedBox(height: 8),
  //               Text(
  //                 'Due Date: ${task.dueDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 'Assignee: ${assignee?.fullName ?? AppStrings.unassigned}',
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 'Created By: ${creator?.fullName ?? AppStrings.unassigned}',
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 'Created At: ${task.createdAt?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Close'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // // Navigation drawer for mobile view
  // Widget _buildDrawer(BuildContext context) {
  //   final appUser = Provider.of<AuthenticationProvider>(context).appUser;
  //   return Drawer(
  //     child: ListView(
  //       padding: EdgeInsets.zero,
  //       children: [
  //         DrawerHeader(
  //           decoration: BoxDecoration(color: Theme.of(context).primaryColor),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               ProfileImageWidget(imageUrl: appUser?.userPhotoUrl, radius: 30),
  //               const SizedBox(height: 10),
  //               Text(
  //                 appUser?.fullName ?? 'User Name',
  //                 style: Theme.of(
  //                   context,
  //                 ).textTheme.titleLarge?.copyWith(color: Colors.white),
  //               ),
  //               Text(
  //                 appUser?.email ?? 'user@example.com',
  //                 style: Theme.of(
  //                   context,
  //                 ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
  //               ),
  //             ],
  //           ),
  //         ),
  //         _buildDrawerItem(
  //           context,
  //           icon: Icons.dashboard_outlined,
  //           title: 'Dashboard',
  //           onTap: () {
  //             Navigator.pop(context);
  //             context.go('/dashboard');
  //           },
  //           selected: GoRouter.of(context).location == '/dashboard',
  //         ),
  //         _buildDrawerItem(
  //           context,
  //           icon: Icons.task_alt_outlined,
  //           title: 'Tasks',
  //           onTap: () {
  //             Navigator.pop(context);
  //             context.go('/tasks');
  //           },
  //           selected: GoRouter.of(context).location == '/tasks',
  //         ),
  //         _buildDrawerItem(
  //           context,
  //           icon: Icons.folder_outlined,
  //           title: 'Projects',
  //           onTap: () {
  //             Navigator.pop(context);
  //             context.go('/projects');
  //           },
  //           selected: GoRouter.of(context).location == '/projects',
  //         ),
  //         _buildDrawerItem(
  //           context,
  //           icon: Icons.inventory_2_outlined,
  //           title: 'Inventory',
  //           onTap: () {
  //             Navigator.pop(context);
  //             context.go('/inventory');
  //           },
  //           selected: GoRouter.of(context).location == '/inventory',
  //         ),
  //         const Divider(),
  //         _buildDrawerItem(
  //           context,
  //           icon: Icons.settings_outlined,
  //           title: 'Settings',
  //           onTap: () {
  //             Navigator.pop(context);
  //             // context.go('/settings'); // Assuming a settings route
  //           },
  //           // selected: GoRouter.of(context).location == '/settings',
  //         ),
  //         _buildDrawerItem(
  //           context,
  //           icon: Icons.logout,
  //           title: 'Logout',
  //           onTap: () async {
  //             Navigator.pop(context);
  //             await Provider.of<AuthenticationProvider>(
  //               context,
  //               listen: false,
  //             ).signOut();
  //             context.go('/login');
  //           },
  //           textColor: Colors.red,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // // Helper method to build drawer items
  // Widget _buildDrawerItem(
  //   BuildContext context, {
  //   required IconData icon,
  //   required String title,
  //   required VoidCallback onTap,
  //   bool selected = false,
  //   Color? textColor,
  // }) {
  //   return ListTile(
  //     leading: Icon(
  //       icon,
  //       color:
  //           selected
  //               ? Theme.of(context).primaryColor
  //               : textColor ?? Theme.of(context).iconTheme.color,
  //     ),
  //     title: Text(
  //       title,
  //       style: TextStyle(
  //         color:
  //             selected
  //                 ? Theme.of(context).primaryColor
  //                 : textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
  //         fontWeight: selected ? FontWeight.bold : null,
  //       ),
  //     ),
  //     onTap: onTap,
  //     selected: selected,
  //   );
  // }

