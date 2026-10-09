import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/status_chip.dart';

/// Full details of a task with live updates and the status control.
/// [onEdit] shows an edit button when the viewer is allowed to edit the task.
class TaskDetailsScreen extends StatefulWidget {
  final String taskId;
  final void Function(BuildContext context, TaskModel task)? onEdit;

  const TaskDetailsScreen({super.key, required this.taskId, this.onEdit});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late final Stream<TaskModel?> _stream;
  bool _updating = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _stream = context.read<TaskService>().watchTask(widget.taskId);
  }

  Future<void> _setStatus(TaskModel task, String status) async {
    if (status == task.status) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _updating = true);
    try {
      await context.read<TaskService>().updateStatus(task.id, status);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not update the status. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  /// The task was deleted (here or on another device): leave the screen.
  void _closeOnce() {
    if (_closing) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  String _assignedBy(TaskModel task) {
    if (task.isAdminAssigned) return 'Admin';
    return task.assignedToName.isEmpty
        ? 'Self-created'
        : '${task.assignedToName} (self-created)';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskModel?>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Details')),
            body: const ErrorView(message: 'Could not load this task.'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Details')),
            body: const LoadingView(),
          );
        }

        final task = snapshot.data;
        if (task == null) {
          _closeOnce();
          return Scaffold(
            appBar: AppBar(title: const Text('Task Details')),
            body: const LoadingView(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Task Details'),
            actions: [
              if (widget.onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit task',
                  onPressed: () => widget.onEdit!(context, task),
                ),
            ],
          ),
          body: _buildBody(context, task),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TaskModel task) {
    final overdue = task.isOverdue;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          task.title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            StatusChip.forStatus(task.status),
            if (overdue)
              const StatusChip(label: 'Overdue', color: AppTheme.overdue),
            if (task.isAdminAssigned)
              const StatusChip(
                label: 'Assigned by admin',
                color: AppTheme.primary,
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Description', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          task.description.isEmpty ? 'No description' : task.description,
          style: TextStyle(
            color: task.description.isEmpty ? Colors.grey : null,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(
                  label: 'Due date',
                  value: AppDates.format(task.dueDate),
                  valueColor: overdue ? AppTheme.overdue : null,
                ),
                _InfoRow(label: 'Assigned to', value: task.assignedToName),
                _InfoRow(label: 'Assigned by', value: _assignedBy(task)),
                if (task.createdAt != null)
                  _InfoRow(
                    label: 'Created',
                    value: AppDates.format(task.createdAt!),
                  ),
                if (task.completedAt != null)
                  _InfoRow(
                    label: 'Completed',
                    value: AppDates.format(task.completedAt!),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Status', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: [
            for (final status in TaskStatus.all)
              ButtonSegment(
                value: status,
                label: Text(
                  TaskStatus.label(status),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
          selected: {task.status},
          onSelectionChanged:
              _updating ? null : (s) => _setStatus(task, s.first),
        ),
        if (_updating)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
