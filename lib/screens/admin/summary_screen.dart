import 'package:flutter/material.dart';

import '../../widgets/empty_view.dart';

/// Placeholder until the overall summary is added.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyView(
      message: 'The overall summary will appear here',
      icon: Icons.bar_chart,
    );
  }
}
