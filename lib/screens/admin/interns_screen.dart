import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import 'intern_performance_screen.dart';

/// Live list of all registered interns.
class InternsScreen extends StatefulWidget {
  const InternsScreen({super.key});

  @override
  State<InternsScreen> createState() => _InternsScreenState();
}

class _InternsScreenState extends State<InternsScreen> {
  late Stream<List<UserModel>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = context.read<UserService>().watchInterns();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(
            message: 'Could not load interns.',
            onRetry: () => setState(
              () => _stream = context.read<UserService>().watchInterns(),
            ),
          );
        }
        if (!snapshot.hasData) return const LoadingView();

        final interns = snapshot.data!;
        if (interns.isEmpty) {
          return const EmptyView(
            message: 'No interns have registered yet.',
            icon: Icons.people_outline,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: interns.length,
          itemBuilder: (context, i) {
            final intern = interns[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    intern.name.isEmpty ? '?' : intern.name[0].toUpperCase(),
                  ),
                ),
                title: Text(intern.name),
                subtitle: Text(intern.email),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InternPerformanceScreen(intern: intern),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
