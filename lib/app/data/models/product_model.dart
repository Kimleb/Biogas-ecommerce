class ProductModel {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final List<String> thumbnailImages;
  final double price;
  final int quantity;
  final String? categoryId;
  final String? category;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    this.images = const [],
    this.thumbnailImages = const [],
    required this.price,
    required this.quantity,
    this.categoryId,
    this.category,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      thumbnailImages: List<String>.from(json['thumbnailImages'] ?? []),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      categoryId: json['categoryId'],
      category: json['category'],
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
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
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? images,
    List<String>? thumbnailImages,
    double? price,
    int? quantity,
    String? categoryId,
    String? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      images: images ?? this.images,
      thumbnailImages: thumbnailImages ?? this.thumbnailImages,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
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
}
