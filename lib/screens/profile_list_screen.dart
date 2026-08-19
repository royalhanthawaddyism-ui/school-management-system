import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/profile_controller.dart';
import '../models/profile.dart';
import '../screens/profile_edit_screen.dart';
import 'create_profile_screen.dart';

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

  bool _filterAdmin = true;
  bool _filterTeacher = true;
  bool _filterParent = true;

  bool _isLoading = true;
  String _error = '';
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    loadProfiles();
  }

  Future<void> loadProfiles({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
    }

    try {
      final data = await _controller.fetchProfiles();

      if (!mounted) return;

      setState(() {
        _profiles = data;
        // Reset filter checkboxes to checked on every load/refresh
        _filterAdmin = true;
        _filterTeacher = true;
        _filterParent = true;
        _isLoading = false;
      });

      // Re-apply filters so the displayed list matches the reset checkbox states and search query
      applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void searchProfiles(String value) {
    applyFilters(value);
  }

  void applyFilters([String? value]) {
    final keyword = (value ?? _searchController.text).toLowerCase();

    setState(() {
      _filteredProfiles = _profiles.where((p) {
        final matchesSearch =
            p.email.toLowerCase().contains(keyword) ||
            p.roleLabel.toLowerCase().contains(keyword);

        var roleAllowed = false;
        if (_filterAdmin && p.role == '1') roleAllowed = true;
        if (_filterTeacher && p.role == '2') roleAllowed = true;
        if (_filterParent && p.role == '3') roleAllowed = true;

        return matchesSearch && roleAllowed;
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
        // ignore: use_build_context_synchronously
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        final now = DateTime.now();
        final isDoubleBack =
            _lastBackPressTime != null &&
            now.difference(_lastBackPressTime!) <= const Duration(seconds: 2);

        if (isDoubleBack) {
          SystemNavigator.pop();
          return;
        }

        _lastBackPressTime = now;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
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
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final created = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateProfileScreen(),
                          ),
                        );

                        if (created == true) {
                          loadProfiles();
                        }
                      },
                      //icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Admin
                    Row(
                      children: [
                        Checkbox(
                          value: _filterAdmin,
                          onChanged: (v) => setState(() {
                            _filterAdmin = v ?? false;
                            applyFilters();
                          }),
                        ),
                        const Text('Admin'),
                      ],
                    ),

                    const SizedBox(width: 8),

                    // Teacher
                    Row(
                      children: [
                        Checkbox(
                          value: _filterTeacher,
                          onChanged: (v) => setState(() {
                            _filterTeacher = v ?? false;
                            applyFilters();
                          }),
                        ),
                        const Text('Teacher'),
                      ],
                    ),

                    const SizedBox(width: 8),

                    // Parent
                    Row(
                      children: [
                        Checkbox(
                          value: _filterParent,
                          onChanged: (v) => setState(() {
                            _filterParent = v ?? false;
                            applyFilters();
                          }),
                        ),
                        const Text('Parent'),
                      ],
                    ),

                    const Spacer(),
                  ],
                ),
              ),

              // 📄 LIST
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => loadProfiles(showLoading: false),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error.isNotEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [Center(child: Text(_error))],
                        )
                      : _filteredProfiles.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            Center(child: Text("No profiles found")),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
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
                                  loadProfiles(showLoading: false);
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),

                                leading: const CircleAvatar(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    8,
                                    44,
                                    98,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
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

                                trailing: profile.role == '1'
                                    ? null
                                    : IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                "Delete Profile",
                                              ),
                                              content: const Text(
                                                "Are you sure you want to delete this user?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    deleteProfile(profile.id);
                                                  },
                                                  child: const Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
