/// Entry data model
/// Represents a memory entry with photos, tags, location, and Smart Page data
class Entry {
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
    this.pageLayoutType,
    this.colorTheme,
    this.sprinkles,
    this.isProcessed = false,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'] as String,
      logId: json['log_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      eventDate: DateTime.parse(json['event_date'] as String),
      highlightText: json['highlight_text'] as String? ?? '',
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => Photo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tagIds: (json['tag_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      pageLayoutType: json['page_layout_type'] as String?,
      colorTheme: json['color_theme'] as String?,
      sprinkles: (json['sprinkles'] as List<dynamic>?)?.cast<String>(),
      isProcessed: json['is_processed'] as bool? ?? false,
    );
  }

  final String id;
  final String logId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime eventDate;
  final String highlightText;
  final List<Photo> photos;
  final List<String> tagIds;
  final Location? location;
  final String? pageLayoutType; // Set by backend Smart Page engine
  final String? colorTheme; // Set by backend Smart Page engine
  final List<String>? sprinkles; // Set by backend Smart Page engine
  final bool isProcessed; // Backend processing complete flag

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'log_id': logId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'event_date': eventDate.toIso8601String(),
      'highlight_text': highlightText,
      'photos': photos.map((p) => p.toJson()).toList(),
      'tag_ids': tagIds,
      if (location != null) 'location': location!.toJson(),
      if (pageLayoutType != null) 'page_layout_type': pageLayoutType,
      if (colorTheme != null) 'color_theme': colorTheme,
      if (sprinkles != null) 'sprinkles': sprinkles,
      'is_processed': isProcessed,
    };
  }
}

class Photo {
  const Photo({
    required this.id,
    required this.entryId,
    required this.url,
    required this.thumbnailUrl,
    this.displayOrder,
    this.dominantColors,
    this.metadata,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      entryId: json['entry_id'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      displayOrder: json['display_order'] as int?,
      dominantColors: (json['dominant_colors'] as List<dynamic>?)?.cast<String>(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String entryId;
  final String url;
  final String thumbnailUrl;
  final int? displayOrder;
  final List<String>? dominantColors;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entry_id': entryId,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      if (displayOrder != null) 'display_order': displayOrder,
      if (dominantColors != null) 'dominant_colors': dominantColors,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class Location {
  const Location({
    this.lat,
    this.lng,
    required this.displayName,
    required this.isUserOverridden,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      displayName: json['display_name'] as String,
      isUserOverridden: json['is_user_overridden'] as bool,
    );
  }

  final double? lat;
  final double? lng;
  final String displayName;
  final bool isUserOverridden;

  Map<String, dynamic> toJson() {
    return {
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'display_name': displayName,
      'is_user_overridden': isUserOverridden,
    };
  }
}
