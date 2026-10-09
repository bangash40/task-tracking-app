import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

/// Small coloured label for a task status, or a custom badge.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.forStatus(String status) {
    return StatusChip(
      label: TaskStatus.label(status),
      color: colorFor(status),
    );
  }

  static Color colorFor(String status) {
    switch (status) {
      case TaskStatus.inProgress:
        return AppTheme.inProgress;
      case TaskStatus.completed:
        return AppTheme.completed;
      default:
        return AppTheme.todo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
