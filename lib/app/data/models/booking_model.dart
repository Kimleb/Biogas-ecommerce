import 'part_model.dart';

class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String serviceId;
  final String serviceName;
  final String? technicianId;
  final String? technicianName;
  final DateTime bookingDate;
  final DateTime serviceDate;
  final String
      status; // 'pending', 'confirmed', 'in_progress', 'completed', 'cancelled'
  final double totalPrice;
  final String address;
  final String? notes;
  final List<PartModel> selectedParts;
  final String? rating;
  final String? review;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.serviceId,
    required this.serviceName,
    this.technicianId,
    this.technicianName,
    required this.bookingDate,
    required this.serviceDate,
    required this.status,
    required this.totalPrice,
    required this.address,
    this.notes,
    this.selectedParts = const [],
    this.rating,
    this.review,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Helper function to parse date from either timestamp or string
    DateTime parseDate(dynamic value) {
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
            // Fallback to current time if parsing fails
            return DateTime.now();
          }
        }
      }
      return DateTime.now(); // Fallback
    }

    return BookingModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      technicianId: json['technicianId']?.toString(),
      technicianName: json['technicianName']?.toString(),
      bookingDate: parseDate(json['bookingDate']),
      serviceDate: parseDate(json['serviceDate']),
      status: json['status']?.toString() ?? 'pending',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      address: json['address']?.toString() ?? '',
      notes: json['notes']?.toString(),
      selectedParts: (json['selectedParts'] as List?)
              ?.map((e) => PartModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      rating: json['rating']?.toString(),
      review: json['review']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'bookingDate': bookingDate.toIso8601String(),
      'serviceDate': serviceDate.toIso8601String(),
      'status': status,
      'totalPrice': totalPrice,
      'address': address,
      'notes': notes,
      'selectedParts': selectedParts.map((e) => e.toJson()).toList(),
      'rating': rating,
      'review': review,
    };
  }
}
