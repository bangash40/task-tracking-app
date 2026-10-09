import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/task_service.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/task_card.dart';
import '../shared/task_form_screen.dart';
import 'open_task.dart';

/// One intern's tasks, with a button to assign a new task to them.
/// Performance metrics are added to this screen in a later step.
class InternPerformanceScreen extends StatefulWidget {
  final UserModel intern;

  const InternPerformanceScreen({super.key, required this.intern});

  @override
  State<InternPerformanceScreen> createState() =>
      _InternPerformanceScreenState();
}

class _InternPerformanceScreenState extends State<InternPerformanceScreen> {
  late Stream<List<TaskModel>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _openStream();
  }

  Stream<List<TaskModel>> _openStream() =>
      context.read<TaskService>().watchTasksForIntern(widget.intern.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.intern.name)),
      body: StreamBuilder<List<TaskModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(
              message: 'Could not load tasks.',
              onRetry: () => setState(() => _stream = _openStream()),
            );
          }
          if (!snapshot.hasData) return const LoadingView();

          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return EmptyView(
              message: '${widget.intern.name} has no tasks yet.',
              icon: Icons.checklist,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: tasks.length,
            itemBuilder: (context, i) => TaskCard(
              task: tasks[i],
              onTap: () => openTaskAsAdmin(context, tasks[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaskFormScreen(assignee: widget.intern),
          ),
        ),
        icon: const Icon(Icons.add_task),
        label: const Text('Assign Task'),
      ),
    );
  }
}
