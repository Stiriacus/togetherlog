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
    this.tags = const [],
    this.location,
    this.pageLayoutType,
    this.colorTheme,
    this.sprinkles,
    this.isProcessed = false,
    this.layoutVariant = 0,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    // Parse tags - backend can return either 'tag_ids' or 'tags' (full objects)
    List<String> tagIds = [];
    List<EntryTag> tags = [];

    if (json['tag_ids'] != null) {
      // Direct tag_ids array
      tagIds = (json['tag_ids'] as List<dynamic>).cast<String>();
    } else if (json['tags'] != null) {
      // Full tag objects from view
      final tagsList = json['tags'] as List<dynamic>;
      tags = tagsList.map((tag) => EntryTag.fromJson(tag as Map<String, dynamic>)).toList();
      tagIds = tags.map((tag) => tag.id).toList();
    }

    // Parse location - can be either flat fields or nested object
    Location? location;
    if (json['location'] != null) {
      // Nested object format (from toJson)
      location = Location.fromJson(json['location'] as Map<String, dynamic>);
    } else if (json['location_display_name'] != null) {
      // Flat fields format (from database view)
      location = Location(
        lat: (json['location_lat'] as num?)?.toDouble(),
        lng: (json['location_lng'] as num?)?.toDouble(),
        displayName: json['location_display_name'] as String,
        isUserOverridden: json['location_is_user_overridden'] as bool? ?? false,
      );
    }

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
      tagIds: tagIds,
      tags: tags,
      location: location,
      pageLayoutType: json['page_layout_type'] as String?,
      colorTheme: json['color_theme'] as String?,
      sprinkles: (json['sprinkles'] as List<dynamic>?)?.cast<String>(),
      isProcessed: json['is_processed'] as bool? ?? false,
      layoutVariant: json['layout_variant'] as int? ?? 0,
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
  final List<EntryTag> tags; // Full tag objects with names
  final Location? location;
  final String? pageLayoutType; // Set by backend Smart Page engine
  final String? colorTheme; // Set by backend Smart Page engine
  final List<String>? sprinkles; // Set by backend Smart Page engine
  final bool isProcessed; // Backend processing complete flag
  final int layoutVariant; // Used for visual variation seed (rotation, stagger)

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
      'layout_variant': layoutVariant,
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
      entryId: json['entry_id'] as String? ?? '', // Backend view might not include entry_id
      url: json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      displayOrder: json['display_order'] as int?,
      dominantColors: (json['dominant_colors'] as List<dynamic>?)?.cast<String>(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String entryId; // Can be empty if from view that doesn't include it
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

class EntryTag {
  const EntryTag({
    required this.id,
    required this.name,
    this.category,
    this.icon,
  });

  factory EntryTag.fromJson(Map<String, dynamic> json) {
    return EntryTag(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      icon: json['icon'] as String?,
    );
  }

  final String id;
  final String name;
  final String? category;
  final String? icon;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (category != null) 'category': category,
      if (icon != null) 'icon': icon,
    };
  }
}
