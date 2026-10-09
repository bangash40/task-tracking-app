import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/status_filter_bar.dart';
import '../../widgets/task_card.dart';
import 'open_task.dart';

/// Real-time list of all tasks across all interns, filterable by intern and status.
class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  late Stream<List<TaskModel>> _tasksStream;
  late final Stream<List<UserModel>> _internsStream;
  String? _internFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _tasksStream = context.read<TaskService>().watchAllTasks();
    _internsStream = context.read<UserService>().watchInterns();
  }

  Widget _internDropdown() {
    return StreamBuilder<List<UserModel>>(
      stream: _internsStream,
      builder: (context, snapshot) {
        final interns = snapshot.data ?? const <UserModel>[];
        // Reset a selection that no longer exists in the list.
        final value = interns.any((u) => u.uid == _internFilter)
            ? _internFilter
            : null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: DropdownButtonFormField<String?>(
            initialValue: value,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Intern',
              prefixIcon: Icon(Icons.person_outline),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All interns'),
              ),
              for (final intern in interns)
                DropdownMenuItem<String?>(
                  value: intern.uid,
                  child: Text(intern.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _internFilter = v),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _internDropdown(),
        StatusFilterBar(
          selected: _statusFilter,
          onChanged: (v) => setState(() => _statusFilter = v),
        ),
        Expanded(
          child: StreamBuilder<List<TaskModel>>(
            stream: _tasksStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorView(
                  message: 'Could not load tasks.',
                  onRetry: () => setState(
                    () => _tasksStream =
                        context.read<TaskService>().watchAllTasks(),
                  ),
                );
              }
              if (!snapshot.hasData) return const LoadingView();

              final all = snapshot.data!;
              if (all.isEmpty) {
                return const EmptyView(
                  message: 'No tasks have been created yet.',
                  icon: Icons.checklist,
                );
              }

              final tasks = all.where((t) {
                if (_internFilter != null && t.assignedTo != _internFilter) {
                  return false;
                }
                if (_statusFilter != null && t.status != _statusFilter) {
                  return false;
                }
                return true;
              }).toList();

              if (tasks.isEmpty) {
                return EmptyView(
                  message: _statusFilter == null
                      ? 'No tasks for this intern.'
                      : 'No ${TaskStatus.label(_statusFilter!)} tasks match '
                          'the filters.',
                  icon: Icons.filter_list_off,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                itemCount: tasks.length,
                itemBuilder: (context, i) => TaskCard(
                  task: tasks[i],
                  showAssignee: true,
                  onTap: () => openTaskAsAdmin(context, tasks[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
