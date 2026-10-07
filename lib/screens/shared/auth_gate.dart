import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../admin/admin_home_screen.dart';
import '../auth/login_screen.dart';
import '../intern/intern_home_screen.dart';

/// Shows the login screen when signed out, otherwise the home for the user's role.
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

    final profile = auth.profile;
    if (profile == null) {
      // Signed in but the profile did not load: show the error with a way out.
      if (auth.error != null) {
        return Scaffold(
          body: ErrorView(message: auth.error!, onRetry: auth.logout),
        );
      }
      return const Scaffold(body: LoadingView(message: 'Loading your profile'));
    }

    return profile.isAdmin
        ? const AdminHomeScreen()
        : const InternHomeScreen();
  }
}
