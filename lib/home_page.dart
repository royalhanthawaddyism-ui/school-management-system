import 'package:flutter/material.dart';

import 'records_page.dart';
import 'settings_page.dart';
import 'setting_screen.dart';
import 'student_list_screen.dart';
import 'teacher_list_screen.dart';
import 'timetable_list_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const _pageTitles = [
    'Royal Hanthawaddy ISM',
    'Student Records',
    'Settings',
  ];

  static const _navigationItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.folder_shared), label: 'Records'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  static final List<Widget> _pages = [
    const _HomeTab(),
    const RecordsPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_pageTitles[_selectedIndex])),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _navigationItems,
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.school,
        label: 'Students',
        destination: const StudentListScreen(),
      ),
      _MenuItem(
        icon: Icons.person,
        label: 'Teachers',
        destination: const TeacherListScreen(),
      ),
      _MenuItem(
        icon: Icons.calendar_month,
        label: 'Timetables',
        destination: const TimetableListScreen(),
      ),
      _MenuItem(
        icon: Icons.settings,
        label: 'Setting',
        destination: const SettingScreen(),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: menuItems
                  .map((item) => _MenuCard(menuItem: item))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Widget destination;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.destination,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuItem menuItem;

  const _MenuCard({required this.menuItem});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => menuItem.destination),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                menuItem.icon,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(
                menuItem.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
