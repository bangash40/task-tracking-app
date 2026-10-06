import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/loading_view.dart';
import '../auth/login_screen.dart';

/// Shows the login screen when signed out, and the app when signed in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.initializing) {
      return const Scaffold(body: LoadingView());
    }
    if (!auth.isSignedIn) {
      return const LoginScreen();
    }
    if (auth.profile == null) {
      return const Scaffold(body: LoadingView(message: 'Loading your profile'));
    }

    // Replaced by the intern and admin homes in the next step.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Tracking App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: auth.logout,
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, ${auth.profile!.name} (${auth.profile!.role})'),
      ),
    );
  }
}
