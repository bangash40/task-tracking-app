class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String tasks = 'tasks';
}

class UserRoles {
  UserRoles._();

  static const String intern = 'intern';
  static const String admin = 'admin';
}

class TaskStatus {
  TaskStatus._();

  static const String todo = 'todo';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';

  static const List<String> all = [todo, inProgress, completed];

  static String label(String status) {
    switch (status) {
      case todo:
        return 'To Do';
      case inProgress:
        return 'In Progress';
      case completed:
        return 'Completed';
      default:
        return status;
    }
  }
}
