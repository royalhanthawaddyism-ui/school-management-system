class Student {
  const Student({
    required this.studentId,
    required this.name,
    required this.parentName,
    required this.year,
    required this.photoUrl,
    this.dob = '',
    this.address = '',
    this.gender = '',
  });

  final String studentId;
  final String name;
  final String parentName;
  final String year;
  final String photoUrl;
  final String dob;
  final String address;
  final String gender;

  String get id => studentId;

  factory Student.fromMap(Map<String, dynamic> data) {
    String firstNonEmptyString(Map<String, dynamic> data, List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
        if (value is Map) {
          for (final nestedKey in ['name', 'title', 'year', 'class', 'grade']) {
            final nested = value[nestedKey];
            if (nested is String && nested.trim().isNotEmpty) {
              return nested.trim();
            }
            if (nested != null) return nested.toString().trim();
          }
        }
        if (value is List && value.isNotEmpty) {
          final first = value.first;
          if (first is String && first.trim().isNotEmpty) return first.trim();
          if (first is Map) {
            for (final nestedKey in [
              'name',
              'title',
              'year',
              'class',
              'grade',
            ]) {
              final nested = first[nestedKey];
              if (nested is String && nested.trim().isNotEmpty) {
                return nested.trim();
              }
              if (nested != null) return nested.toString().trim();
            }
          }
        }
        if (value != null) return value.toString().trim();
      }
      return '';
    }

    final studentId = firstNonEmptyString(data, [
      'student_id',
      'studentId',
      'id',
    ]);
    final name = firstNonEmptyString(data, [
      'name',
      'student_name',
      'studentName',
    ]);
    final parentName = firstNonEmptyString(data, [
      'parent_name',
      'parentName',
      'guardian_name',
      'guardianName',
      'father_name',
      'mother_name',
    ]);

    var year = firstNonEmptyString(data, [
      'year',
      'class_year',
      'classYear',
      'grade_year',
      'gradeYear',
      'class',
      'class_name',
      'className',
      'standard',
      'grade',
      'form',
      'level',
      'student_class',
    ]);

    if (year.isEmpty) {
      final nested = data['years'] ?? data['year'];
      if (nested is List && nested.isNotEmpty) {
        final first = nested.first;
        if (first is Map<String, dynamic>) {
          year = firstNonEmptyString(first, ['name', 'year', 'title', 'class']);
        } else if (first is String) {
          year = first.trim();
        }
      } else if (nested is Map<String, dynamic>) {
        year = firstNonEmptyString(nested, ['name', 'year', 'title', 'class']);
      }
    }

    final photoUrl = firstNonEmptyString(data, [
      'photo_url',
      'photoUrl',
      'image_url',
      'imageUrl',
      'avatar_url',
      'avatarUrl',
      'profile_photo',
      'photo',
    ]);

    final dob = firstNonEmptyString(data, [
      'dob',
      'date_of_birth',
      'dateOfBirth',
      'birth_date',
      'birthDate',
      'birthday',
      'date_of_birth_text',
    ]);

    final address = firstNonEmptyString(data, [
      'address',
      'home_address',
      'homeAddress',
      'address_line',
      'addressLine',
      'permanent_address',
      'current_address',
    ]);

    final gender = firstNonEmptyString(data, [
      'gender',
      'sex',
      'gender_label',
      'genderName',
    ]);

    return Student(
      studentId: studentId,
      name: name,
      parentName: parentName,
      year: year,
      photoUrl: photoUrl,
      dob: dob,
      address: address,
      gender: gender,
    );
  }

  bool matchesSearch(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    final searchFields = [
      studentId,
      name,
      parentName,
      year,
    ].map((value) => value.toLowerCase());

    return searchFields.any((value) => value.contains(normalizedQuery));
  }
}
