import 'package:flutter/material.dart';

import '../../widgets/logout_button.dart';
import 'all_tasks_screen.dart';
import 'interns_screen.dart';
import 'summary_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  static const _titles = ['All Tasks', 'Interns', 'Summary'];
  static const _pages = [AllTasksScreen(), InternsScreen(), SummaryScreen()];

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
            label: 'All Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Interns',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Summary',
          ),
        ],
      ),
    );
  }
}
