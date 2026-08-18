class TeacherAttendanceModel {
  final String? id;
  final String teacherProfileId;
  final DateTime attendanceDate;
  final DateTime checkIn;
  final DateTime? checkOut;
  final DateTime? createdAt;

  TeacherAttendanceModel({
    this.id,
    required this.teacherProfileId,
    required this.attendanceDate,
    required this.checkIn,
    this.checkOut,
    this.createdAt,
  });

  // Supabase သို့ Check In ထည့်သွင်းရန်
  Map<String, dynamic> toInsertJson() {
    return {
      'teacher_profile_id': teacherProfileId,
      'attendance_date': attendanceDate.toIso8601String().split('T').first,
      'check_in': checkIn.toIso8601String(),
    };
  }

  // Supabase သို့ Check Out ပြင်ဆင်ရန်
  Map<String, dynamic> toUpdateCheckoutJson(DateTime checkOutTime) {
    return {'check_out': checkOutTime.toIso8601String()};
  }

  // State update ပြုလုပ်ရန် copyWith method
  TeacherAttendanceModel copyWith({
    String? id,
    String? teacherProfileId,
    DateTime? attendanceDate,
    DateTime? checkIn,
    DateTime? checkOut,
    DateTime? createdAt,
  }) {
    return TeacherAttendanceModel(
      id: id ?? this.id,
      teacherProfileId: teacherProfileId ?? this.teacherProfileId,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TeacherAttendanceModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      final parsed = DateTime.tryParse(value.toString());
      return parsed == null ? DateTime.now() : parsed.toLocal();
    }

    return TeacherAttendanceModel(
      // int (BigInt) primary key များကို String သို့ လုံခြုံစွာ ပြောင်းလဲခြင်း
      id: json['id']?.toString(),
      teacherProfileId: json['teacher_profile_id'].toString(),
      attendanceDate: parseDate(json['attendance_date']),
      checkIn: parseDate(json['check_in']),
      checkOut: json['check_out'] != null ? parseDate(json['check_out']) : null,
      createdAt: json['created_at'] != null
          ? parseDate(json['created_at'])
          : null,
    );
  }
}
