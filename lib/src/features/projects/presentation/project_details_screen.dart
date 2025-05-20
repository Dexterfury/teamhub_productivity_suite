import 'package:flutter/material.dart';
import 'package:teamhub_productivity_suite/src/models/project_model.dart';
import 'package:teamhub_productivity_suite/src/utils/appstrings.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId; // To receive the project ID via navigation

  ProjectDetailsScreen({Key? key, required this.projectId}) : super(key: key);

  // Placeholder data (replace with actual data fetching later)
  final ProjectModel placeholderProject = ProjectModel(
    projectId: '1',
    projectName: AppStrings.placeholderProjectName,
    projectDescription: AppStrings.placeholderProjectDescription,
    memberIds: ['user1', 'user2', 'user3'],
    createdById: 'user1',
    createdAt: DateTime.now(), // Use DateTime.now()
  );

  @override
  Widget build(BuildContext context) {
    // In a real app, you would fetch project details based on projectId
    final project = placeholderProject; // Using placeholder for now

    return Scaffold(
      appBar: AppBar(
        title: Text(project.projectName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.projectName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              project.projectDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Members (${project.memberIds.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            // TODO: Placeholder for Members list
            Container(
              height: 100,
              color: Colors.grey[200],
              child: Center(child: Text('Members List Placeholder')),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            // TODO: Placeholder for Tasks list
            Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(child: Text('Tasks List Placeholder')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Create Task screen for this project
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
