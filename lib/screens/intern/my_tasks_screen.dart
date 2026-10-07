import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../providers/auth_provider.dart';
import '../../services/task_service.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../models/task_model.dart';
import 'task_form_screen.dart';

/// Basic task list with an add button. The full list with filters and
/// badges replaces this in the next step.
class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().profile!.uid;

    return Scaffold(
      body: StreamBuilder<List<TaskModel>>(
        stream: context.read<TaskService>().watchTasksForIntern(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorView(message: 'Could not load your tasks.');
          }
          if (!snapshot.hasData) return const LoadingView();

          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return const EmptyView(
              message: 'No tasks yet. Tap + to add one.',
              icon: Icons.checklist,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: tasks.length,
            itemBuilder: (context, i) {
              final task = tasks[i];
              return Card(
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text('Due ${AppDates.format(task.dueDate)}'),
                  onTap: task.isAdminAssigned
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TaskFormScreen(task: task),
                            ),
                          ),
                ),
              );
            },
          );
        },
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
