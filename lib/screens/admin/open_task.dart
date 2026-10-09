import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../shared/task_details_screen.dart';
import '../shared/task_form_screen.dart';

/// Opens a task's details as an admin. Admins can edit and delete only the
/// tasks they assigned themselves.
void openTaskAsAdmin(BuildContext context, TaskModel task) {
  final adminUid = context.read<AuthProvider>().profile!.uid;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TaskDetailsScreen(
        taskId: task.id,
        onEdit: task.createdBy == adminUid
            ? (ctx, current) => Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (_) => TaskFormScreen(task: current),
                  ),
                )
            : null,
      ),
    ),
  );
}
