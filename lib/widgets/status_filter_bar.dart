import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Row of chips to filter by task status. A null selection means "All".
class StatusFilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const StatusFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = <String?>[null, ...TaskStatus.all];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final status = options[i];
          return ChoiceChip(
            label: Text(status == null ? 'All' : TaskStatus.label(status)),
            selected: selected == status,
            onSelected: (_) => onChanged(status),
          );
        },
      ),
    );
  }
}
