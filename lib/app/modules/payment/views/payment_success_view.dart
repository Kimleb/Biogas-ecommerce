import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../utils/constants.dart';
import '../../../components/dark_transition.dart';
import '../../../routes/app_pages.dart';

// Extension for spacing
extension HorizontalSpace on double {
  SizedBox get horizontalSpace => SizedBox(width: this);
}

extension VerticalSpace on double {
  SizedBox get verticalSpace => SizedBox(height: this);
}

class PaymentSuccessView extends StatelessWidget {
  final String paymentId;
  final double amount;
  final String serviceName;

  PaymentSuccessView({
    Key? key,
  })  : paymentId = _getPaymentId(),
        amount = _getAmount(),
        serviceName = _getServiceName(),
        super(key: key);

  static String _getPaymentId() {
    final args = Get.arguments as Map<String, dynamic>?;
    return args?['paymentId'] ?? 'Unknown';
  }

  static double _getAmount() {
    final args = Get.arguments as Map<String, dynamic>?;
    return args?['amount']?.toDouble() ?? 0.0;
  }

  static String _getServiceName() {
    final args = Get.arguments as Map<String, dynamic>?;
    return args?['serviceName'] ?? 'Unknown Service';
  }

  @override
  Widget build(BuildContext context) {
    return DarkTransition(
      offset: Offset(0, -context.height),
      isDark: false,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Success Header
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4CAF50),
                        Color(0xFF45A049),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success Icon
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 60.sp,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      24.verticalSpace,
                      Text(
                        'Payment Successful!',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      8.verticalSpace,
                      Text(
                        'Your payment has been processed',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Payment Details
              Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Service Info
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(Icons.receipt_long,
                                  size: 24.sp, color: Colors.white),
                            ),
                            16.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    serviceName,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  4.verticalSpace,
                                  Text(
                                    'Payment ID: $paymentId',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      16.verticalSpace,

                      // Amount Details
                      Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      12.verticalSpace,
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Amount Paid',
                                'KES ${amount.toStringAsFixed(2)}'),
                            12.verticalSpace,
                            _buildDetailRow('Payment Method', 'M-Pesa'),
                            12.verticalSpace,
                            _buildDetailRow('Status', 'Completed'),
                            12.verticalSpace,
                            Divider(height: 1.h, color: Colors.grey[300]),
                            12.verticalSpace,
                            _buildDetailRow(
                              'Date & Time',
                              DateTime.now().toString().substring(0, 19),
                            ),
                          ],
                        ),
                      ),
                      16.verticalSpace,

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.offAllNamed(Routes.HOME),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Color(0xFF4CAF50)),
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
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                          ),
                          12.horizontalSpace,
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to booking details or receipt
                                Get.snackbar(
                                  'Receipt',
                                  'Receipt download feature coming soon!',
                                  backgroundColor: Color(0xFF4CAF50),
                                  colorText: Colors.white,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4CAF50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                              ),
                              child: Text(
                                'View Receipt',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
