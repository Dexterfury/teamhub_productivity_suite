import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';

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
        child: ResponsiveContainer(
          maxWidthMedium: 600,
          maxWidthLarge: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: AppStrings.taskTitleHint,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: AppStrings.taskDescriptionHint,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: const InputDecoration(
                  labelText: AppStrings.dueDateHint,
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () {
                  // TODO: Show Date Picker
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                isDense: true,
                decoration: const InputDecoration(
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
                hint: const Text(AppStrings.statusHint),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                isDense: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.assigneeHint,
                  border: OutlineInputBorder(),
                ),
                items:
                    ['User 1', 'User 2', 'User 3']
                        .map(
                          (user) =>
                              DropdownMenuItem(value: user, child: Text(user)),
                        )
                        .toList(),
                onChanged: (value) {
                  // TODO: Handle assignee change
                },
                hint: const Text(AppStrings.assigneeHint),
              ),
              const SizedBox(height: 16.0),
              if (projectId == null)
                DropdownButtonFormField<String>(
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: AppStrings.selectProjectHint,
                    border: OutlineInputBorder(),
                  ),
                  items:
                      ['Project A', 'Project B', 'Project C']
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
                  hint: const Text(AppStrings.selectProjectHint),
                ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement Save logic
                      },
                      child: const Text(AppStrings.saveButton),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(AppStrings.cancelButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
