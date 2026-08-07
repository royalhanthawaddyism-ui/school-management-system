import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/models/teacher.dart';

class TeacherService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const int maxPhotoSizeBytes = 1024 * 1024;

  Future<List<Teacher>> getActiveTeachers() async {
    try {
      final response = await _supabase
          .from('teachers')
          .select(
            'id, employee_id, name, photo_url, subject, dob, gender, phone, address, joining_date',
          )
          .eq('deleted', 0)
          .order('name', ascending: true);

      return (response as List).map((json) => Teacher.fromJson(json)).toList();
    } catch (e) {
      throw Exception('can not get data- $e');
    }
  }

  Future<void> createTeacher(Teacher teacher) async {
    try {
      await _supabase.from('teachers').insert(teacher.toJson());
    } catch (error) {
      throw Exception('Database operation failed: $error');
    }
  }

  Future<void> updateTeacher(Teacher teacher) async {
    final teacherId = teacher.id;
    if (teacherId == null) {
      throw Exception('Teacher id is required for update.');
    }

    try {
      await _supabase
          .from('teachers')
          .update(teacher.toJson())
          .eq('id', teacherId);
    } catch (error) {
      throw Exception('Database operation failed: $error');
    }
  }

  static String? validatePhotoSize(int sizeInBytes) {
    if (sizeInBytes <= maxPhotoSizeBytes) {
      return null;
    }
    return 'Photo must be under 1 MB.';
  }

  Future<String> uploadTeacherPhoto({
    required XFile photo,
    required String employeeId,
  }) async {
    final photoBytes = await photo.readAsBytes();
    final validationMessage = validatePhotoSize(photoBytes.length);
    if (validationMessage != null) {
      throw ArgumentError(validationMessage);
    }

    final extension = photo.name.contains('.')
        ? photo.name.substring(photo.name.lastIndexOf('.'))
        : '.jpg';
    final safeEmployeeId = employeeId.isNotEmpty
        ? employeeId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
        : 'teacher';
    final storagePath = '$safeEmployeeId$extension';

    await _supabase.storage
        .from('profile-photos')
        .uploadBinary(
          storagePath,
          photoBytes,
          fileOptions: FileOptions(contentType: photo.mimeType ?? 'image/jpeg'),
        );

    return _supabase.storage.from('profile-photos').getPublicUrl(storagePath);
  }

  Future<void> deleteTeacher(String employeeId) async {
    try {
      await _supabase
          .from('teachers')
          .update({'deleted': 1})
          .eq('employee_id', employeeId);
    } catch (e) {
      throw Exception('can not delete teacher- $e');
    }
  }
}
