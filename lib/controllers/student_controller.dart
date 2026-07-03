import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hism_management_system/models/parent.dart';
import 'package:hism_management_system/models/student.dart';
import 'package:hism_management_system/popup/existing_parent_dialog.dart';
import 'package:hism_management_system/popup/new_parent_dialog.dart';
import 'package:hism_management_system/services/parent_service.dart';
import 'package:hism_management_system/services/student_service.dart';

class StudentController extends ChangeNotifier {
  static const newParentOption = 'New';
  static const existingParentOption = 'Existing';

  final formKey = GlobalKey<FormState>();
  final studentIdController = TextEditingController();
  final nameController = TextEditingController();
  final parentDisplayController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();
  final ParentService parentService = ParentService();

  Parent? selectedParent;
  String? selectedParentOption;
  XFile? selectedPhoto;
  String? selectedGender;
  String? selectedYearId;
  List<Map<String, dynamic>> years = [];
  bool isSaving = false;

  @override
  void dispose() {
    studentIdController.dispose();
    nameController.dispose();
    parentDisplayController.dispose();
    dobController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> loadYears({required BuildContext context}) async {
    try {
      final loadedYears = await StudentService().fetchYears();
      if (!context.mounted) return;

      years = loadedYears;
      if (years.isNotEmpty) {
        selectedYearId = years.first['id'].toString();
      }
      notifyListeners();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to load years: $error')));
    }
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
      final validationMessage = StudentService.validatePhotoSize(
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

  Future<void> chooseParent({required BuildContext context}) async {
    if (selectedParentOption == null) return;

    final parent = await showDialog<Parent?>(
      context: context,
      builder: (dialogContext) {
        if (selectedParentOption == newParentOption) {
          return const NewParentDialog();
        }
        return const ExistingParentDialog();
      },
    );

    if (parent == null) return;

    selectedParent = parent;
    parentDisplayController.text = parent.displayName;
    notifyListeners();
  }

  Future<void> pickDateOfBirth({required BuildContext context}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    dobController.text = pickedDate.toIso8601String().split('T').first;
    notifyListeners();
  }

  Future<List<Student>> fetchStudents({String? parentId}) async {
    try {
      return await StudentService().fetchStudents(parentId: parentId);
    } catch (error, stackTrace) {
      debugPrint('Failed to load students: $error');
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }

  List<Student> filterStudents(List<Student> students, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return students;
    }

    return students
        .where((student) => student.matchesSearch(normalizedQuery))
        .toList();
  }

  static String formatDate(String rawDate) {
    if (rawDate.isEmpty) return 'N/A';

    try {
      final parsedDate = DateTime.parse(rawDate);
      return '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
    } catch (_) {
      return rawDate;
    }
  }

  void setParentOption(String? value) {
    selectedParentOption = value;
    selectedParent = null;
    parentDisplayController.clear();
    notifyListeners();
  }

  void setYear(String? value) {
    selectedYearId = value;
    notifyListeners();
  }

  void setGender(String? value) {
    selectedGender = value;
    notifyListeners();
  }

  Future<bool> saveStudent({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
  }) async {
    if (!formKey.currentState!.validate()) return false;
    if (selectedParent == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a parent.')));
      return false;
    }

    isSaving = true;
    notifyListeners();

    final studentId = studentIdController.text.trim();
    final name = nameController.text.trim();
    final year = selectedYearId ?? '';
    final dob = dobController.text.trim();
    final address = addressController.text.trim();
    final gender = selectedGender ?? '';

    String? createdParentId;

    try {
      if (selectedParentOption == newParentOption && selectedParent != null) {
        createdParentId = await parentService.createParent(selectedParent!);
        selectedParent = Parent(
          id: createdParentId,
          fatherName: selectedParent!.fatherName,
          motherName: selectedParent!.motherName,
          phone: selectedParent!.phone,
          address: selectedParent!.address,
        );
      }

      String photoUrl = '';
      if (selectedPhoto != null) {
        photoUrl = await StudentService().uploadStudentPhoto(
          photo: selectedPhoto!,
          studentId: studentId,
        );
      }

      final student = Student(
        studentId: studentId,
        name: name,
        parentName: selectedParent?.id ?? '',
        year: year,
        photoUrl: photoUrl,
        dob: dob,
        address: address,
        gender: gender,
      );

      await StudentService().createStudent(student);
      return true;
    } catch (error) {
      if (createdParentId != null && createdParentId.isNotEmpty) {
        try {
          await parentService.deleteParentById(createdParentId);
        } catch (_) {
          // Ignore rollback failure, but student creation already failed.
        }
      }
      if (context.mounted) {
        final errorMessage = error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save student: $errorMessage')),
        );
      }
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
