import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/models/student.dart';

class StudentService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Student>> fetchStudents() async {
    final response = await _client.from('students').select('*, years(*)');
    final rows = (response as List).cast<Map<String, dynamic>>();
    return rows.map(Student.fromMap).toList();
  }
}
