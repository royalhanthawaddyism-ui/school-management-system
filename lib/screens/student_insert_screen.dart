import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hism_management_system/models/parent.dart';
import 'package:hism_management_system/models/student.dart';
import 'package:hism_management_system/popup/existing_parent_dialog.dart';
import 'package:hism_management_system/popup/new_parent_dialog.dart';
import 'package:hism_management_system/services/parent_service.dart';
import 'package:hism_management_system/services/student_service.dart';

class StudentInsertScreen extends StatefulWidget {
  const StudentInsertScreen({super.key});

  @override
  State<StudentInsertScreen> createState() => _StudentInsertScreenState();
}

class _StudentInsertScreenState extends State<StudentInsertScreen> {
  static const _newParentOption = 'New';
  static const _existingParentOption = 'Existing';

  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _parentDisplayController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ParentService _parentService = ParentService();
  Parent? _selectedParent;
  String? _selectedParentOption;
  XFile? _selectedPhoto;
  String? _selectedGender;
  String? _selectedYearId;
  List<Map<String, dynamic>> _years = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadYears();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _nameController.dispose();
    _parentDisplayController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadYears() async {
    try {
      final years = await StudentService().fetchYears();
      if (!mounted) return;
      setState(() {
        _years = years;
        if (_years.isNotEmpty) {
          _selectedYearId = _years.first['id'].toString();
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to load years: $error')));
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (photo == null) {
        return;
      }

      final photoBytes = await photo.readAsBytes();
      final validationMessage = StudentService.validatePhotoSize(
        photoBytes.length,
      );
      if (validationMessage != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(validationMessage)));
        return;
      }

      setState(() {
        _selectedPhoto = photo;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to choose photo: $error')));
    }
  }

  Future<void> _chooseParent() async {
    if (_selectedParentOption == null) return;

    final parent = await showDialog<Parent?>(
      context: context,
      builder: (context) {
        if (_selectedParentOption == _newParentOption) {
          return const NewParentDialog();
        }
        return const ExistingParentDialog();
      },
    );

    if (parent == null) return;

    setState(() {
      _selectedParent = parent;
      _parentDisplayController.text = parent.displayName;
    });
  }

  Future<void> _pickDateOfBirth() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    setState(() {
      _dobController.text = pickedDate.toIso8601String().split('T').first;
    });
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedParent == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a parent.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final studentId = _studentIdController.text.trim();
    final name = _nameController.text.trim();
    final year = _selectedYearId ?? '';
    final dob = _dobController.text.trim();
    final address = _addressController.text.trim();
    final gender = _selectedGender ?? '';

    String? createdParentId;

    try {
      if (_selectedParentOption == _newParentOption &&
          _selectedParent != null) {
        createdParentId = await _parentService.createParent(_selectedParent!);
        _selectedParent = Parent(
          id: createdParentId,
          fatherName: _selectedParent!.fatherName,
          motherName: _selectedParent!.motherName,
          phone: _selectedParent!.phone,
          address: _selectedParent!.address,
        );
      }

      String photoUrl = '';
      if (_selectedPhoto != null) {
        photoUrl = await StudentService().uploadStudentPhoto(
          photo: _selectedPhoto!,
          studentId: studentId,
        );
      }

      final student = Student(
        studentId: studentId,
        name: name,
        parentName: _selectedParent?.id ?? '',
        year: year,
        photoUrl: photoUrl,
        dob: dob,
        address: address,
        gender: gender,
      );

      await StudentService().createStudent(student);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (createdParentId != null && createdParentId.isNotEmpty) {
        try {
          await _parentService.deleteParentById(createdParentId);
        } catch (_) {
          // Ignore rollback failure, but student creation already failed.
        }
      }
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save student: $error')),
        );
      }
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
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _studentIdController,
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
                  controller: _nameController,
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
                  initialValue: _selectedParentOption,
                  decoration: const InputDecoration(
                    labelText: 'Parent Information',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: _newParentOption,
                      child: Text('New'),
                    ),
                    DropdownMenuItem(
                      value: _existingParentOption,
                      child: Text('Existing'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedParentOption = value;
                      _selectedParent = null;
                      _parentDisplayController.clear();
                    });
                    _chooseParent();
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
                  controller: _parentDisplayController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Selected Parent',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _selectedParentOption == null
                          ? null
                          : _chooseParent,
                    ),
                  ),
                  maxLines: 1,
                  validator: (_) {
                    if (_selectedParent == null) {
                      return 'Please choose a parent.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedYearId,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(),
                  ),
                  items: _years.map((year) {
                    final yearId = year['id']?.toString() ?? '';
                    final yearName = year['name']?.toString() ?? 'Unnamed year';
                    return DropdownMenuItem<String>(
                      value: yearId,
                      child: Text(yearName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYearId = value;
                    });
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
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
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
                  onPressed: _isSaving ? null : _pickPhoto,
                  icon: const Icon(Icons.photo_camera),
                  label: Text(
                    _selectedPhoto == null
                        ? 'Select Student Photo'
                        : 'Change Student Photo',
                  ),
                ),
                if (_selectedPhoto != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${_selectedPhoto!.name}',
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
                  controller: _dobController,
                  readOnly: true,
                  onTap: _pickDateOfBirth,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDateOfBirth,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveStudent,
                  child: _isSaving
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
