class Profile {
  const Profile({
    required this.id,
    required this.email,
    required this.role,
    this.password = '',
    this.displayName = '',
    this.createdAt = '',
  });

  final String id;
  final String email;
  final String role; // '1' = Admin (A), '2' = Teacher (T), '3' = Parent (P)
  final String password;
  final String displayName;
  final String createdAt;

  String get roleInitial {
    switch (role) {
      case '1':
        return 'A';
      case '2':
        return 'T';
      case '3':
        return 'P';
      default:
        return '?';
    }
  }

  String get roleLabel {
    switch (role) {
      case '1':
        return 'Admin';
      case '2':
        return 'Teacher';
      case '3':
        return 'Parent';
      default:
        return 'Unknown';
    }
  }

  factory Profile.fromMap(Map<String, dynamic> data) {
    String firstNonEmptyString(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value == null) continue;
        final str = value.toString().trim();
        if (str.isNotEmpty) return str;
      }
      return '';
    }

    return Profile(
      id: firstNonEmptyString(['id', 'user_id', 'userId']),
      email: firstNonEmptyString(['email', 'user_email', 'userEmail']),
      role: firstNonEmptyString(['role', 'user_role', 'userRole']),
      displayName: firstNonEmptyString(['display_name', 'displayName', 'name']),
      createdAt: firstNonEmptyString(['created_at', 'createdAt']),
    );
  }
}
