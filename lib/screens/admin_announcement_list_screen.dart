import 'package:flutter/material.dart';
import 'package:hism_management_system/models/announcement.dart';
import 'package:hism_management_system/screens/admin_announcement_add_screen.dart';
import '../controllers/announcement_controller.dart';

class AdminAnnouncementListScreen extends StatefulWidget {
  const AdminAnnouncementListScreen({super.key});

  @override
  State<AdminAnnouncementListScreen> createState() => _AdminAnnouncementListScreenState();
}

class _AdminAnnouncementListScreenState extends State<AdminAnnouncementListScreen> {
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
    setState(() {
      _isAdmin = isAdmin;
      _isLoadingRole = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Announcements')),
      body: StreamBuilder<List<Announcement>>(
        stream: _controller.fetchAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoadingRole) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No announcements available.'));
          }

          final announcements = snapshot.data!;

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final item = announcements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(item.body),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('Target: ${item.targetType}'),
                        backgroundColor: Colors.blue.shade50,
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
                  MaterialPageRoute(builder: (context) => const AdminAnnouncementAddScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Announcement'),
            )
          : null,
    );
  }
}