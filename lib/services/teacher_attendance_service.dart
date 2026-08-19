import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/models/teacher_attendance.dart';

class TeacherAttendanceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<TeacherAttendanceModel>> fetchAttendanceForMonth(
    int year,
    int month,
  ) async {
    final startDate = DateTime(
      year,
      month,
      1,
    ).toIso8601String().split('T').first;
    final lastDay = DateTime(year, month + 1, 0).day;
    final endDate = DateTime(
      year,
      month,
      lastDay,
    ).toIso8601String().split('T').first;

    final response = await _supabase
        .from('teacher_attendance')
        .select('*, profiles:teacher_profile_id(email)')
        .gte('attendance_date', startDate)
        .lte('attendance_date', endDate)
        .order('attendance_date', ascending: true);

    return (response as List)
        .map((data) => TeacherAttendanceModel.fromJson(data))
        .toList();
  }

  Future<TeacherAttendanceModel?> fetchTodayAttendance(
    String teacherProfileId,
    String todayDateStr,
  ) async {
    final response = await _supabase
        .from('teacher_attendance')
        .select()
        .eq('teacher_profile_id', teacherProfileId)
        .eq('attendance_date', todayDateStr)
        .maybeSingle();

    if (response == null) return null;
    return TeacherAttendanceModel.fromJson(response);
  }

  Future<TeacherAttendanceModel> insertCheckIn(
    TeacherAttendanceModel model,
  ) async {
    final response = await _supabase
        .from('teacher_attendance')
        .insert(model.toInsertJson())
        .select()
        .single();

    return TeacherAttendanceModel.fromJson(response);
  }

  Future<void> updateCheckOut(
    TeacherAttendanceModel model,
    DateTime checkOutTime,
  ) async {
    if (model.id == null) return;

    final dynamic parsedId = int.tryParse(model.id!) ?? model.id;

    await _supabase
        .from('teacher_attendance')
        .update(model.toUpdateCheckoutJson(checkOutTime))
        .eq('id', parsedId);
  }
}
