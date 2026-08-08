import 'package:flutter/material.dart';
import 'package:hism_management_system/controllers/student_controller.dart';

class StudentInsertUpdateScreen extends StatefulWidget {
  const StudentInsertUpdateScreen({super.key});

  @override
  State<StudentInsertUpdateScreen> createState() =>
      _StudentInsertUpdateScreenState();
}

class _StudentInsertUpdateScreenState extends State<StudentInsertUpdateScreen> {
  late final StudentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StudentController();
    _controller.addListener(_refresh);
    _controller.loadYears(context: context);
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

  Future<void> _saveStudent() async {
    final saved = await _controller.saveStudent(
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
      appBar: AppBar(title: const Text('Add Student')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _controller.formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _controller.studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Student ID is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
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
                DropdownButtonFormField<String>(
                  initialValue: _controller.selectedParentOption,
                  decoration: const InputDecoration(
                    labelText: 'Parent Information',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: StudentController.newParentOption,
                      child: Text('New'),
                    ),
                    DropdownMenuItem(
                      value: StudentController.existingParentOption,
                      child: Text('Existing'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    _controller.setParentOption(value);
                    _controller.chooseParent(context: context);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Parent information is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _controller.parentDisplayController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Selected Parent',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _controller.selectedParentOption == null
                          ? null
                          : () => _controller.chooseParent(context: context),
                    ),
                  ),
                  maxLines: 1,
                  validator: (_) {
                    if (_controller.selectedParent == null) {
                      return 'Please choose a parent.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _controller.selectedYearId,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(),
                  ),
                  items: _controller.years.map((year) {
                    final yearId = year['id']?.toString() ?? '';
                    final yearName = year['name']?.toString() ?? 'Unnamed year';
                    return DropdownMenuItem<String>(
                      value: yearId,
                      child: Text(yearName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _controller.setYear(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Year is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _controller.selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (value) {
                    _controller.setGender(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Gender is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _controller.isSaving
                      ? null
                      : () => _controller.pickPhoto(context: context),
                  icon: const Icon(Icons.photo_camera),
                  label: Text(
                    _controller.selectedPhoto == null
                        ? 'Select Student Photo'
                        : 'Change Student Photo',
                  ),
                ),
                if (_controller.selectedPhoto != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${_controller.selectedPhoto!.name}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Photo must be under 1 MB.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _controller.dobController,
                  readOnly: true,
                  onTap: () => _controller.pickDateOfBirth(context: context),
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () =>
                          _controller.pickDateOfBirth(context: context),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _controller.addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _controller.isSaving ? null : _saveStudent,
                  child: _controller.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Save Student'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
