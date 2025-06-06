import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/project_model.dart';
import 'package:teamhub_productivity_suite/src/models/user_model.dart';
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart';
import 'package:teamhub_productivity_suite/src/services/project_service.dart';
import 'package:teamhub_productivity_suite/src/services/user_service.dart';
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

  // Services
  final ProjectService _projectService = ProjectService();
  final UserService _userService = UserService();

  // Real data instead of dummy data
  List<UserModel> _selectedMembers = [];
  List<UserModel> _availableMembers = [];
  ProjectModel? _existingProject;

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

    // Load initial data for editing or creating a project
    _loadInitialData();
  }

  // Load initial data for editing or creating
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthenticationProvider>();
      final currentUser = authProvider.appUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Always add current user as first member
      _selectedMembers = [currentUser];

      if (widget.isEditing && widget.projectId != null) {
        // Load existing project data
        _existingProject = await _projectService.getProject(widget.projectId!);

        if (_existingProject != null) {
          // Populate form fields
          _nameController.text = _existingProject!.projectName;
          _descriptionController.text = _existingProject!.projectDescription;

          // Load project members (excluding current user since already added)
          final memberUsers = await _loadProjectMembers(
            _existingProject!.memberIds,
          );
          _selectedMembers = [
            currentUser, // Current user always first
            ...memberUsers.where((user) => user.uid != currentUser.uid),
          ];
        }
      }

      // Load available members for adding to project
      await _loadAvailableMembers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Load project members from Firestore
  Future<List<UserModel>> _loadProjectMembers(List<String> memberIds) async {
    final List<UserModel> members = [];

    for (final memberId in memberIds) {
      final user = await _userService.getUser(memberId);
      if (user != null) {
        members.add(user);
      }
    }

    return members;
  }

  // Load available users that can be added to the project
  Future<void> _loadAvailableMembers() async {
    try {
      // Get all users from UserService (you might need to implement this method)
      final allUsers = await _userService.getAllUsers();

      // Filter out already selected members
      _availableMembers =
          allUsers.where((user) {
            return !_selectedMembers.any(
              (selected) => selected.uid == user.uid,
            );
          }).toList();
    } catch (e) {
      print('Error loading available members: $e');
      _availableMembers = [];
    }
  }

  // Updated save project method with real Firestore integration
  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthenticationProvider>(
        context,
        listen: false,
      );
      final currentUser = authProvider.appUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final memberIds = _selectedMembers.map((member) => member.uid).toList();

      if (widget.isEditing && widget.projectId != null) {
        // Update existing project
        final updatedProject = ProjectModel(
          projectId: widget.projectId!,
          projectName: _nameController.text.trim(),
          projectDescription: _descriptionController.text.trim(),
          memberIds: memberIds,
          createdById: _existingProject?.createdById ?? currentUser.uid,
          createdAt: _existingProject?.createdAt ?? DateTime.now(),
        );

        await _projectService.updateProject(updatedProject);
      } else {
        // Create new project
        final newProject = ProjectModel(
          projectId: DateTime.now().millisecondsSinceEpoch.toString(),
          projectName: _nameController.text.trim(),
          projectDescription: _descriptionController.text.trim(),
          memberIds: memberIds,
          createdById: currentUser.uid,
          createdAt: DateTime.now(),
        );

        await _projectService.createProject(newProject);
      }

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

      // Navigate back
      if (widget.isEditing) {
        context.go('/projects/${widget.projectId}');
      } else {
        context.go('/projects');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving project: ${e.toString()}'),
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
  void dispose() {
    // Clean up controllers when the widget is disposed
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  // Updated team members section with real data
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
                  final isCurrentUser =
                      index == 0; // First member is always current user

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          member.userPhotoUrl != null
                              ? NetworkImage(member.userPhotoUrl!)
                              : null,
                      child:
                          member.userPhotoUrl == null
                              ? Text(
                                member.fullName.isNotEmpty
                                    ? member.fullName[0].toUpperCase()
                                    : 'U',
                              )
                              : null,
                    ),
                    title: Row(
                      children: [
                        Text(member.fullName),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(member.jobTitle ?? member.email),
                    trailing:
                        isCurrentUser
                            ? null // Don't show remove button for current user
                            : IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.red,
                              onPressed: () {
                                setState(() {
                                  _selectedMembers.removeAt(index);
                                });
                                // Refresh available members
                                _loadAvailableMembers();
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

  // Updated add members dialog with real data
  void _showAddMembersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Team Members'),
          content: SizedBox(
            width: double.maxFinite,
            child:
                _availableMembers.isEmpty
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No more members available to add'),
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _availableMembers.length,
                      itemBuilder: (context, index) {
                        final member = _availableMembers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                member.userPhotoUrl != null
                                    ? NetworkImage(member.userPhotoUrl!)
                                    : null,
                            child:
                                member.userPhotoUrl == null
                                    ? Text(
                                      member.fullName.isNotEmpty
                                          ? member.fullName[0].toUpperCase()
                                          : 'U',
                                    )
                                    : null,
                          ),
                          title: Text(member.fullName),
                          subtitle: Text(member.jobTitle ?? member.email),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.green,
                            onPressed: () {
                              setState(() {
                                _selectedMembers.add(member);
                              });
                              // Refresh available members
                              _loadAvailableMembers();
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
