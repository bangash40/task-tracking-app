import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_app/core/constants/app_constants.dart';
import 'package:task_tracking_app/models/report_model.dart';
import 'package:task_tracking_app/models/task_model.dart';

TaskModel task(String status, DateTime due, {DateTime? completedAt}) {
  return TaskModel(
    title: 't',
    status: status,
    dueDate: due,
    assignedTo: 'u1',
    assignedToName: 'Intern',
    createdBy: 'u1',
    createdByRole: UserRoles.intern,
    completedAt: completedAt,
  );
}

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final past = today.subtract(const Duration(days: 3));
  final future = today.add(const Duration(days: 3));

  test('empty list gives zero rates', () {
    final r = ReportModel.fromTasks([]);
    expect(r.total, 0);
    expect(r.completionRate, 0);
    expect(r.onTimeRate, 0);
  });

  test('counts, rates and overdue', () {
    final r = ReportModel.fromTasks([
      task(TaskStatus.todo, past),
      task(TaskStatus.inProgress, future),
      task(TaskStatus.completed, past,
          completedAt: past.add(const Duration(hours: 5))),
      task(TaskStatus.completed, past, completedAt: today),
    ]);
    expect(r.total, 4);
    expect(r.todo, 1);
    expect(r.inProgress, 1);
    expect(r.completed, 2);
    expect(r.overdue, 1);
    expect(r.completionRate, 50);
    expect(r.onTimeRate, 50);
  });
}
