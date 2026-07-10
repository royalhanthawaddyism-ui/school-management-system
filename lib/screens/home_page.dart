import 'package:flutter/material.dart';

import 'package:hism_management_system/screens/profile_list_screen.dart';
import 'package:hism_management_system/screens/settings_page.dart';
import 'package:hism_management_system/screens/setting_screen.dart';
import 'package:hism_management_system/screens/student_list_screen.dart';
import 'package:hism_management_system/screens/teacher_list_screen.dart';
import 'package:hism_management_system/screens/timetable_list_screen.dart';

class HomePage extends StatefulWidget {
  final String role;
  final String? parentId;

  const HomePage({super.key, required this.role, this.parentId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  bool get isAdmin => widget.role == '1';

  List<String> get _pageTitles =>
      isAdmin ? _pageTitlesForAdmin : _pageTitlesForNormal;

  List<BottomNavigationBarItem> get _navigationItems =>
      isAdmin ? _navigationItemsForAdmin : _navigationItemsForNormal;

  List<Widget> get _pages => [
    _HomeTab(role: widget.role, parentId: widget.parentId),
    if (isAdmin) ProfileListScreen(),
    if (isAdmin) const SettingsPage(),
  ];

  static const _pageTitlesForNormal = ['Royal Hanthawaddy ISM'];

  static const _navigationItemsForNormal = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
  ];

  static const _pageTitlesForAdmin = [
    'Royal Hanthawaddy ISM',
    'User Accounts',
    'Settings',
  ];

  static const _navigationItemsForAdmin = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User Accounts'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
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
      bottomNavigationBar: isAdmin
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: _navigationItems,
            )
          : null,
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String role;
  final String? parentId;

  const _HomeTab({required this.role, this.parentId});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.school,
        label: 'Students',
        destination: StudentListScreen(role: role, parentId: parentId),
      ),
      _MenuItem(
        icon: Icons.person,
        label: 'Teachers',
        destination: TeacherListScreen(role: role),
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
