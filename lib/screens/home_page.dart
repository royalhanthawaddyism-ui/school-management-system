import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/screens/admin_announcement_list_screen.dart';
import 'package:hism_management_system/screens/group_chat_screen.dart';

import 'package:hism_management_system/screens/profile_list_screen.dart';
import 'package:hism_management_system/screens/teacher_attendance_admin_view.dart';
import 'package:hism_management_system/screens/timetables_screen.dart';
import 'package:hism_management_system/setup/setup_list_screen.dart';
import 'package:hism_management_system/screens/setting_screen.dart';
import 'package:hism_management_system/screens/student_list_screen.dart';
import 'package:hism_management_system/screens/teacher_list_screen.dart';
import 'package:hism_management_system/screens/teacher_attendance_self_view.dart';
import 'package:hism_management_system/services/announcement_read_local_store.dart';

class HomePage extends StatefulWidget {
  final String role;
  final String? parentId;

  const HomePage({super.key, required this.role, this.parentId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final AnnouncementReadLocalStore _announcementReadStore =
      AnnouncementReadLocalStore();

  int _selectedIndex = 0;
  bool _hasUnreadNotices = false;
  List<DateTime> _latestAnnouncementDates = [];

  bool get isAdmin => widget.role == '1';

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUnreadAnnouncementStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUnreadAnnouncementStatus();
    }
  }

  Future<void> _loadUnreadAnnouncementStatus() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;

    try {
      final rows = await Supabase.instance.client
          .from('announcements')
          .select('created_at')
          .order('created_at', ascending: false);

      final createdAts = <DateTime>[];
      for (final row in rows) {
        final raw = row['created_at'];
        if (raw is DateTime) {
          createdAts.add(raw);
        } else if (raw != null) {
          final parsed = DateTime.tryParse(raw.toString());
          if (parsed != null) createdAts.add(parsed);
        }
      }

      final unread = await _announcementReadStore.hasUnreadAnnouncements(
        userId: userId,
        announcementCreatedAts: createdAts,
      );

      if (!mounted) return;
      setState(() {
        _latestAnnouncementDates = createdAts;
        _hasUnreadNotices = unread;
      });
    } catch (_) {
      // Network error ဖြစ်လျှင် existing badge state ကို ထိန်းထားမည်
    }
  }

  Future<void> _openSchoolNotices() async {
    final userId = _currentUserId;
    if (userId != null && userId.isNotEmpty) {
      DateTime? newestDate;
      if (_latestAnnouncementDates.isNotEmpty) {
        newestDate = _latestAnnouncementDates.reduce(
          (a, b) => a.isAfter(b) ? a : b,
        );
      }

      await _announcementReadStore.markAllAsSeen(
        userId,
        latestTimestamp: newestDate,
      );

      if (mounted) {
        setState(() {
          _hasUnreadNotices = false;
        });
      }
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminAnnouncementListScreen(role: widget.role),
      ),
    );

    if (!mounted) return;
    await _loadUnreadAnnouncementStatus();
  }

  List<String> get _pageTitles =>
      isAdmin ? _pageTitlesForAdmin : _pageTitlesForNormal;

  List<BottomNavigationBarItem> get _navigationItems =>
      isAdmin ? _navigationItemsForAdmin : _navigationItemsForNormal;

  List<Widget> get _pages => [
    _HomeTab(
      role: widget.role,
      parentId: widget.parentId,
      hasUnreadNotices: _hasUnreadNotices,
      onOpenSchoolNotices: _openSchoolNotices,
    ),
    if (isAdmin) ProfileListScreen(),
    if (isAdmin) const SetupListScreen(),
  ];

  static const _pageTitlesForNormal = ['Royal Hanthawaddy ISM'];

  static const _navigationItemsForNormal = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
  ];

  static const _pageTitlesForAdmin = [
    'Royal Hanthawaddy ISM',
    'User Accounts',
    'Setup Data',
  ];

  static const _navigationItemsForAdmin = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User Accounts'),
    BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Setup Data'),
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
  final bool hasUnreadNotices;
  final Future<void> Function() onOpenSchoolNotices;

  const _HomeTab({
    required this.role,
    this.parentId,
    required this.hasUnreadNotices,
    required this.onOpenSchoolNotices,
  });

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
        destination: const TimetablesScreen(),
      ),
      if (role != '3')
        _MenuItem(
          icon: Icons.watch_later,
          label: 'Teacher Attendance',
          destination: role == '1'
              ? const TeacherAttendanceAdminView()
              : const TeacherAttendanceSelfView(),
        ),
      _MenuItem(
        icon: Icons.notifications,
        label: 'School Notices',
        destination: AdminAnnouncementListScreen(role: role),
        showBadge: hasUnreadNotices,
        onTapOverride: onOpenSchoolNotices,
      ),
      const _MenuItem(
        icon: Icons.groups,
        label: 'Community',
        destination: GroupChatScreen(),
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
  final bool showBadge;
  final Future<void> Function()? onTapOverride;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.destination,
    this.showBadge = false,
    this.onTapOverride,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuItem menuItem;

  const _MenuCard({required this.menuItem});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (menuItem.onTapOverride != null) {
                  menuItem.onTapOverride!();
                  return;
                }
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
          ),
        ),
        if (menuItem.showBadge)
          Positioned(
            top: -5,
            right: -5,
            child: IgnorePointer(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  '!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
