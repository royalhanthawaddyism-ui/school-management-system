class Year {
  final String id;
  final String name;
  final int deleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Year({
    required this.id,
    required this.name,
    required this.deleted,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isDeleted => deleted == 1;

  factory Year.fromJson(Map<String, dynamic> json) {
    return Year(
      id: json['id'].toString(),
      name: json['name'] as String,
      deleted: json['deleted'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deleted': deleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
