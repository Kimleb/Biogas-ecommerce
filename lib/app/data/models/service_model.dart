class ServiceModel {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final List<String> thumbnailImages;
  final String duration;
  final double price;
  final String? technicianId;
  final String? technicianName;
  final double rating;
  final String? categoryId;
  final String? category;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    this.images = const [],
    this.thumbnailImages = const [],
    required this.duration,
    required this.price,
    this.technicianId,
    this.technicianName,
    this.rating = 0.0,
    this.categoryId,
    this.category,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Helper function to parse date from either timestamp or string
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is num) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      }
      if (value is String) {
        try {
          // Try parsing as ISO string first
          return DateTime.parse(value);
        } catch (e) {
          try {
            // Try parsing as timestamp string
            final timestamp = int.parse(value);
            return DateTime.fromMillisecondsSinceEpoch(timestamp);
          } catch (e2) {
            return null;
          }
        }
      }
      return null;
    }

    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      thumbnailImages: (json['thumbnailImages'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      duration: json['duration']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      technicianId: json['technicianId']?.toString(),
      technicianName: json['technicianName']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['categoryId']?.toString(),
      category: json['category']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'images': images,
      'thumbnailImages': thumbnailImages,
      'duration': duration,
      'price': price,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'rating': rating,
      'categoryId': categoryId,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? images,
    List<String>? thumbnailImages,
    String? duration,
    double? price,
    String? technicianId,
    String? technicianName,
    double? rating,
    String? categoryId,
    String? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      images: images ?? this.images,
      thumbnailImages: thumbnailImages ?? this.thumbnailImages,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      rating: rating ?? this.rating,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get the primary image (first image in the list)
  String? get primaryImage => images.isNotEmpty ? images.first : null;

  // Get the primary thumbnail
  String? get primaryThumbnail =>
      thumbnailImages.isNotEmpty ? thumbnailImages.first : null;

  // Get technician name (for backward compatibility)
  String? get technician => technicianName;
}
