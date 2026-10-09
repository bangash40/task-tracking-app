import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/report_model.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/report_view.dart';
import '../../widgets/stat_tile.dart';
import 'intern_performance_screen.dart';

/// Overall summary across all interns, with each intern's completion rate.
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late Stream<List<UserModel>> _internsStream;
  late Stream<List<TaskModel>> _tasksStream;

  @override
  void initState() {
    super.initState();
    _openStreams();
  }

  void _openStreams() {
    _internsStream = context.read<UserService>().watchInterns();
    _tasksStream = context.read<TaskService>().watchAllTasks();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: _internsStream,
      builder: (context, internsSnap) {
        return StreamBuilder<List<TaskModel>>(
          stream: _tasksStream,
          builder: (context, tasksSnap) {
            if (internsSnap.hasError || tasksSnap.hasError) {
              return ErrorView(
                message: 'Could not load the summary.',
                onRetry: () => setState(_openStreams),
              );
            }
            if (!internsSnap.hasData || !tasksSnap.hasData) {
              return const LoadingView();
            }

            final interns = internsSnap.data!;
            final tasks = tasksSnap.data!;
            if (interns.isEmpty) {
              return const EmptyView(
                message: 'No interns have registered yet.',
                icon: Icons.people_outline,
              );
            }

            return _buildSummary(context, interns, tasks);
          },
        );
      },
    );
  }

  Widget _buildSummary(
    BuildContext context,
    List<UserModel> interns,
    List<TaskModel> tasks,
  ) {
    final tasksByIntern = <String, List<TaskModel>>{};
    for (final task in tasks) {
      tasksByIntern.putIfAbsent(task.assignedTo, () => []).add(task);
    }

    final rows = [
      for (final intern in interns)
        _InternRate(
          intern: intern,
          report: ReportModel.fromTasks(tasksByIntern[intern.uid] ?? const []),
        ),
    ]..sort((a, b) {
        final byRate = b.report.completionRate.compareTo(a.report.completionRate);
        if (byRate != 0) return byRate;
        return b.report.total.compareTo(a.report.total);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StatTile(
          label: 'Total interns',
          value: '${interns.length}',
          icon: Icons.people_outline,
          color: AppTheme.primary,
        ),
        const SizedBox(height: 12),
        ReportView(report: ReportModel.fromTasks(tasks)),
        const SizedBox(height: 24),
        Text(
          'Intern performance',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Ranked by completion rate',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < rows.length; i++)
          _InternRateTile(rank: i + 1, row: rows[i]),
      ],
    );
  }
}

class _InternRate {
  final UserModel intern;
  final ReportModel report;

  const _InternRate({required this.intern, required this.report});
}

class _InternRateTile extends StatelessWidget {
  final int rank;
  final _InternRate row;

  const _InternRateTile({required this.rank, required this.row});

  @override
  Widget build(BuildContext context) {
    final report = row.report;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InternPerformanceScreen(intern: row.intern),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(radius: 14, child: Text('$rank')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.intern.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (report.completionRate / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        color: AppTheme.completed,
                        backgroundColor:
                            AppTheme.completed.withValues(alpha: 0.15),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      report.total == 0
                          ? 'No tasks'
                          : '${report.completed}/${report.total} completed'
                              '${report.overdue > 0 ? ' · ${report.overdue} overdue' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                ReportView.percent(report.completionRate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.completed,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
