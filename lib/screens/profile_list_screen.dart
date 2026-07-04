import 'package:flutter/material.dart';

import '../controllers/profile_controller.dart';
import '../models/profile.dart';
import '../screens/profile_edit_screen.dart';

class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({super.key});

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  final ProfileController _controller = ProfileController();
  final TextEditingController _searchController = TextEditingController();

  List<Profile> _profiles = [];
  List<Profile> _filteredProfiles = [];

  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    try {
      final data = await _controller.fetchProfiles();

      setState(() {
        _profiles = data;
        _filteredProfiles = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void searchProfiles(String value) {
    final keyword = value.toLowerCase();

    setState(() {
      _filteredProfiles = _profiles.where((p) {
        return p.email.toLowerCase().contains(keyword) ||
            p.roleLabel.toLowerCase().contains(keyword);
      }).toList();
    });
  }

  Future<void> deleteProfile(String id) async {
    try {
      await _controller.deleteProfile(id);

      setState(() {
        _profiles.removeWhere((p) => p.id == id);
        _filteredProfiles.removeWhere((p) => p.id == id);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 SEARCH BOX
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                onChanged: searchProfiles,
                decoration: InputDecoration(
                  hintText: "Search email or role",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            // 📄 LIST
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                  ? Center(child: Text(_error))
                  : _filteredProfiles.isEmpty
                  ? const Center(child: Text("No profiles found"))
                  : ListView.builder(
                      itemCount: _filteredProfiles.length,
                      itemBuilder: (context, index) {
                        final profile = _filteredProfiles[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProfileEditScreen(profile: profile),
                                ),
                              );
                              loadProfiles();
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),

                            leading: const CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Icon(Icons.person, color: Colors.white),
                            ),

                            title: Text(
                              profile.email,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            subtitle: Text(
                              profile.roleLabel,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),

                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete Profile"),
                                    content: const Text(
                                      "Are you sure you want to delete this user?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          deleteProfile(profile.id);
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
