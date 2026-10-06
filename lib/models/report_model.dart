import '../core/constants/app_constants.dart';
import 'task_model.dart';

class ReportModel {
  final int total;
  final int todo;
  final int inProgress;
  final int completed;
  final int overdue;
  final int completedOnTime;

  const ReportModel({
    required this.total,
    required this.todo,
    required this.inProgress,
    required this.completed,
    required this.overdue,
    required this.completedOnTime,
  });

  /// Completed / total x 100 (0 if there are no tasks).
  double get completionRate => total == 0 ? 0 : completed / total * 100;

  /// Completed on or before the due date / completed x 100 (0 if none completed).
  double get onTimeRate =>
      completed == 0 ? 0 : completedOnTime / completed * 100;

  factory ReportModel.fromTasks(List<TaskModel> tasks) {
    var todo = 0;
    var inProgress = 0;
    var completed = 0;
    var overdue = 0;
    var onTime = 0;

    for (final task in tasks) {
      switch (task.status) {
        case TaskStatus.inProgress:
          inProgress++;
        case TaskStatus.completed:
          completed++;
          if (task.completedOnTime) onTime++;
        default:
          todo++;
      }
      if (task.isOverdue) overdue++;
    }

    return ReportModel(
      total: tasks.length,
      todo: todo,
      inProgress: inProgress,
      completed: completed,
      overdue: overdue,
      completedOnTime: onTime,
    );
  }
}
