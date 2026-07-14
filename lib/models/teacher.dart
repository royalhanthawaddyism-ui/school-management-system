class Teacher {
  final int? id;
  final String employeeId;
  final String name;
  final String? photoUrl;
  final String subject;
  final DateTime joiningDate;

  Teacher({
    this.id,
    required this.employeeId,
    required this.name,
    this.photoUrl,
    required this.subject,
    required this.joiningDate,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as int?,
      employeeId: json['employee_id'] as String,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
      subject: json['subject'] as String,
      joiningDate: DateTime.parse(json['joining_date'] as String),
    );
  }

  String get formattedJoiningDate {
    return "${joiningDate.day.toString().padLeft(2, '0')}-${joiningDate.month.toString().padLeft(2, '0')}-${joiningDate.year}";
  }

  String get initials {
    if (name.isEmpty) return '?';
    List<String> words = name.trim().split(' ');
    if (words.length > 1) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0][0].toUpperCase();
  }
}
