class ReceiptModel {
  final String id;
  final String paymentId;
  final String bookingId;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String serviceName;
  final double amount;
  final double serviceFee;
  final double platformFee;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final String? transactionId;
  final String? merchantRequestId;
  final String? checkoutRequestId;
  final Map<String, dynamic>? verificationData;

  ReceiptModel({
    required this.id,
    required this.paymentId,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.serviceName,
    required this.amount,
    required this.serviceFee,
    required this.platformFee,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.transactionId,
    this.merchantRequestId,
    this.checkoutRequestId,
    this.verificationData,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      id: json['id'].toString(),
      paymentId: json['payment_id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      serviceName: json['service_name'] ?? '',
      amount: double.parse(json['amount'].toString()),
      serviceFee: double.parse(json['service_fee'].toString()),
      platformFee: double.parse(json['platform_fee'].toString()),
      paymentMethod: json['payment_method'] ?? 'M-Pesa',
      status: json['status'] ?? 'completed',
      createdAt: DateTime.parse(json['created_at']),
      transactionId: json['transaction_id'],
      merchantRequestId: json['merchant_request_id'],
      checkoutRequestId: json['checkout_request_id'],
      verificationData: json['verification_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_id': paymentId,
      'booking_id': bookingId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'service_name': serviceName,
      'amount': amount,
      'service_fee': serviceFee,
      'platform_fee': platformFee,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'transaction_id': transactionId,
      'merchant_request_id': merchantRequestId,
      'checkout_request_id': checkoutRequestId,
      'verification_data': verificationData,
    };
  }

  /// Get formatted amount with currency
  String get formattedAmount => 'KES ${amount.toStringAsFixed(2)}';

  /// Get formatted service fee
  String get formattedServiceFee => 'KES ${serviceFee.toStringAsFixed(2)}';

  /// Get formatted platform fee
  String get formattedPlatformFee => 'KES ${platformFee.toStringAsFixed(2)}';

  /// Get formatted date
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  /// Get formatted time
  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted date and time
  String get formattedDateTime {
    return '$formattedDate at $formattedTime';
  }

  /// Create receipt from payment data
  factory ReceiptModel.fromPaymentData({
    required String paymentId,
    required String bookingId,
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String serviceName,
    required double amount,
    required double serviceFee,
    required double platformFee,
    required String paymentMethod,
    required String status,
    required DateTime createdAt,
    String? transactionId,
    String? merchantRequestId,
    String? checkoutRequestId,
    Map<String, dynamic>? verificationData,
  }) {
    return ReceiptModel(
      id: 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      paymentId: paymentId,
      bookingId: bookingId,
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      serviceName: serviceName,
      amount: amount,
      serviceFee: serviceFee,
      platformFee: platformFee,
      paymentMethod: paymentMethod,
      status: status,
      createdAt: createdAt,
      transactionId: transactionId,
      merchantRequestId: merchantRequestId,
      checkoutRequestId: checkoutRequestId,
      verificationData: verificationData,
    );
  }

  @override
  String toString() {
    return 'ReceiptModel(id: $id, paymentId: $paymentId, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReceiptModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
