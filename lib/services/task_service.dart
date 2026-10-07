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

  Future<void> createTask(TaskModel task) async {
    await _tasks.add(task.toCreateMap());
  }

  Future<void> updateTask(TaskModel task) {
    return _tasks.doc(task.id).update(task.toUpdateMap());
  }

  Future<void> deleteTask(String taskId) {
    return _tasks.doc(taskId).delete();
  }
}
