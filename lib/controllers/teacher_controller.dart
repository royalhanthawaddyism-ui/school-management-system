import 'package:flutter/material.dart';
import 'package:hism_management_system/models/teacher.dart';
import 'package:hism_management_system/services/teacher_service.dart';

class TeacherController extends ChangeNotifier {
  final TeacherService _teacherService = TeacherService();

  List<Teacher> _teachers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Teacher> get teachers => _teachers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
}
