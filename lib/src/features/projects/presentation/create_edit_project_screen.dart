import 'package:flutter/material.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';

class CreateEditProjectScreen extends StatelessWidget {
  final String? projectId; // Null if creating, not null if editing

  const CreateEditProjectScreen({super.key, this.projectId});

  bool get isEditing => projectId != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editProjectTitle : AppStrings.createProjectTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: AppStrings.projectNameHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppStrings.projectDescriptionHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              AppStrings.addMembersHint,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            // TODO: Placeholder for Add Members functionality
            Container(
              height: 100,
              color: Colors.grey[200],
              child: Center(child: Text('Add Members Placeholder')),
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
                    // TODO: Implement Cancel logic (navigate back)
                    Navigator.of(context).pop();
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
