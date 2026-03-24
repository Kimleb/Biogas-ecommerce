import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/models/receipt_model.dart';
import '../../../data/services/receipt_service.dart';
import '../../../routes/app_pages.dart';

// Extension for spacing
extension HorizontalSpace on double {
  SizedBox get horizontalSpace => SizedBox(width: this);
}

extension VerticalSpace on double {
  SizedBox get verticalSpace => SizedBox(height: this);
}

class ReceiptView extends StatelessWidget {
  final ReceiptModel receipt;

  const ReceiptView({
    Key? key,
    required this.receipt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final receiptService = ReceiptService.to;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Payment Receipt',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Receipt Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4CAF50),
                        Color(0xFF45A049),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48.sp,
                        color: Colors.white,
                      ),
                      16.verticalSpace,
                      Text(
                        'PAYMENT RECEIPT',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      8.verticalSpace,
                      Text(
                        'Receipt ID: ${receipt.id}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                24.verticalSpace,

                // Customer Information
                _buildSectionCard(
                  title: 'Customer Information',
                  icon: Icons.person,
                  children: [
                    _buildInfoRow('Name', receipt.customerName),
                    _buildInfoRow('Email', receipt.customerEmail),
                    _buildInfoRow('Phone', receipt.customerPhone),
                  ],
                ),
                16.verticalSpace,

                // Service Details
                _buildSectionCard(
                  title: 'Service Details',
                  icon: Icons.miscellaneous_services,
                  children: [
                    _buildInfoRow('Service', receipt.serviceName),
                    _buildInfoRow('Booking ID', receipt.bookingId),
                    _buildInfoRow('Payment ID', receipt.paymentId),
                    _buildInfoRow('Date & Time', receipt.formattedDateTime),
                  ],
                ),
                16.verticalSpace,

                // Payment Details
                _buildSectionCard(
                  title: 'Payment Details',
                  icon: Icons.payment,
                  children: [
                    _buildInfoRow('Service Fee', receipt.formattedServiceFee),
                    _buildInfoRow('Platform Fee', receipt.formattedPlatformFee),
                    Divider(height: 24.h, color: Colors.grey[300]),
                    _buildInfoRow(
                      'Total Amount',
                      receipt.formattedAmount,
                      isTotal: true,
                    ),
                    _buildInfoRow('Payment Method', receipt.paymentMethod),
                    _buildInfoRow('Status', receipt.status.toUpperCase()),
                  ],
                ),

                // Transaction Details (if available)
                if (receipt.transactionId != null ||
                    receipt.checkoutRequestId != null ||
                    receipt.merchantRequestId != null) ...[
                  16.verticalSpace,
                  _buildSectionCard(
                    title: 'Transaction Details',
                    icon: Icons.receipt,
                    children: [
                      if (receipt.transactionId != null)
                        _buildInfoRow('Transaction ID', receipt.transactionId!),
                      if (receipt.checkoutRequestId != null)
                        _buildInfoRow(
                            'Checkout Request ID', receipt.checkoutRequestId!),
                      if (receipt.merchantRequestId != null)
                        _buildInfoRow(
                            'Merchant Request ID', receipt.merchantRequestId!),
                    ],
                  ),
                ],
                24.verticalSpace,

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => receiptService.downloadReceipt(receipt),
                        icon: Icon(Icons.download, size: 18.sp),
                        label: Text('Download'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFF4CAF50)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                      ),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => receiptService.shareReceipt(receipt),
                        icon: Icon(Icons.share, size: 18.sp),
                        label: Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                      ),
                    ),
                  ],
                ),
                16.verticalSpace,

                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(Routes.HOME),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ),
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: Color(0xFF4CAF50),
                ),
              ),
              12.horizontalSpace,
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          16.verticalSpace,
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16.sp : 14.sp,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                color: Colors.grey[600],
              ),
            ),
          ),
          8.horizontalSpace,
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: isTotal ? 16.sp : 14.sp,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? Color(0xFF4CAF50) : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
