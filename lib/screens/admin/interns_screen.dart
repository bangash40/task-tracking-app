import 'package:flutter/material.dart';

import '../../widgets/empty_view.dart';

/// Placeholder until the interns list is added.
class InternsScreen extends StatelessWidget {
  const InternsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyView(
      message: 'Interns will appear here',
      icon: Icons.people_outline,
    );
  }
}
