import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/receipt_model.dart';
import '../models/payment_model.dart';
import '../models/booking_model.dart';

class ReceiptService extends GetxService {
  static ReceiptService get to => Get.find();

  // Backend URL - same as MpesaService
  static const String _baseUrl =
      'https://eminently-rare-pegasus.ngrok-free.app/api';

  // Reactive state
  final RxBool isGeneratingReceipt = false.obs;
  final Rx<ReceiptModel?> currentReceipt = Rx<ReceiptModel?>(null);
  final RxString receiptStatus = ''.obs;

  /// Generate receipt from completed payment
  Future<ReceiptModel?> generateReceipt({
    required PaymentModel payment,
    required BookingModel booking,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    try {
      isGeneratingReceipt.value = true;
      receiptStatus.value = 'Generating receipt...';

      // Calculate fees
      double serviceFee = booking.totalPrice * 0.8; // 80% service fee
      double platformFee = booking.totalPrice * 0.2; // 20% platform fee

      // Create receipt locally first
      final receipt = ReceiptModel.fromPaymentData(
        paymentId: payment.id,
        bookingId: booking.id,
        customerId: booking.customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        serviceName: booking.serviceName,
        amount: payment.amount,
        serviceFee: serviceFee,
        platformFee: platformFee,
        paymentMethod: payment.paymentMethod?.name ?? 'M-Pesa',
        status: payment.status.name,
        createdAt: payment.createdAt,
        transactionId: payment.verificationData?['transaction_id'],
        merchantRequestId: payment.verificationData?['merchant_request_id'],
        checkoutRequestId: payment.verificationData?['checkout_request_id'],
        verificationData: payment.verificationData,
      );

      // Try to save receipt to backend
      final savedReceipt = await _saveReceiptToBackend(receipt);

      currentReceipt.value = savedReceipt ?? receipt;
      receiptStatus.value = 'Receipt generated successfully';

      return currentReceipt.value;
    } catch (e) {
      receiptStatus.value = 'Receipt generation failed: ${e.toString()}';
      print('Receipt generation error: $e');
      return null;
    } finally {
      isGeneratingReceipt.value = false;
    }
  }

  /// Save receipt to backend
  Future<ReceiptModel?> _saveReceiptToBackend(ReceiptModel receipt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/receipts/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(receipt.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ReceiptModel.fromJson(data);
      } else {
        print('Failed to save receipt to backend: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error saving receipt to backend: $e');
      return null;
    }
  }

  /// Get receipt by ID from backend
  Future<ReceiptModel?> getReceiptById(String receiptId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/receipts/$receiptId/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ReceiptModel.fromJson(data);
      } else {
        print('Receipt not found: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching receipt: $e');
      return null;
    }
  }

  /// Get receipts by customer ID
  Future<List<ReceiptModel>> getReceiptsByCustomerId(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/receipts/customer/$customerId/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => ReceiptModel.fromJson(item)).toList();
      } else {
        print('Failed to fetch customer receipts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching customer receipts: $e');
      return [];
    }
  }

  /// Generate PDF receipt (placeholder for future implementation)
  Future<File?> generatePdfReceipt(ReceiptModel receipt) async {
    try {
      // This is a placeholder for PDF generation
      // In a real implementation, you would use a PDF library like pdf or printing

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'receipt_${receipt.id}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');

      // Create a simple text receipt for now
      final receiptContent = _generateTextReceipt(receipt);
      await file.writeAsString(receiptContent);

      return file;
    } catch (e) {
      print('Error generating PDF receipt: $e');
      return null;
    }
  }

  /// Generate text receipt content
  String _generateTextReceipt(ReceiptModel receipt) {
    return '''
========================================
           PAYMENT RECEIPT
========================================

RECEIPT ID: ${receipt.id}
PAYMENT ID: ${receipt.paymentId}
BOOKING ID: ${receipt.bookingId}

----------------------------------------
CUSTOMER INFORMATION
----------------------------------------
Name: ${receipt.customerName}
Email: ${receipt.customerEmail}
Phone: ${receipt.customerPhone}

----------------------------------------
SERVICE DETAILS
----------------------------------------
Service: ${receipt.serviceName}
Date: ${receipt.formattedDateTime}

----------------------------------------
PAYMENT DETAILS
----------------------------------------
Service Fee: ${receipt.formattedServiceFee}
Platform Fee: ${receipt.formattedPlatformFee}
Total Amount: ${receipt.formattedAmount}
Payment Method: ${receipt.paymentMethod}
Status: ${receipt.status.toUpperCase()}

----------------------------------------
TRANSACTION DETAILS
----------------------------------------
${receipt.transactionId != null ? 'Transaction ID: ${receipt.transactionId}' : ''}
${receipt.checkoutRequestId != null ? 'Checkout Request ID: ${receipt.checkoutRequestId}' : ''}
${receipt.merchantRequestId != null ? 'Merchant Request ID: ${receipt.merchantRequestId}' : ''}

========================================
        Thank you for your payment!
========================================
    ''';
  }

  /// Share receipt (placeholder - requires share_plus package)
  Future<void> shareReceipt(ReceiptModel receipt) async {
    try {
      final file = await generatePdfReceipt(receipt);
      if (file != null) {
        // TODO: Implement sharing when share_plus package is added
        Get.snackbar(
          'Info',
          'Share functionality will be available when share_plus package is added',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        // Fallback to copying to clipboard or showing content
        final receiptContent = _generateTextReceipt(receipt);
        print('Receipt content: $receiptContent');
        Get.snackbar(
          'Info',
          'Receipt content logged to console',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error sharing receipt: $e');
      Get.snackbar(
        'Error',
        'Failed to share receipt',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Download receipt
  Future<void> downloadReceipt(ReceiptModel receipt) async {
    try {
      final file = await generatePdfReceipt(receipt);
      if (file != null) {
        Get.snackbar(
          'Success',
          'Receipt downloaded to ${file.path}',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to download receipt',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error downloading receipt: $e');
      Get.snackbar(
        'Error',
        'Failed to download receipt',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    }
  }

  /// Clear current receipt
  void clearCurrentReceipt() {
    currentReceipt.value = null;
    receiptStatus.value = '';
  }

  /// Get receipt summary for display
  Map<String, dynamic> getReceiptSummary(ReceiptModel receipt) {
    return {
      'id': receipt.id,
      'serviceName': receipt.serviceName,
      'amount': receipt.formattedAmount,
      'date': receipt.formattedDate,
      'time': receipt.formattedTime,
      'status': receipt.status,
      'paymentMethod': receipt.paymentMethod,
    };
  }
}
