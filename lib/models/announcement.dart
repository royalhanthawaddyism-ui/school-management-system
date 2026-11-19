// models/announcement_model.dart
class Announcement {
  final int id;
  final String title;
  final String body;
  final String targetType;
  final String? targetId;
  final DateTime? createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.targetType,
    this.targetId,
    this.createdAt,
  });

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'],
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      targetType: map['target_type'] ?? '',
      targetId: map['target_id'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}