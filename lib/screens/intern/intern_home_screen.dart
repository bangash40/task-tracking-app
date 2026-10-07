import 'package:flutter/material.dart';

import '../../widgets/logout_button.dart';
import 'my_progress_screen.dart';
import 'my_tasks_screen.dart';

class InternHomeScreen extends StatefulWidget {
  const InternHomeScreen({super.key});

  @override
  State<InternHomeScreen> createState() => _InternHomeScreenState();
}

class _InternHomeScreenState extends State<InternHomeScreen> {
  static const _titles = ['My Tasks', 'My Progress'];
  static const _pages = [MyTasksScreen(), MyProgressScreen()];

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: const [LogoutButton()],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'My Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'My Progress',
          ),
        ],
      ),
    );
  }
}
