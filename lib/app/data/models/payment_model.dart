/// Payment Model for tracking transactions
class PaymentModel {
  final String id;
  final String bookingId;
  final String userId;
  final String? technicianId;
  final double amount;
  final String currency;
  final PaymentType paymentType;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? description;
  final String? authorizationUrl;
  final String? accessCode;
  final String? reference;
  final Map<String, dynamic>? verificationData;
  final DateTime? refundedAt;
  final String? refundReason;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    this.technicianId,
    required this.amount,
    this.currency = 'KES',
    required this.paymentType,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.description,
    this.authorizationUrl,
    this.accessCode,
    this.reference,
    this.verificationData,
    this.refundedAt,
    this.refundReason,
  });

  /// Create payment from JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      userId: json['userId'] ?? '',
      technicianId: json['technicianId'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'NGN',
      paymentType: _parsePaymentType(json['paymentType']),
      status: _parsePaymentStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      description: json['description'],
      authorizationUrl: json['authorizationUrl'],
      accessCode: json['accessCode'],
      reference: json['reference'],
      verificationData: json['verificationData'],
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'])
          : null,
      refundReason: json['refundReason'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'technicianId': technicianId,
      'amount': amount,
      'currency': currency,
      'paymentType': paymentType.toString(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'description': description,
      'authorizationUrl': authorizationUrl,
      'accessCode': accessCode,
      'reference': reference,
      'verificationData': verificationData,
      'refundedAt': refundedAt?.toIso8601String(),
      'refundReason': refundReason,
    };
  }

  /// Parse payment type from string
  static PaymentType _parsePaymentType(String? type) {
    switch (type) {
      case 'PaymentType.payNow':
        return PaymentType.payNow;
      case 'PaymentType.payAfterService':
        return PaymentType.payAfterService;
      case 'PaymentType.partPurchase':
        return PaymentType.partPurchase;
      default:
        return PaymentType.payNow;
    }
  }

  /// Parse payment status from string
  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case 'PaymentStatus.pending':
        return PaymentStatus.pending;
      case 'PaymentStatus.processing':
        return PaymentStatus.processing;
      case 'PaymentStatus.completed':
        return PaymentStatus.completed;
      case 'PaymentStatus.failed':
        return PaymentStatus.failed;
      case 'PaymentStatus.refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  /// Create a copy with updated fields
  PaymentModel copyWith({
    String? id,
    String? bookingId,
    String? userId,
    String? technicianId,
    double? amount,
    String? currency,
    PaymentType? paymentType,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? paidAt,
    String? description,
    String? authorizationUrl,
    String? accessCode,
    String? reference,
    Map<String, dynamic>? verificationData,
    DateTime? refundedAt,
    String? refundReason,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      technicianId: technicianId ?? this.technicianId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      description: description ?? this.description,
      authorizationUrl: authorizationUrl ?? this.authorizationUrl,
      accessCode: accessCode ?? this.accessCode,
      reference: reference ?? this.reference,
      verificationData: verificationData ?? this.verificationData,
      refundedAt: refundedAt ?? this.refundedAt,
      refundReason: refundReason ?? this.refundReason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PaymentModel(id: $id, amount: $amount, status: $status, type: $paymentType)';
  }
}

/// Payment types
enum PaymentType {
  payNow,
  payAfterService,
  partPurchase,
}

/// Payment status
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

/// Payment method types
enum PaymentMethod {
  card,
  bankTransfer,
  ussd,
  paystackBank,
  qrCode,
  mpesa,
}
