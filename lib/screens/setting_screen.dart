import 'package:flutter/material.dart';
import 'package:hism_management_system/screens/login_page.dart';
import 'package:hism_management_system/services/remember_me_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  String username = "Loading...";
  String lastLogin = "Loading...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() {
    final user = supabase.auth.currentUser;

    if (user != null) {
      setState(() {
        username =
            user.userMetadata?['display_name'] ??
            user.userMetadata?['username'] ??
            user.email ??
            "Unknown User";

        if (user.lastSignInAt != null) {
          DateTime localTime = DateTime.parse(user.lastSignInAt!).toLocal();
          lastLogin =
              "${localTime.day}/${localTime.month}/${localTime.year} at ${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}";
        } else {
          lastLogin = "N/A";
        }

        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await RememberMeStorage.clearCredentials();
      await supabase.auth.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Shows loader while data parses
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Icon(
                      Icons.account_circle,
                      size: 92,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                            title: const Text(
                              'Username',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            subtitle: Text(
                              username,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(
                              Icons.access_time,
                              color: Colors.grey,
                            ),
                            title: const Text(
                              'Last Login',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            subtitle: Text(
                              lastLogin,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Logout Button
                  ElevatedButton.icon(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
    );
  }
}
