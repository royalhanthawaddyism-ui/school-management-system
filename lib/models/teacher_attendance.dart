class TeacherAttendanceModel {
  final String? id;
  final String teacherProfileId;
  final String? email;
  final DateTime attendanceDate;
  final DateTime checkIn;
  final DateTime? checkOut;
  final DateTime? createdAt;

  TeacherAttendanceModel({
    this.id,
    required this.teacherProfileId,
    this.email,
    required this.attendanceDate,
    required this.checkIn,
    this.checkOut,
    this.createdAt,
  });

  Map<String, dynamic> toInsertJson() {
    return {'teacher_profile_id': teacherProfileId};
  }

  Map<String, dynamic> toUpdateCheckoutJson(DateTime serverUtcTime) {
    final mmTime = serverUtcTime.toUtc().add(
      const Duration(hours: 6, minutes: 30),
    );

    return {'check_out': mmTime.toIso8601String()};
  }

  TeacherAttendanceModel copyWith({
    String? id,
    String? teacherProfileId,
    String? email,
    DateTime? attendanceDate,
    DateTime? checkIn,
    DateTime? checkOut,
    DateTime? createdAt,
  }) {
    return TeacherAttendanceModel(
      id: id ?? this.id,
      teacherProfileId: teacherProfileId ?? this.teacherProfileId,
      email: email ?? this.email,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TeacherAttendanceModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();

      String dateStr = value.toString();
      if (dateStr.contains('T')) {
        dateStr = dateStr.split('+').first.replaceAll('Z', '');
      }

      return DateTime.tryParse(dateStr) ?? DateTime.now();
    }

    String? extractedEmail;
    if (json['profiles'] != null && json['profiles'] is Map) {
      extractedEmail = json['profiles']['email']?.toString();
    }

    return TeacherAttendanceModel(
      id: json['id']?.toString(),
      teacherProfileId: json['teacher_profile_id'].toString(),
      email: extractedEmail,
      attendanceDate: parseDate(json['attendance_date']),
      checkIn: parseDate(json['check_in']),
      checkOut: json['check_out'] != null ? parseDate(json['check_out']) : null,
      createdAt: json['created_at'] != null
          ? parseDate(json['created_at'])
          : null,
    );
  }
}
