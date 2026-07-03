import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/models/student.dart';

class StudentService {
  static const int maxPhotoSizeBytes = 1024 * 1024;

  SupabaseClient get _client => Supabase.instance.client;

  static bool shouldDeleteParent(int otherActiveStudentCount) {
    return otherActiveStudentCount <= 0;
  }

  Future<List<Student>> fetchStudents({String? parentId}) async {
    var query = _client.from('students').select('*, years(*)').eq('deleted', 0);
    if (parentId != null) {
      if (parentId.isEmpty) {
        return [];
      }
      query = query.eq('parent_id', parentId);
    }

    final response = await query;
    final rows = (response as List).cast<Map<String, dynamic>>();
    return rows.map(Student.fromMap).toList();
  }

  Future<List<Map<String, dynamic>>> fetchYears() async {
    final response = await _client
        .from('years')
        .select('id, name')
        .eq('deleted', 0)
        .order('order_no', ascending: true);
    return (response as List).cast<Map<String, dynamic>>();
  }

  static String? validatePhotoSize(int sizeInBytes) {
    if (sizeInBytes <= maxPhotoSizeBytes) {
      return null;
    }
    return 'Photo must be under 1 MB.';
  }

  Future<String> uploadStudentPhoto({
    required XFile photo,
    required String studentId,
  }) async {
    final photoBytes = await photo.readAsBytes();
    final validationMessage = validatePhotoSize(photoBytes.length);
    if (validationMessage != null) {
      throw ArgumentError(validationMessage);
    }

    final extension = photo.name.contains('.')
        ? photo.name.substring(photo.name.lastIndexOf('.'))
        : '.jpg';
    final safeStudentId = studentId.isNotEmpty
        ? studentId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
        : 'student';
    final storagePath = '$safeStudentId$extension';

    await _client.storage
        .from('profile-photos')
        .uploadBinary(
          storagePath,
          photoBytes,
          fileOptions: FileOptions(contentType: photo.mimeType ?? 'image/jpeg'),
        );

    return _client.storage.from('profile-photos').getPublicUrl(storagePath);
  }

  Future<void> createStudent(Student student) async {
    await _client.from('students').insert({
      'student_id': student.studentId,
      'name': student.name,
      'parent_id': student.parentName.isEmpty ? null : student.parentName,
      'year_id': student.year.isEmpty ? null : student.year,
      'photo_url': student.photoUrl,
      'dob': student.dob,
      'address': student.address,
      'gender': student.gender.isEmpty ? null : student.gender,
      'deleted': 0,
    });
  }

  Future<void> deleteStudent(String studentId) async {
    final studentRow = await _client
        .from('students')
        .select('parent_id')
        .eq('student_id', studentId)
        .maybeSingle();

    final parentId = studentRow?['parent_id']?.toString();

    await _client
        .from('students')
        .update({'deleted': 1})
        .eq('student_id', studentId);

    if (parentId == null || parentId.isEmpty) {
      return;
    }

    final otherActiveStudents = await _client
        .from('students')
        .select('id')
        .eq('parent_id', parentId)
        .eq('deleted', 0)
        .neq('student_id', studentId)
        .limit(1);

    final otherActiveStudentCount = (otherActiveStudents as List).length;
    if (!shouldDeleteParent(otherActiveStudentCount)) {
      return;
    }

    await _client.from('parents').update({'deleted': 1}).eq('id', parentId);

    try {
      final parentRow = await _client
          .from('parents')
          .select('profile_id')
          .eq('id', parentId)
          .maybeSingle();

      final profileId = parentRow?['profile_id']?.toString();
      if (profileId != null && profileId.isNotEmpty) {
        await _client
            .from('profiles')
            .update({'deleted': 1})
            .eq('id', profileId);
      }
    } catch (error) {
      debugPrint(
        'Failed to update related profiles for parent $parentId: $error',
      );
    }
  }
}
