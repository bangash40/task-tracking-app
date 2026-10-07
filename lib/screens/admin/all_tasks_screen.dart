import 'package:flutter/material.dart';

import '../../widgets/empty_view.dart';

/// Placeholder until real-time task monitoring is added.
class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyView(
      message: 'All interns\' tasks will appear here',
      icon: Icons.checklist,
    );
  }
}
