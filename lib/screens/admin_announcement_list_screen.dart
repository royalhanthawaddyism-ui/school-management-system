import 'package:flutter/material.dart';
import 'package:hism_management_system/models/announcement.dart';
import 'package:hism_management_system/screens/admin_announcement_add_screen.dart';
import '../controllers/announcement_controller.dart';

class AdminAnnouncementListScreen extends StatefulWidget {
  final String? role;

  const AdminAnnouncementListScreen({super.key, this.role});

  @override
  State<AdminAnnouncementListScreen> createState() =>
      _AdminAnnouncementListScreenState();
}

class _AdminAnnouncementListScreenState
    extends State<AdminAnnouncementListScreen> {
  final AnnouncementController _controller = AnnouncementController();

  bool _isAdmin = false;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _initRoleCheck();
  }

  Future<void> _initRoleCheck() async {
    bool isAdmin = await _controller.checkIsAdmin();
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
      _isLoadingRole = false;
    });
  }

  bool _isRelevantToRole(String rawTarget, String? role) {
    if (role == '1') return true;

    final target = rawTarget.trim().toLowerCase();
    if (target.isEmpty || target == 'all') return true;

    if (role == '3') {
      return target == 'parent' || target == 'parents';
    }

    if (role == '2') {
      return target == 'teacher' || target == 'teachers';
    }

    return target == 'all';
  }

  String _formatAnnouncementDate(Announcement item) {
    final dynamic raw = item.createdAt;
    DateTime? dt;
    if (raw is DateTime) {
      dt = raw.toLocal();
    } else if (raw != null) {
      dt = DateTime.tryParse(raw.toString())?.toLocal();
    }

    if (dt == null) return '-';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$d-$m-$y';
  }

  String _formatTargetLabel(String rawTarget) {
    switch (rawTarget.trim().toLowerCase()) {
      case 'teacher':
      case 'teachers':
        return 'Teachers';
      case 'parent':
      case 'parents':
        return 'Parents';
      case 'all':
      default:
        if (rawTarget.trim().isEmpty) return 'All';
        final lower = rawTarget.trim().toLowerCase();
        return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('School Notices')),
      body: StreamBuilder<List<Announcement>>(
        stream: _controller.fetchAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoadingRole) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No announcements available.'));
          }

          final announcements = snapshot.data!
              .where((item) => _isRelevantToRole(item.targetType, widget.role))
              .toList();

          if (announcements.isEmpty) {
            return const Center(child: Text('No announcements for you.'));
          }

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final item = announcements[index];
              final dateLabel = _formatAnnouncementDate(item);
              final targetLabel = _formatTargetLabel(item.targetType);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.calendar_today, size: 15),
                            label: Text(dateLabel),
                            backgroundColor: Colors.grey.shade100,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          Chip(
                            avatar: const Icon(Icons.group_outlined, size: 16),
                            label: Text(targetLabel),
                            backgroundColor: Colors.blue.shade50,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminAnnouncementAddScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Announcement'),
            )
          : null,
    );
  }
}