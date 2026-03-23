import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../components/dark_transition.dart';
import '../controllers/payment_controller.dart';

// Extension for spacing
extension HorizontalSpace on double {
  SizedBox get horizontalSpace => SizedBox(width: this);
}

extension VerticalSpace on double {
  SizedBox get verticalSpace => SizedBox(height: this);
}

class PaymentView extends GetView<PaymentController> {
  const PaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DarkTransition(
      offset: Offset(0, context.height),
      isDark: !controller.isLightTheme.value,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(context),
        body: Obx(() => controller.isLoading.value
            ? _buildLoadingState()
            : _buildPaymentContent()),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.arrow_back, size: 20.sp, color: Colors.black87),
        ),
      ),
      title: Text(
        'Payment',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16.w),
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Color(0xFFFF8C00).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.security, size: 20.sp, color: Color(0xFFFF8C00)),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: Color(0xFFFF8C00),
              strokeWidth: 3,
            ),
          ),
          24.verticalSpace,
          Text(
            controller.loadingMessage.value,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Summary Card
          _buildPaymentSummary(),
          24.verticalSpace,

          // M-Pesa Form (always shown)
          _buildMpesaForm(),
          24.verticalSpace,

          // Payment Button
          _buildPayButton(),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.receipt_long,
                    size: 24.sp, color: Color(0xFF4A90E2)),
              ),
              16.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      controller.booking?.serviceName ?? 'Service Booking',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          20.verticalSpace,
          _buildSummaryRow('Service Fee', controller.serviceFee),
          12.verticalSpace,
          _buildSummaryRow('Platform Fee', controller.platformFee),
          12.verticalSpace,
          Divider(height: 1.h, color: Colors.grey[200]),
          12.verticalSpace,
          _buildSummaryRow(
            'Total Amount',
            controller.totalAmount,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          'KES ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? Color(0xFFFF8C00) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMpesaForm() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_android, size: 20.sp, color: Color(0xFF4A90E2)),
              8.horizontalSpace,
              Text(
                'M-Pesa Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          16.verticalSpace,
          Text(
            'Enter your M-Pesa phone number',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          8.verticalSpace,
          TextField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+254 712 345 678',
              prefixIcon: Container(
                padding: EdgeInsets.all(12.w),
                child: Text(
                  '📱',
                  style: TextStyle(fontSize: 20.sp),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Color(0xFFFF8C00)),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          12.verticalSpace,
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16.sp, color: Color(0xFF4A90E2)),
                8.horizontalSpace,
                Expanded(
                  child: Text(
                    'You will receive an M-Pesa STK Push prompt on this number to complete the payment',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          12.verticalSpace,
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFF28A745).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.security, size: 16.sp, color: Color(0xFF28A745)),
                8.horizontalSpace,
                Expanded(
                  child: Text(
                    'Payment is processed securely through Safaricom Daraja API',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Color(0xFF28A745),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: controller.isProcessing.value
            ? null
            : () => controller.processPayment(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF8C00),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: Obx(() => controller.isProcessing.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  12.horizontalSpace,
                  Text(
                    controller.loadingMessage.value.isNotEmpty
                        ? controller.loadingMessage.value
                        : 'Processing M-Pesa payment...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_android, size: 20.sp),
                  8.horizontalSpace,
                  Text(
                    'Pay KES ${controller.totalAmount.toStringAsFixed(2)} with M-Pesa',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )),
      ),
    );
  }
}
