class PartModel {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final List<String> thumbnailImages;
  final double price;
  final int quantity;
  final String? categoryId;
  final String? category;
  final String? brand;
  final String? model;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PartModel({
    required this.id,
    required this.name,
    required this.description,
    this.images = const [],
    this.thumbnailImages = const [],
    required this.price,
    required this.quantity,
    this.categoryId,
    this.category,
    this.brand,
    this.model,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory PartModel.fromJson(Map<String, dynamic> json) {
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

    return PartModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      thumbnailImages: (json['thumbnailImages'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      categoryId: json['categoryId']?.toString(),
      category: json['category']?.toString(),
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
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
      'price': price,
      'quantity': quantity,
      'categoryId': categoryId,
      'category': category,
      'brand': brand,
      'model': model,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  PartModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? images,
    List<String>? thumbnailImages,
    double? price,
    int? quantity,
    String? categoryId,
    String? category,
    String? brand,
    String? model,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      images: images ?? this.images,
      thumbnailImages: thumbnailImages ?? this.thumbnailImages,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
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
}
