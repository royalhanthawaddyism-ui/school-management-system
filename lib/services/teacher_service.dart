import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/models/teacher.dart';

class TeacherService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Teacher>> getActiveTeachers() async {
    try {
      final response = await _supabase
          .from('teachers')
          .select('id, employee_id, name, photo_url, subject, joining_date')
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
