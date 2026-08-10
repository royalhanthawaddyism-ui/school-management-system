import 'package:flutter/material.dart';
import 'package:hism_management_system/controllers/student_controller.dart';
import 'package:hism_management_system/models/student.dart';

class StudentInsertUpdateScreen extends StatefulWidget {
  const StudentInsertUpdateScreen({super.key, this.student});

  final Student? student;

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
    if (widget.student != null) {
      _controller.populateFromStudent(widget.student!);
    }
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
    final savedStudent = await _controller.saveStudent(
      context: context,
      formKey: _controller.formKey,
    );

    if (savedStudent != null && mounted) {
      Navigator.pop(context, savedStudent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Update Student' : 'Add Student')),
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
                    if (_controller.selectedParent == null &&
                        (_controller.existingParentId == null ||
                            _controller.existingParentId!.isEmpty)) {
                      return 'Please choose a parent.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final seenIds = <String>{};
                    final items = <DropdownMenuItem<String>>[];
                    for (final year in _controller.years) {
                      final yearId = year['id']?.toString() ?? '';
                      if (yearId.isEmpty || seenIds.contains(yearId)) {
                        continue;
                      }
                      seenIds.add(yearId);
                      items.add(
                        DropdownMenuItem<String>(
                          value: yearId,
                          child: Text(
                            year['name']?.toString() ?? 'Unnamed year',
                          ),
                        ),
                      );
                    }

                    if (_controller.selectedYearId != null &&
                        _controller.selectedYearId!.isNotEmpty &&
                        !seenIds.contains(_controller.selectedYearId)) {
                      final matched = _controller.years.firstWhere(
                        (year) =>
                            year['name']?.toString() ==
                            _controller.selectedYearId,
                        orElse: () => {},
                      );
                      if (matched.isNotEmpty) {
                        _controller.selectedYearId = matched['id']?.toString();
                      }
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: items.isEmpty
                          ? null
                          : _controller.selectedYearId,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                      ),
                      items: items,
                      onChanged: (value) {
                        _controller.setYear(value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Year is required';
                        }
                        return null;
                      },
                    );
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
                      : Text(isEditing ? 'Update Student' : 'Save Student'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
