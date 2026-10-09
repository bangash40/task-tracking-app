import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/report_model.dart';
import 'stat_tile.dart';

/// Progress report for a set of tasks: rates with progress bars and counts.
/// Shared by the intern's own report and the admin's per-intern view.
class ReportView extends StatelessWidget {
  final ReportModel report;

  const ReportView({super.key, required this.report});

  static String percent(double value) => '${value.toStringAsFixed(0)}%';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RateCard(
          title: 'Completion rate',
          subtitle: '${report.completed} of ${report.total} tasks completed',
          rate: report.completionRate,
          color: AppTheme.completed,
        ),
        const SizedBox(height: 12),
        _RateCard(
          title: 'On-time completion rate',
          subtitle: report.completed == 0
              ? 'No completed tasks yet'
              : '${report.completedOnTime} of ${report.completed} completed '
                  'on or before the due date',
          rate: report.onTimeRate,
          color: AppTheme.primary,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Total tasks',
                value: '${report.total}',
                icon: Icons.assignment_outlined,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: 'Overdue',
                value: '${report.overdue}',
                icon: Icons.warning_amber_rounded,
                color: AppTheme.overdue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'To Do',
                value: '${report.todo}',
                icon: Icons.radio_button_unchecked,
                color: AppTheme.todo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: 'In Progress',
                value: '${report.inProgress}',
                icon: Icons.timelapse,
                color: AppTheme.inProgress,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: 'Completed',
                value: '${report.completed}',
                icon: Icons.check_circle_outline,
                color: AppTheme.completed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double rate;
  final Color color;

  const _RateCard({
    required this.title,
    required this.subtitle,
    required this.rate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  ReportView.percent(rate),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (rate / 100).clamp(0.0, 1.0),
                minHeight: 10,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
