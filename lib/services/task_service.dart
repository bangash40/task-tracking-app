import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _db;

  TaskService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _db.collection(FirestoreCollections.tasks);

  /// Live list of the tasks assigned to an intern, sorted by due date.
  /// Sorting is done on the client to avoid a composite index.
  Stream<List<TaskModel>> watchTasksForIntern(String uid) {
    return _tasks.where('assignedTo', isEqualTo: uid).snapshots().map((snap) {
      final tasks = snap.docs.map(TaskModel.fromDoc).toList();
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return tasks;
    });
  }

  /// Live list of every task (admin only), sorted by due date.
  Stream<List<TaskModel>> watchAllTasks() {
    return _tasks.snapshots().map((snap) {
      final tasks = snap.docs.map(TaskModel.fromDoc).toList();
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return tasks;
    });
  }

  Future<void> createTask(TaskModel task) async {
    await _tasks.add(task.toCreateMap());
  }

  Future<void> updateTask(TaskModel task) {
    return _tasks.doc(task.id).update(task.toUpdateMap());
  }

  /// Live view of a single task; emits null if it has been deleted.
  Stream<TaskModel?> watchTask(String taskId) {
    return _tasks.doc(taskId).snapshots().map(
          (doc) => doc.exists ? TaskModel.fromDoc(doc) : null,
        );
  }

  /// Changes only the status fields. `completedAt` is set when the task is
  /// completed and cleared if it is moved back.
  Future<void> updateStatus(String taskId, String status) {
    return _tasks.doc(taskId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt':
          status == TaskStatus.completed ? FieldValue.serverTimestamp() : null,
    });
  }

  Future<void> deleteTask(String taskId) {
    return _tasks.doc(taskId).delete();
  }
}
