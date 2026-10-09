import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/task_service.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/status_filter_bar.dart';
import '../../widgets/task_card.dart';
import '../shared/task_details_screen.dart';
import '../shared/task_form_screen.dart';

/// The intern's real-time task list with a status filter.
class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  late Stream<List<TaskModel>> _stream;
  String? _filter;

  @override
  void initState() {
    super.initState();
    _stream = _openStream();
  }

  Stream<List<TaskModel>> _openStream() {
    final uid = context.read<AuthProvider>().profile!.uid;
    return context.read<TaskService>().watchTasksForIntern(uid);
  }

  void _openTask(TaskModel task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailsScreen(
          taskId: task.id,
          // Admin-assigned tasks can only have their status changed.
          onEdit: task.isAdminAssigned
              ? null
              : (ctx, current) => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => TaskFormScreen(task: current),
                    ),
                  ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StatusFilterBar(
            selected: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorView(
                    message: 'Could not load your tasks.',
                    onRetry: () => setState(() => _stream = _openStream()),
                  );
                }
                if (!snapshot.hasData) return const LoadingView();

                final all = snapshot.data!;
                if (all.isEmpty) {
                  return const EmptyView(
                    message: 'No tasks yet. Tap Add Task to create one.',
                    icon: Icons.checklist,
                  );
                }

                final tasks = _filter == null
                    ? all
                    : all.where((t) => t.status == _filter).toList();
                if (tasks.isEmpty) {
                  return EmptyView(
                    message: 'No ${TaskStatus.label(_filter!)} tasks.',
                    icon: Icons.filter_list_off,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 88),
                  itemCount: tasks.length,
                  itemBuilder: (context, i) => TaskCard(
                    task: tasks[i],
                    onTap: () => _openTask(tasks[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TaskFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
