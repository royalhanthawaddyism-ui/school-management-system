class Teacher {
  final int? id;
  final String employeeId;
  final String name;
  final String? photoUrl;
  final String subject;
  final DateTime dob;
  final String gender;
  final String? phone;
  final String? address;
  final DateTime joiningDate;

  Teacher({
    this.id,
    required this.employeeId,
    required this.name,
    this.photoUrl,
    required this.subject,
    required this.dob,
    required this.gender,
    this.phone,
    this.address,
    required this.joiningDate,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as int?,
      employeeId: json['employee_id'] as String,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
      subject: json['subject'] as String,
      dob: json['dob'] != null
          ? DateTime.parse(json['dob'] as String)
          : DateTime.now(),
      gender: json['gender'] != null ? (json['gender'] as String) : 'Male',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      joiningDate: json['joining_date'] != null
          ? DateTime.parse(json['joining_date'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'name': name,
      'photo_url': photoUrl,
      'subject': subject,
      'dob': dob.toIso8601String(),
      'gender': gender,
      'phone': phone,
      'address': address,
      'joining_date': joiningDate.toIso8601String(),
    };
  }

  String get formattedDob {
    return "${dob.day.toString().padLeft(2, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.year}";
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
