import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/models/student.dart';

class StudentService {
  static const int maxPhotoSizeBytes = 1024 * 1024;

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Student>> fetchStudents() async {
    final response = await _client
        .from('students')
        .select('*, years(*)')
        .eq('deleted', 0);
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
}
