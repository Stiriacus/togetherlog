// TogetherLog - Tag Data Model
// Represents a predefined tag category for entries

/// Tag data model
/// Tags are predefined categories stored in the database
/// 19 seed tags across Activity, Event, and Emotion categories
class Tag {
  const Tag({
    required this.id,
    required this.name,
    required this.category,
    this.icon,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String?,
    );
  }

  final String id;
  final String name;
  final String category; // 'Activity', 'Event', 'Emotion'
  final String? icon; // Optional icon identifier

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      if (icon != null) 'icon': icon,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
