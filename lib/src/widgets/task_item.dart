import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamhub_productivity_suite/src/models/task_model.dart';
import 'package:teamhub_productivity_suite/src/models/user_model.dart';
import 'package:teamhub_productivity_suite/src/services/task_service.dart';

class TaskItem extends StatefulWidget {
  final TaskModel task;
  final UserModel? assignee;
  final bool isManager;
  final bool isAssignee;
  final VoidCallback onTaskUpdated;

  const TaskItem({
    super.key,
    required this.task,
    this.assignee,
    required this.isManager,
    required this.isAssignee,
    required this.onTaskUpdated,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  final TaskService _taskService = TaskService();
  bool _isUpdatingStatus = false;

  Future<void> _updateTaskStatus(TaskStatus newStatus) async {
    if (newStatus == widget.task.status) return;

    setState(() => _isUpdatingStatus = true);

    try {
      final updatedTask = TaskModel(
        taskId: widget.task.taskId,
        title: widget.task.title,
        description: widget.task.description,
        dueDate: widget.task.dueDate,
        status: newStatus,
        assigneeId: widget.task.assigneeId,
        projectId: widget.task.projectId,
        createdById: widget.task.createdById,
        createdAt: widget.task.createdAt,
      );

      await _taskService.updateTask(updatedTask);
      widget.onTaskUpdated();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task status updated to ${newStatus.toString().split('.').last}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Task Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  TaskStatus.values.map((status) {
                    return RadioListTile<TaskStatus>(
                      title: Text(_getStatusDisplayName(status)),
                      value: status,
                      groupValue: widget.task.status,
                      onChanged: (value) {
                        Navigator.of(context).pop();
                        if (value != null) {
                          _updateTaskStatus(value);
                        }
                      },
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  String _getStatusDisplayName(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.access_time;
      case TaskStatus.completed:
        return Icons.check_circle;
    }
  }

  bool _isOverdue() {
    if (widget.task.dueDate == null) return false;
    return widget.task.dueDate!.isBefore(DateTime.now()) &&
        widget.task.status != TaskStatus.completed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = _isOverdue();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            widget.isManager
                ? () => context.go('/tasks/${widget.task.taskId}/edit')
                : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isOverdue ? Colors.red[700] : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        widget.task.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(
                          widget.task.status,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(widget.task.status),
                          size: 14,
                          color: _getStatusColor(widget.task.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusDisplayName(widget.task.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(widget.task.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              if (widget.task.description.isNotEmpty)
                Text(
                  widget.task.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Info Row
              Row(
                children: [
                  // Assignee
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.assignee?.fullName ?? 'Unknown User',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Due Date
                  if (widget.task.dueDate != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.task.dueDate!.toLocal().toString().split(' ')[0],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverdue ? Colors.red : Colors.grey[700],
                        fontWeight:
                            isOverdue ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'OVERDUE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Action Buttons
                  if (widget.isAssignee && !widget.isManager) ...[
                    // Status Update Button for Assignee
                    _isUpdatingStatus
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : TextButton.icon(
                          onPressed: _showStatusDialog,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Update Status'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                  ],

                  if (widget.isManager) ...[
                    // Edit Button for Manager
                    TextButton.icon(
                      onPressed:
                          () => context.go('/tasks/${widget.task.taskId}/edit'),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
