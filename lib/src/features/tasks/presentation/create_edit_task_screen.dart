import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/project_model.dart';
import 'package:teamhub_productivity_suite/src/models/task_model.dart';
import 'package:teamhub_productivity_suite/src/models/user_model.dart';
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart';
import 'package:teamhub_productivity_suite/src/services/project_service.dart';
import 'package:teamhub_productivity_suite/src/services/task_service.dart';
import 'package:teamhub_productivity_suite/src/services/user_service.dart';
import 'package:teamhub_productivity_suite/src/widgets/responsive_container.dart';
import 'package:uuid/uuid.dart';

class CreateEditTaskScreen extends StatefulWidget {
  final String? taskId; // Null if creating, not null if editing
  final String? projectId; // Optional, for creating a task within a project

  const CreateEditTaskScreen({super.key, this.taskId, this.projectId});

  @override
  State<CreateEditTaskScreen> createState() => _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends State<CreateEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();

  TaskStatus _selectedStatus = TaskStatus.todo;
  ProjectModel? _selectedProject;
  UserModel? _selectedAssignee;
  DateTime? _selectedDueDate;

  List<ProjectModel> _availableProjects = [];
  List<UserModel> _projectMembers = [];

  final TaskService _taskService = TaskService();
  final ProjectService _projectService = ProjectService();
  final UserService _userService = UserService();

  bool get isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    final currentUserId = authProvider.appUser?.uid;

    if (currentUserId == null) {
      // Handle error or redirect if user is not logged in
      return;
    }

    // Load projects for the current user
    _availableProjects = await _projectService.getProjectsForUser(
      currentUserId,
    );

    if (isEditing) {
      // Load existing task data
      final task = await _taskService.getTask(widget.taskId!);
      if (task != null) {
        _titleController.text = task.title;
        _descriptionController.text = task.description;
        _selectedStatus = task.status;
        _selectedDueDate = task.dueDate;
        if (_selectedDueDate != null) {
          _dueDateController.text =
              _selectedDueDate!.toLocal().toString().split(' ')[0];
        }

        // Set selected project and assignee
        if (task.projectId.isNotEmpty) {
          _selectedProject = _availableProjects.firstWhere(
            (p) => p.projectId == task.projectId,
            orElse: () => _availableProjects.first, // Fallback
          );
          await _loadProjectMembers(_selectedProject!.projectId);
          _selectedAssignee = _projectMembers.firstWhere(
            (u) => u.uid == task.assigneeId,
            orElse: () => _projectMembers.first, // Fallback
          );
        }
      }
    } else if (widget.projectId != null) {
      // If creating a task within a specific project (from project details screen)
      _selectedProject = _availableProjects.firstWhere(
        (p) => p.projectId == widget.projectId,
        orElse: () => _availableProjects.first, // Fallback
      );
      if (_selectedProject != null) {
        await _loadProjectMembers(_selectedProject!.projectId);
      }
    }

    setState(() {});
  }

  Future<void> _loadProjectMembers(String projectId) async {
    final project = await _projectService.getProject(projectId);
    if (project != null && project.memberIds.isNotEmpty) {
      _projectMembers = await _userService.getUsersByIds(project.memberIds);
    } else {
      _projectMembers = [];
    }
    setState(() {});
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    final currentUserId = authProvider.appUser?.uid;

    if (currentUserId == null) {
      // Show error or redirect
      return;
    }

    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.selectProjectHint)),
      );
      return;
    }

    if (_selectedAssignee == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.assigneeHint)));
      return;
    }

    try {
      final task = TaskModel(
        taskId: isEditing ? widget.taskId! : const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDueDate,
        status: _selectedStatus,
        assigneeId: _selectedAssignee!.uid,
        projectId: _selectedProject!.projectId,
        createdById: isEditing ? null : currentUserId, // Only set on creation
        createdAt: isEditing ? null : DateTime.now(), // Only set on creation
      );

      if (isEditing) {
        await _taskService.updateTask(task);
      } else {
        await _taskService.createTask(task);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? AppStrings.taskUpdatedSuccessfully
                : AppStrings.taskCreatedSuccessfully,
          ),
        ),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${AppStrings.genericError}: $e')));
    }
  }

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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.taskTitleHint,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.requiredFieldError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: AppStrings.taskDescriptionHint,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.requiredFieldError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _dueDateController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.dueDateHint,
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () => _selectDueDate(context),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<TaskStatus>(
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: AppStrings.statusHint,
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedStatus,
                  items:
                      TaskStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.toString().split('.').last),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                  hint: const Text(AppStrings.statusHint),
                ),
                const SizedBox(height: 16.0),
                if (widget.projectId == null)
                  DropdownButtonFormField<ProjectModel>(
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: AppStrings.selectProjectHint,
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedProject,
                    items:
                        _availableProjects
                            .map(
                              (project) => DropdownMenuItem(
                                value: project,
                                child: Text(project.projectName),
                              ),
                            )
                            .toList(),
                    onChanged: (value) async {
                      setState(() {
                        _selectedProject = value;
                        _selectedAssignee = null; // Reset assignee
                        _projectMembers = []; // Clear members
                      });
                      if (value != null) {
                        await _loadProjectMembers(value.projectId);
                      }
                    },
                    hint: const Text(AppStrings.selectProjectHint),
                    validator: (value) {
                      if (value == null) {
                        return AppStrings.requiredFieldError;
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<UserModel>(
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: AppStrings.assigneeHint,
                    border: const OutlineInputBorder(),
                    enabled:
                        _selectedProject !=
                        null, // Disable until project selected
                  ),
                  value: _selectedAssignee,
                  items:
                      _projectMembers
                          .map(
                            (user) => DropdownMenuItem(
                              value: user,
                              child: Text(user.fullName),
                            ),
                          )
                          .toList(),
                  onChanged:
                      _selectedProject != null
                          ? (value) {
                            setState(() {
                              _selectedAssignee = value;
                            });
                          }
                          : null, // Disable onChanged if no project selected
                  hint: const Text(AppStrings.assigneeHint),
                  validator: (value) {
                    if (value == null && _selectedProject != null) {
                      return AppStrings.requiredFieldError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveTask,
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
      ),
    );
  }
}
