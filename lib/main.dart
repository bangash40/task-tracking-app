import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'widgets/empty_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracking App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        appBar: AppBar(title: const Text('Task Tracking App')),
        body: const EmptyView(message: 'Firebase connected'),
      ),
    );
  }
}
