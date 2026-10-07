import 'package:flutter/material.dart';

import '../../widgets/empty_view.dart';

/// Placeholder until the progress report is added.
class MyProgressScreen extends StatelessWidget {
  const MyProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyView(
      message: 'Your progress report will appear here',
      icon: Icons.bar_chart,
    );
  }
}
