/// Log data model
class Log {
  const Log({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.entryCount = 0,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      entryCount: json['entry_count'] as int? ?? 0,
    );
  }

  final String id;
  final String? userId;
  final String name;
  final String type; // e.g., 'Couple', 'Friends', 'Family'
  final DateTime createdAt;
  final DateTime updatedAt;
  final int entryCount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'entry_count': entryCount,
    };
  }
}
