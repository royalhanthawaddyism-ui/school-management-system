import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAnnouncementAddScreen extends StatefulWidget {
  const AdminAnnouncementAddScreen({super.key});

  @override
  State<AdminAnnouncementAddScreen> createState() => _AdminAnnouncementAddScreenState();
}

class _AdminAnnouncementAddScreenState extends State<AdminAnnouncementAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  
  String _selectedTargetType = 'all'; // 'all', 'teachers', 'parents', 'individual'
  String? _selectedIndividualUserId;
  bool _isLoading = false;

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
        'target_id': _selectedTargetType == 'individual' ? _selectedIndividualUserId : null,
        'admin_id': adminId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement successfully created and notifications sent!')),
      );

      _titleController.clear();
      _bodyController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while creating the announcement: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Announcement Panel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) => val!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: '(Body)'),
                maxLines: 4,
                validator: (val) => val!.isEmpty ? 'Please enter a body' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _selectedTargetType,
                decoration: const InputDecoration(labelText: 'Notification (Target Type)'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'teachers', child: Text('All Teachers')),
                  DropdownMenuItem(value: 'parents', child: Text('All Parents')),
                  DropdownMenuItem(value: 'individual', child: Text('Individual')),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedTargetType = val!;
                  });
                },
              ),

              if (_selectedTargetType == 'individual') ...[
                const SizedBox(height: 16),
                TextFormField(
                  onChanged: (val) => _selectedIndividualUserId = val,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    hintText: 'Enter User ID',
                  ),
                  validator: (val) => _selectedTargetType == 'individual' && (val == null || val.isEmpty) 
                      ? 'User ID is required' : null,
                ),
              ],

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