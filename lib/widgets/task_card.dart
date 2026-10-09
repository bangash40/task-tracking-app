import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';
import '../models/task_model.dart';
import 'status_chip.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;

  /// Shows the intern's name (used in admin lists).
  final bool showAssignee;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.showAssignee = false,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = task.isOverdue;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusChip.forStatus(task.status),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: overdue ? AppTheme.overdue : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppDates.format(task.dueDate),
                        style: TextStyle(
                          fontSize: 13,
                          color: overdue ? AppTheme.overdue : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  if (overdue)
                    const StatusChip(label: 'Overdue', color: AppTheme.overdue),
                  if (task.isAdminAssigned)
                    const StatusChip(
                      label: 'Assigned by admin',
                      color: AppTheme.primary,
                    ),
                  if (showAssignee && task.assignedToName.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          task.assignedToName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
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
