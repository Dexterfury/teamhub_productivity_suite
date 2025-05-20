import 'package:flutter/material.dart';
import 'package:teamhub_productivity_suite/src/models/project_model.dart';
import 'package:teamhub_productivity_suite/src/utils/appstrings.dart';

class ProjectsScreen extends StatelessWidget {
  ProjectsScreen({Key? key}) : super(key: key);

  // Placeholder data
  final List<ProjectModel> placeholderProjects = [
    ProjectModel(
      projectId: '1',
      projectName: AppStrings.placeholderProjectName,
      projectDescription: AppStrings.placeholderProjectDescription,
      memberIds: ['user1', 'user2'],
      createdById: 'user1',
      createdAt: DateTime.now(), // Use DateTime.now()
    ),
    ProjectModel(
      projectId: '2',
      projectName: 'Another Project',
      projectDescription: 'This is another placeholder project description.',
      memberIds: ['user1', 'user3'],
      createdById: 'user3',
      createdAt: DateTime.now(), // Use DateTime.now()
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.projectsTitle),
      ),
      body: ListView.builder(
        itemCount: placeholderProjects.length,
        itemBuilder: (context, index) {
          final project = placeholderProjects[index];
          return ListTile(
            title: Text(project.projectName),
            subtitle: Text(
              project.projectDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text('${project.memberIds.length} Members'),
            onTap: () {
              // TODO: Navigate to ProjectDetailsScreen
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Create Project screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
