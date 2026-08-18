import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hism_management_system/models/teacher_attendance.dart';

class TeacherAttendanceService {
  final SupabaseClient _supabase = Supabase.instance.client;

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

    // Primary Key သည် integer ဖြစ်ပါက int အဖြစ်သို့ ပြောင်းပေးခြင်း
    final dynamic parsedId = int.tryParse(model.id!) ?? model.id;

    await _supabase
        .from('teacher_attendance')
        .update(model.toUpdateCheckoutJson(checkOutTime))
        .eq('id', parsedId);
  }
}
