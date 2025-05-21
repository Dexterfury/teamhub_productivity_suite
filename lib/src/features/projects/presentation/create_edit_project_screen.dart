import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/widgets/inputfield.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';

class CreateEditProjectScreen extends StatefulWidget {
  final String? projectId; // Null if creating, not null if editing

  const CreateEditProjectScreen({super.key, this.projectId});

  bool get isEditing => projectId != null;

  @override
  State<CreateEditProjectScreen> createState() =>
      _CreateEditProjectScreenState();
}

class _CreateEditProjectScreenState extends State<CreateEditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  // Placeholder for selected members
  final List<Map<String, dynamic>> _selectedMembers = [
    {
      'id': 'user1',
      'name': 'John Doe',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'role': 'Project Manager',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values if editing
    _nameController = TextEditingController(
      text: widget.isEditing ? AppStrings.placeholderProjectName : '',
    );
    _descriptionController = TextEditingController(
      text: widget.isEditing ? AppStrings.placeholderProjectDescription : '',
    );

    // TODO: Fetch project details if editing
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Save project
  Future<void> _saveProject() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate saving to backend
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Project updated successfully'
                : 'Project created successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to projects list or project details
      if (widget.isEditing) {
        context.go('/projects/${widget.projectId}');
      } else {
        context.go('/projects');
      }
    } catch (e) {
      if (!mounted) return;
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.genericError),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? AppStrings.editProjectTitle
              : AppStrings.createProjectTitle,
        ),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveProject,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.save),
            label: Text(AppStrings.saveButton),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ResponsiveContainer(
            maxWidthMedium: 800,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Header
                  _buildFormHeader(context),

                  const SizedBox(height: 24.0),

                  // Project Details Section
                  _buildProjectDetailsSection(context),

                  const SizedBox(height: 24.0),

                  // Team Members Section
                  _buildTeamMembersSection(context),

                  const SizedBox(height: 24.0),

                  // Action Buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Form header with title and instructions
  Widget _buildFormHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isEditing ? 'Edit Project Details' : 'Create New Project',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in the details below to ${widget.isEditing ? 'update' : 'create'} a project.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  // Project details section with name and description
  Widget _buildProjectDetailsSection(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Project Name Field
            InputField(
              controller: _nameController,
              labelText: AppStrings.projectNameHint,
              icon: Icons.folder_outlined,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.requiredFieldError;
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Project Description Field
            InputField(
              controller: _descriptionController,
              labelText: AppStrings.projectDescriptionHint,
              icon: Icons.description_outlined,
              maxLines: 3,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.requiredFieldError;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // Team members section with member selection
  Widget _buildTeamMembersSection(BuildContext context) {
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
                  'Team Members',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAddMembersDialog(context),
                  icon: const Icon(Icons.person_add_outlined, size: 20),
                  label: const Text('Add Members'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Selected Members List
            if (_selectedMembers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No team members added yet',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click "Add Members" to add team members to this project',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedMembers.length,
                itemBuilder: (context, index) {
                  final member = _selectedMembers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(member['avatar']),
                    ),
                    title: Text(member['name']),
                    subtitle: Text(member['role']),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.red,
                      onPressed: () {
                        // Don't allow removing the last member
                        if (_selectedMembers.length > 1) {
                          setState(() {
                            _selectedMembers.removeAt(index);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Project must have at least one member',
                              ),
                            ),
                          );
                        }
                      },
                      tooltip: 'Remove member',
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Action buttons for form
  Widget _buildActionButtons(BuildContext context) {
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth >= 600;

    if (isTabletOrLarger) {
      // Row layout for tablet and larger screens
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveProject,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.save),
            label: Text(widget.isEditing ? 'Update Project' : 'Create Project'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          TextButton.icon(
            onPressed:
                _isLoading
                    ? null
                    : () =>
                        widget.isEditing
                            ? context.go('/projects/${widget.projectId}')
                            : context.go('/projects'),
            icon: const Icon(Icons.cancel),
            label: const Text(AppStrings.cancelButton),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
            ),
          ),
        ],
      );
    } else {
      // Column layout for mobile screens
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveProject,
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.save),
              label: Text(
                widget.isEditing ? 'Update Project' : 'Create Project',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed:
                  _isLoading
                      ? null
                      : () =>
                          widget.isEditing
                              ? context.go('/projects/${widget.projectId}')
                              : context.go('/projects'),
              icon: const Icon(Icons.cancel),
              label: const Text(AppStrings.cancelButton),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
        ],
      );
    }
  }

  // Show dialog to add team members
  void _showAddMembersDialog(BuildContext context) {
    // Placeholder list of available team members
    final availableMembers = [
      {
        'id': 'user2',
        'name': 'Jane Smith',
        'avatar': 'https://i.pravatar.cc/150?img=2',
        'role': 'Developer',
      },
      {
        'id': 'user3',
        'name': 'Robert Johnson',
        'avatar': 'https://i.pravatar.cc/150?img=3',
        'role': 'Designer',
      },
      {
        'id': 'user4',
        'name': 'Emily Davis',
        'avatar': 'https://i.pravatar.cc/150?img=4',
        'role': 'QA Engineer',
      },
    ];

    // Filter out already selected members
    final filteredMembers =
        availableMembers.where((member) {
          return !_selectedMembers.any(
            (selected) => selected['id'] == member['id'],
          );
        }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Team Members'),
          content: SizedBox(
            width: double.maxFinite,
            child:
                filteredMembers.isEmpty
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No more members available to add'),
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              member['avatar'] ?? '',
                            ),
                          ),
                          title: Text(member['name'] ?? ''),
                          subtitle: Text(member['role'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.green,
                            onPressed: () {
                              setState(() {
                                _selectedMembers.add(member);
                              });
                              Navigator.of(context).pop();
                            },
                            tooltip: 'Add member',
                          ),
                        );
                      },
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
