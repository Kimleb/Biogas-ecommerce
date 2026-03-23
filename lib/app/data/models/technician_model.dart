/// Technician Model for managing service providers
class TechnicianModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? specialization;
  final String? location;
  final double rating;
  final int completedJobs;
  final bool isAvailable;
  final String? profileImage;
  final List<String> skills;
  final DateTime createdAt;
  final DateTime? lastActive;

  TechnicianModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.specialization,
    this.location,
    this.rating = 0.0,
    this.completedJobs = 0,
    this.isAvailable = true,
    this.profileImage,
    this.skills = const [],
    required this.createdAt,
    this.lastActive,
  });

  /// Create technician from JSON
  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      specialization: json['specialization'],
      location: json['location'],
      rating: (json['rating'] ?? 0).toDouble(),
      completedJobs: json['completed_jobs'] ?? 0,
      isAvailable: json['is_available'] ?? true,
      profileImage: json['profile_image'],
      skills: List<String>.from(json['skills'] ?? []),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      lastActive: json['last_active'] != null 
          ? DateTime.parse(json['last_active']) 
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'location': location,
      'rating': rating,
      'completed_jobs': completedJobs,
      'is_available': isAvailable,
      'profile_image': profileImage,
      'skills': skills,
      'created_at': createdAt.toIso8601String(),
      'last_active': lastActive?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TechnicianModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TechnicianModel(id: $id, name: $name, phone: $phone)';
  }
}
