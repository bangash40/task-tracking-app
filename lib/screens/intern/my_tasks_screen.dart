import 'package:flutter/material.dart';

import '../../widgets/empty_view.dart';

/// Placeholder until the real-time task list is added.
class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyView(
      message: 'Your tasks will appear here',
      icon: Icons.checklist,
    );
  }
}
