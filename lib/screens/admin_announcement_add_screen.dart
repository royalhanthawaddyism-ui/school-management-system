import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAnnouncementAddScreen extends StatefulWidget {
  const AdminAnnouncementAddScreen({super.key});

  @override
  State<AdminAnnouncementAddScreen> createState() =>
      _AdminAnnouncementAddScreenState();
}

class _AdminAnnouncementAddScreenState
    extends State<AdminAnnouncementAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  String _selectedTargetType = 'all'; // 'all', 'teachers', 'parents'
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submitAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final adminId = supabase.auth.currentUser?.id;

      await supabase.from('announcements').insert({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'target_type': _selectedTargetType,
        'admin_id': adminId,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Announcement successfully created and notifications sent!',
          ),
        ),
      );

      _titleController.clear();
      _bodyController.clear();
      setState(() {
        _selectedTargetType = 'all';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred while creating the announcement: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Announcement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
                maxLines: 4,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Please enter a body' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedTargetType,
                decoration: const InputDecoration(
                  labelText: 'Notification (Target Type)',
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(
                    value: 'teachers',
                    child: Text('All Teachers'),
                  ),
                  DropdownMenuItem(value: 'parents', child: Text('All Parents')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedTargetType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitAnnouncement,
                      child: const Text('Create Announcement & Send'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}