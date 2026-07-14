import 'package:flutter/material.dart';
import 'package:hism_management_system/controllers/teacher_controller.dart';

class TeacherInsertScreen extends StatefulWidget {
  const TeacherInsertScreen({super.key});

  @override
  State<TeacherInsertScreen> createState() => _TeacherInsertScreenState();
}

class _TeacherInsertScreenState extends State<TeacherInsertScreen> {
  late final TeacherController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TeacherController();
    _controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveTeacher() async {
    final saved = await _controller.saveTeacher(
      context: context,
      formKey: _controller.formKey,
    );

    if (saved && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Teacher')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _controller.formKey,
            child: ListView(
              children: [
                // --- Employee ID ---
                TextFormField(
                  controller: _controller.employeeIdController,
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Employee ID is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // --- Name ---
                TextFormField(
                  controller: _controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // --- Subject ---
                TextFormField(
                  controller: _controller.subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Subject is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // --- Date of Birth (D.O.B) --- [ထပ်တိုးထားသောအပိုင်း]
                TextFormField(
                  controller: _controller.dobController,
                  readOnly: true,
                  onTap: () => _controller.pickDob(context: context),
                  decoration: InputDecoration(
                    labelText: 'Date of Birth (D.O.B)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _controller.pickDob(context: context),
                    ),
                  ),
                  validator: (value) {
                    if (_controller.selectedDob == null) {
                      return 'Date of Birth is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // --- Photo URL --- [မူလအတိုင်း ပြန်ထားပါသည်]
                TextFormField(
                  controller: _controller.photoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Photo URL (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // --- Joining Date ---
                TextFormField(
                  controller: _controller.joiningDateController,
                  readOnly: true,
                  onTap: () => _controller.pickJoiningDate(context: context),
                  decoration: InputDecoration(
                    labelText: 'Joining Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () =>
                          _controller.pickJoiningDate(context: context),
                    ),
                  ),
                  validator: (value) {
                    if (_controller.selectedJoiningDate == null) {
                      return 'Joining Date is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // --- Save Button ---
                ElevatedButton(
                  onPressed: _controller.isSaving ? null : _saveTeacher,
                  child: _controller.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Save Teacher'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
