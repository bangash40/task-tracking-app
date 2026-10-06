import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime dueDate;
  final String assignedTo;
  final String assignedToName;
  final String createdBy;
  final String createdByRole;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const TaskModel({
    this.id = '',
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    required this.dueDate,
    required this.assignedTo,
    required this.assignedToName,
    required this.createdBy,
    required this.createdByRole,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  bool get isCompleted => status == TaskStatus.completed;

  bool get isAdminAssigned => createdByRole == UserRoles.admin;

  /// Not completed and the due date has passed.
  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate.isBefore(today);
  }

  /// Completed on or before the end of the due date day.
  bool get completedOnTime {
    if (!isCompleted || completedAt == null) return false;
    final endOfDue = DateTime(dueDate.year, dueDate.month, dueDate.day + 1);
    return completedAt!.isBefore(endOfDue);
  }

  factory TaskModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TaskModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: data['status'] as String? ?? TaskStatus.todo,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedTo: data['assignedTo'] as String? ?? '',
      assignedToName: data['assignedToName'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdByRole: data['createdByRole'] as String? ?? UserRoles.intern,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Fields written when a task is first created.
  Map<String, dynamic> toCreateMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'dueDate': Timestamp.fromDate(dueDate),
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'createdBy': createdBy,
      'createdByRole': createdByRole,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt': null,
    };
  }

  /// Fields written when the editable details of a task change.
  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
    String? assignedTo,
    String? assignedToName,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdBy: createdBy,
      createdByRole: createdByRole,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
    );
  }
}
