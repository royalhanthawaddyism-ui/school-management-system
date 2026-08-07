import 'package:flutter/material.dart';
import 'package:hism_management_system/models/teacher.dart';
import 'package:hism_management_system/services/teacher_service.dart';
import 'package:image_picker/image_picker.dart';

class TeacherController extends ChangeNotifier {
  TeacherController({this._teacherService});

  TeacherService? _teacherService;
  TeacherService get teacherService {
    _teacherService ??= TeacherService();
    return _teacherService!;
  }

  final formKey = GlobalKey<FormState>();

  final employeeIdController = TextEditingController();
  final nameController = TextEditingController();
  final subjectController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();
  final joiningDateController = TextEditingController();

  XFile? selectedPhoto;
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
  String? existingPhotoUrl;
  Teacher? _editingTeacher;

  List<Teacher> get teachers => _teachers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEditing => _editingTeacher != null;

  void setGender(String? value) {
    selectedGender = value;
    notifyListeners();
  }

  void populateFromTeacher(Teacher teacher) {
    _editingTeacher = teacher;
    existingPhotoUrl = teacher.photoUrl;

    employeeIdController.text = teacher.employeeId;
    nameController.text = teacher.name;
    subjectController.text = teacher.subject;
    dobController.text = teacher.formattedDob;
    phoneController.text = teacher.phone ?? '';
    addressController.text = teacher.address ?? '';
    joiningDateController.text = teacher.formattedJoiningDate;

    _selectedDob = teacher.dob;
    _selectedJoiningDate = teacher.joiningDate;
    selectedGender = teacher.gender;
    selectedPhoto = null;

    notifyListeners();
  }

  Future<void> loadTeachers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _teachers = await teacherService.getActiveTeachers();
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

    String photoUrl = existingPhotoUrl ?? '';
    if (selectedPhoto != null) {
      photoUrl = await teacherService.uploadTeacherPhoto(
        photo: selectedPhoto!,
        employeeId: employeeIdController.text.trim(),
      );
    }

    final teacherToSave = Teacher(
      id: _editingTeacher?.id,
      employeeId: employeeIdController.text.trim(),
      name: nameController.text.trim(),
      photoUrl: photoUrl,
      subject: subjectController.text.trim(),
      dob: _selectedDob!,
      gender: selectedGender ?? '',
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      joiningDate: _selectedJoiningDate!,
    );

    try {
      if (isEditing) {
        await teacherService.updateTeacher(teacherToSave);
        // ignore: use_build_context_synchronously
        _showSnackBar(context, 'Teacher updated successfully!', Colors.green);
      } else {
        await teacherService.createTeacher(teacherToSave);
        // ignore: use_build_context_synchronously
        _showSnackBar(context, 'Teacher recorded successfully!', Colors.green);
      }
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

  Future<void> pickPhoto({required BuildContext context}) async {
    try {
      final photo = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (photo == null) {
        return;
      }

      final photoBytes = await photo.readAsBytes();
      final validationMessage = TeacherService.validatePhotoSize(
        photoBytes.length,
      );
      if (validationMessage != null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(validationMessage)));
        return;
      }

      selectedPhoto = photo;
      notifyListeners();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to choose photo: $error')));
    }
  }

  @override
  void dispose() {
    employeeIdController.dispose();
    nameController.dispose();
    subjectController.dispose();
    dobController.dispose();
    phoneController.dispose();
    addressController.dispose();
    joiningDateController.dispose();
    super.dispose();
  }
}
