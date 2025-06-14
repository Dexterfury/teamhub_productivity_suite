import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:teamhub_productivity_suite/src/constants/appstrings.dart';
import 'package:teamhub_productivity_suite/src/models/task_model.dart';
import 'package:teamhub_productivity_suite/src/models/user_model.dart';
import 'package:teamhub_productivity_suite/src/providers/authentication_provider.dart';
import 'package:teamhub_productivity_suite/src/widgets/profile_image_widget.dart';

class TaskItemCard extends StatelessWidget {
  final TaskModel task;
  final UserModel? assignee;
  final UserModel? currentUser;
  final VoidCallback? onEdit;
  final Function(TaskStatus)? onStatusChange;
  final VoidCallback? onViewDetails;

  const TaskItemCard({
    super.key,
    required this.task,
    this.assignee,
    this.currentUser,
    this.onEdit,
    this.onStatusChange,
    this.onViewDetails,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.pending_actions;
      case TaskStatus.inProgress:
        return Icons.access_time;
      case TaskStatus.completed:
        return Icons.check_circle_outline;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isManager = currentUser?.roles.isManager ?? false;
    final bool isAssignee = currentUser?.uid == task.assigneeId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isManager || isAssignee)
                  _buildActionButton(context, isManager, isAssignee),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getStatusIcon(task.status),
                  color: _getStatusColor(task.status),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'Status: ${task.status.toString().split('.').last}',
                  style: TextStyle(
                    color: _getStatusColor(task.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Due: ${_formatDate(task.dueDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                //const Text('Assignee: '),
                if (assignee != null)
                  Row(
                    children: [
                      ProfileImageWidget(
                        imageUrl: assignee!.userPhotoUrl,
                        radius: 12,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        assignee!.fullName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  )
                else
                  Text(
                    AppStrings.unassigned,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: onViewDetails,
                child: const Text(AppStrings.viewDetails),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    bool isManager,
    bool isAssignee,
  ) {
    if (isManager) {
      return IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onEdit,
        tooltip: AppStrings.editTask,
      );
    } else if (isAssignee) {
      return PopupMenuButton<TaskStatus>(
        onSelected: (TaskStatus newStatus) {
          onStatusChange?.call(newStatus);
        },
        itemBuilder:
            (BuildContext context) =>
                TaskStatus.values
                    .map(
                      (status) => PopupMenuItem<TaskStatus>(
                        value: status,
                        child: Text(status.toString().split('.').last),
                      ),
                    )
                    .toList(),
        child: const Chip(
          label: Text(AppStrings.changeStatus),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
