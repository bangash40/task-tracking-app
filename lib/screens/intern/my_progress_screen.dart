import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/report_model.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/task_service.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/report_view.dart';

/// The intern's own progress report, updated live from their tasks.
class MyProgressScreen extends StatefulWidget {
  const MyProgressScreen({super.key});

  @override
  State<MyProgressScreen> createState() => _MyProgressScreenState();
}

class _MyProgressScreenState extends State<MyProgressScreen> {
  late Stream<List<TaskModel>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _openStream();
  }

  Stream<List<TaskModel>> _openStream() {
    final uid = context.read<AuthProvider>().profile!.uid;
    return context.read<TaskService>().watchTasksForIntern(uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TaskModel>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(
            message: 'Could not load your progress.',
            onRetry: () => setState(() => _stream = _openStream()),
          );
        }
        if (!snapshot.hasData) return const LoadingView();

        final tasks = snapshot.data!;
        if (tasks.isEmpty) {
          return const EmptyView(
            message: 'No tasks yet. Your progress will show here once you '
                'have tasks.',
            icon: Icons.bar_chart,
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [ReportView(report: ReportModel.fromTasks(tasks))],
        );
      },
    );
  }
}
