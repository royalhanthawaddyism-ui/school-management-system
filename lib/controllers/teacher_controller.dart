import 'package:flutter/material.dart';
import 'package:hism_management_system/models/teacher.dart';
import 'package:hism_management_system/services/teacher_service.dart';

class TeacherController extends ChangeNotifier {
  final TeacherService _teacherService = TeacherService();
  final formKey = GlobalKey<FormState>();

  final employeeIdController = TextEditingController();
  final nameController = TextEditingController();
  final subjectController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final photoUrlController = TextEditingController();
  final joiningDateController = TextEditingController();

  DateTime? _selectedDob;
  DateTime? get selectedDob => _selectedDob;
  DateTime? _selectedJoiningDate;
  DateTime? get selectedJoiningDate => _selectedJoiningDate;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  List<Teacher> _teachers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? selectedGender;

  List<Teacher> get teachers => _teachers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setGender(String? value) {
    selectedGender = value;
    notifyListeners();
  }

  Future<void> loadTeachers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _teachers = await _teacherService.getActiveTeachers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Teacher> filterTeachers(List<Teacher> list, String query) {
    if (query.isEmpty) return list;

    final lowerQuery = query.toLowerCase();
    return list.where((teacher) {
      final nameMatch = teacher.name.toLowerCase().contains(lowerQuery);
      final subjectMatch = teacher.subject.toLowerCase().contains(lowerQuery);
      return nameMatch || subjectMatch;
    }).toList();
  }

  Future<void> pickDob({required BuildContext context}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDob ?? DateTime(1995),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _selectedDob = picked;

      final temporaryTeacherInstance = Teacher(
        employeeId: '',
        name: '',
        subject: '',
        dob: picked,
        gender: '',
        joiningDate: DateTime.now(),
      );

      dobController.text = temporaryTeacherInstance.formattedDob;
      notifyListeners();
    }
  }

  Future<void> pickJoiningDate({required BuildContext context}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedJoiningDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      _selectedJoiningDate = pickedDate;

      final temporaryTeacherInstance = Teacher(
        employeeId: '',
        name: '',
        subject: '',
        dob: selectedDob ?? DateTime(1995),
        gender: '',
        joiningDate: pickedDate,
      );

      joiningDateController.text =
          temporaryTeacherInstance.formattedJoiningDate;
      notifyListeners();
    }
  }

  Future<bool> saveTeacher({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
  }) async {
    if (!formKey.currentState!.validate()) return false;
    if (_selectedJoiningDate == null) return false;

    _isSaving = true;
    notifyListeners();

    final newTeacher = Teacher(
      employeeId: employeeIdController.text.trim(),
      name: nameController.text.trim(),
      photoUrl: photoUrlController.text.trim().isEmpty
          ? null
          : photoUrlController.text.trim(),
      subject: subjectController.text.trim(),
      dob: _selectedDob!,
      gender: selectedGender ?? '',
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      joiningDate: _selectedJoiningDate!,
    );

    try {
      await _teacherService.createTeacher(newTeacher);
      // ignore: use_build_context_synchronously
      _showSnackBar(context, 'Teacher recorded successfully!', Colors.green);
      return true;
    } catch (e) {
      _showSnackBar(
        // ignore: use_build_context_synchronously
        context,
        e.toString().replaceAll('Exception: ', ''),
        Colors.red,
      );
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  @override
  void dispose() {
    employeeIdController.dispose();
    nameController.dispose();
    subjectController.dispose();
    dobController.dispose();
    phoneController.dispose();
    addressController.dispose();
    photoUrlController.dispose();
    joiningDateController.dispose();
    super.dispose();
  }
}
