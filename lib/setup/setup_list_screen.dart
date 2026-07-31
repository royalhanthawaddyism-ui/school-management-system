import 'package:flutter/material.dart';
import 'package:hism_management_system/setup/year_list.dart';
// Import your screen files as you build them:
// import 'package:hism_management_system/screens/class_list.dart';
// import 'package:hism_management_system/screens/subject_list.dart';
// import 'package:hism_management_system/screens/grade_list.dart';
// import 'package:hism_management_system/screens/section_list.dart';
// import 'package:hism_management_system/screens/department_list.dart';
// import 'package:hism_management_system/screens/exam_term_list.dart';

class SetupListScreen extends StatelessWidget {
  const SetupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _ManageMenuItem(
        icon: Icons.calendar_today,
        label: 'Years',
        destination: const YearList(),
      ),
      _ManageMenuItem(
        icon: Icons.class_,
        label: 'Classes',
        destination: const PlaceholderScreen(title: 'Classes'),
      ),
      _ManageMenuItem(
        icon: Icons.menu_book,
        label: 'Subjects',
        destination: const PlaceholderScreen(
          title: 'Subjects',
        ), // Replace with SubjectList()
      ),
      _ManageMenuItem(
        icon: Icons.grade,
        label: 'Grades',
        destination: const PlaceholderScreen(title: 'Grades'),
      ),
      _ManageMenuItem(
        icon: Icons.groups,
        label: 'Sections',
        destination: const PlaceholderScreen(title: 'Sections'),
      ),
      _ManageMenuItem(
        icon: Icons.domain,
        label: 'Departments',
        destination: const PlaceholderScreen(title: 'Departments'),
      ),
      _ManageMenuItem(
        icon: Icons.event_repeat,
        label: 'Terms',
        destination: const PlaceholderScreen(title: 'Terms'),
      ),
      _ManageMenuItem(
        icon: Icons.meeting_room,
        label: 'Rooms',
        destination: const PlaceholderScreen(title: 'Rooms'),
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
                  .map((item) => _ManageMenuCard(menuItem: item))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageMenuItem {
  final IconData icon;
  final String label;
  final Widget destination;

  const _ManageMenuItem({
    required this.icon,
    required this.label,
    required this.destination,
  });
}

class _ManageMenuCard extends StatelessWidget {
  final _ManageMenuItem menuItem;

  const _ManageMenuCard({required this.menuItem});

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

// Temporary placeholder screen for unbuilt features
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Management Screen')),
    );
  }
}
