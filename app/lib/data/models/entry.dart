/// Entry data model - to be implemented in MILESTONE 10
class Entry {
  final String id;
  final String logId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime eventDate;
  final String highlightText;
  final List<Photo> photos;
  final List<String> tagIds;
  final Location? location;
  final String pageLayoutType;
  final String colorTheme;
  final List<String>? sprinkles;

  const Entry({
    required this.id,
    required this.logId,
    required this.createdAt,
    required this.updatedAt,
    required this.eventDate,
    required this.highlightText,
    required this.photos,
    required this.tagIds,
    this.location,
    required this.pageLayoutType,
    required this.colorTheme,
    this.sprinkles,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'] as String,
      logId: json['log_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      eventDate: DateTime.parse(json['event_date'] as String),
      highlightText: json['highlight_text'] as String,
      photos: (json['photos'] as List<dynamic>)
          .map((e) => Photo.fromJson(e as Map<String, dynamic>))
          .toList(),
      tagIds: (json['tag_ids'] as List<dynamic>).cast<String>(),
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      pageLayoutType: json['page_layout_type'] as String,
      colorTheme: json['color_theme'] as String,
      sprinkles: (json['sprinkles'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

class Photo {
  final String id;
  final String url;
  final String thumbnailUrl;
  final Map<String, dynamic>? metadata;

  const Photo({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    this.metadata,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class Location {
  final double? lat;
  final double? lng;
  final String displayName;
  final bool isUserOverridden;

  const Location({
    this.lat,
    this.lng,
    required this.displayName,
    required this.isUserOverridden,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'] as double?,
      lng: json['lng'] as double?,
      displayName: json['display_name'] as String,
      isUserOverridden: json['is_user_overridden'] as bool,
    );
  }
}
