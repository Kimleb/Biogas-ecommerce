class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer', 'technician', 'admin'
  final String? profileImage;
  final String? thumbnailImage;
  final String? address;
  final double? rating;
  final int? completedJobs;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.thumbnailImage,
    this.address,
    this.rating,
    this.completedJobs,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'customer',
      profileImage: json['profileImage'],
      thumbnailImage: json['thumbnailImage'],
      address: json['address'],
      rating: json['rating']?.toDouble(),
      completedJobs: json['completedJobs'],
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
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'thumbnailImage': thumbnailImage,
      'address': address,
      'rating': rating,
      'completedJobs': completedJobs,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profileImage,
    String? thumbnailImage,
    String? address,
    double? rating,
    int? completedJobs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      thumbnailImage: thumbnailImage ?? this.thumbnailImage,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
