import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/models/project_model.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId; // To receive the project ID via navigation

  ProjectDetailsScreen({super.key, required this.projectId});

  // Placeholder data (replace with actual data fetching later)
  final ProjectModel placeholderProject = ProjectModel(
    projectId: '1',
    projectName: AppStrings.placeholderProjectName,
    projectDescription: AppStrings.placeholderProjectDescription,
    memberIds: ['user1', 'user2', 'user3'],
    createdById: 'user1',
    createdAt: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth >= 600;

    // In a real app, you would fetch project details based on projectId
    final project = placeholderProject; // Using placeholder for now

    return Scaffold(
      appBar: AppBar(
        title: Text(project.projectName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/projects/$projectId/edit'),
            tooltip: 'Edit Project',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Implement actions
              if (value == 'delete') {
                _showDeleteConfirmation(context);
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 20),
                        SizedBox(width: 8),
                        Text('Share Project'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive, size: 20),
                        SizedBox(width: 8),
                        Text('Archive Project'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Delete Project',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: ResponsiveContainer(
            maxWidthMedium: 900,
            maxWidthLarge: 1400,
            child:
                isTabletOrLarger
                    ? _buildTabletLayout(context, project)
                    : _buildMobileLayout(context, project),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'projectDetailsFAB', // Add unique heroTag
        onPressed: () {
          // Navigate to Create Task screen for this project
          context.go('/projects/$projectId/tasks/new');
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Tablet and larger screen layout
  Widget _buildTabletLayout(BuildContext context, ProjectModel project) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Project details and members
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project header
              _buildProjectHeader(context, project),
              const SizedBox(height: 24.0),

              // Members section
              _buildMembersSection(context, project),
            ],
          ),
        ),
        const SizedBox(width: 24.0),

        // Right column - Tasks
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildTasksSection(context, project)],
          ),
        ),
      ],
    );
  }

  // Mobile screen layout
  Widget _buildMobileLayout(BuildContext context, ProjectModel project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project header
        _buildProjectHeader(context, project),
        const SizedBox(height: 24.0),

        // Members section
        _buildMembersSection(context, project),
        const SizedBox(height: 24.0),

        // Tasks section
        _buildTasksSection(context, project),
      ],
    );
  }

  // Project header with name, description and metadata
  Widget _buildProjectHeader(BuildContext context, ProjectModel project) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project name
            Text(
              project.projectName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),

            // Project metadata
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Created on ${_formatDate(project.createdAt)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Created by User', // Replace with actual user name
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Project description
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              project.projectDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // Members section with list of project members
  Widget _buildMembersSection(BuildContext context, ProjectModel project) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Members (${project.memberIds.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.person_add, size: 20),
                  label: const Text('Add'),
                  onPressed: () {
                    // TODO: Implement add member functionality
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // TODO: Replace with actual members list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: project.memberIds.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=${index + 1}',
                    ),
                  ),
                  title: Text('Team Member ${index + 1}'),
                  subtitle: Text(
                    'Role: ${index == 0 ? 'Project Manager' : 'Team Member'}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // TODO: Show member options
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Tasks section with list of project tasks
  Widget _buildTasksSection(BuildContext context, ProjectModel project) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Tasks', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                DropdownButton<String>(
                  value: 'all',
                  underline: Container(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Tasks')),
                    DropdownMenuItem(
                      value: 'inProgress',
                      child: Text('In Progress'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                  ],
                  onChanged: (value) {
                    // TODO: Implement task filtering
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // TODO: Replace with actual tasks list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // Placeholder count
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(index).withOpacity(0.2),
                      child: Icon(
                        _getStatusIcon(index),
                        color: _getStatusColor(index),
                        size: 20,
                      ),
                    ),
                    title: Text('Task ${index + 1}'),
                    subtitle: Text(
                      'Due: ${_formatDate(DateTime.now().add(Duration(days: index + 1)))}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=${index + 1}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            // TODO: Show task options
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigate to task details
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to get status color
  Color _getStatusColor(int index) {
    switch (index % 3) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get status icon
  IconData _getStatusIcon(int index) {
    switch (index % 3) {
      case 0:
        return Icons.pending_actions;
      case 1:
        return Icons.access_time;
      case 2:
        return Icons.check_circle_outline;
      default:
        return Icons.circle;
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project?'),
          content: const Text(
            'This action cannot be undone. All tasks associated with this project will also be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement delete logic
                Navigator.of(context).pop();
                context.go('/projects');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
