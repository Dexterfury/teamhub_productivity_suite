import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';

class CreateEditTaskScreen extends StatelessWidget {
  final String? taskId; // Null if creating, not null if editing
  final String? projectId; // Optional, for creating a task within a project

  const CreateEditTaskScreen({super.key, this.taskId, this.projectId});

  bool get isEditing => taskId != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? AppStrings.editTaskTitle : AppStrings.createTaskTitle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: AppStrings.taskTitleHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppStrings.taskDescriptionHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            // TODO: Due Date Picker Placeholder
            TextField(
              decoration: InputDecoration(
                labelText: AppStrings.dueDateHint,
                border: OutlineInputBorder(),
              ),
              readOnly:
                  true, // Make it read-only to indicate it's a date picker
              onTap: () {
                // TODO: Show Date Picker
              },
            ),
            const SizedBox(height: 16.0),
            // TODO: Status Dropdown Placeholder
            DropdownButtonFormField<String>(
              isDense: true,
              decoration: InputDecoration(
                labelText: AppStrings.statusHint,
                border: OutlineInputBorder(),
              ),
              items:
                  ['Todo', 'In Progress', 'Completed']
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                // TODO: Handle status change
              },
              hint: Text(AppStrings.statusHint),
            ),
            const SizedBox(height: 16.0),
            // TODO: Assignee Dropdown Placeholder
            DropdownButtonFormField<String>(
              isDense: true,
              decoration: InputDecoration(
                labelText: AppStrings.assigneeHint,
                border: OutlineInputBorder(),
              ),
              items:
                  ['User 1', 'User 2', 'User 3'] // Placeholder users
                      .map(
                        (user) =>
                            DropdownMenuItem(value: user, child: Text(user)),
                      )
                      .toList(),
              onChanged: (value) {
                // TODO: Handle assignee change
              },
              hint: Text(AppStrings.assigneeHint),
            ),
            const SizedBox(height: 16.0),
            if (projectId ==
                null) // Only show project selection if not creating within a project
              DropdownButtonFormField<String>(
                isDense: true,
                decoration: InputDecoration(
                  labelText: AppStrings.selectProjectHint,
                  border: OutlineInputBorder(),
                ),
                items:
                    [
                          'Project A',
                          'Project B',
                          'Project C',
                        ] // Placeholder projects
                        .map(
                          (project) => DropdownMenuItem(
                            value: project,
                            child: Text(project),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  // TODO: Handle project selection
                },
                hint: Text(AppStrings.selectProjectHint),
              ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Save logic
                  },
                  child: const Text(AppStrings.saveButton),
                ),
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text(AppStrings.cancelButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
