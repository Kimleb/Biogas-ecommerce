import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/models/booking_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/database_service.dart';
import '../controllers/booking_history_controller.dart';

class BookingHistoryView extends GetView<BookingHistoryController> {
  const BookingHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Booking History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8C00)));
        }

        if (controller.bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64.w, color: Colors.grey.shade400),
                16.verticalSpace,
                Text(
                  'No bookings yet',
                  style:
                      TextStyle(fontSize: 18.sp, color: Colors.grey.shade600),
                ),
                8.verticalSpace,
                Text(
                  'Your past and upcoming bookings will appear here',
                  style:
                      TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshBookings,
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.bookings.length,
            separatorBuilder: (_, __) => 16.verticalSpace,
            itemBuilder: (context, index) {
              final booking = controller.bookings[index];
              return _BookingCard(booking: booking);
            },
          ),
        );
      }),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final statusColor = _statusColor(booking.status);
    final statusText = _statusText(booking.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Service name + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.serviceName ?? 'Service',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            12.verticalSpace,

            // Date & time
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16.w, color: Colors.grey.shade600),
                8.horizontalSpace,
                Text(
                  _formatDate(booking.serviceDate),
                  style:
                      TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                ),
              ],
            ),
            8.verticalSpace,

            // Price
            Row(
              children: [
                Icon(Icons.attach_money,
                    size: 16.w, color: Colors.grey.shade600),
                8.horizontalSpace,
                Text(
                  'KES ${booking.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF8C00),
                  ),
                ),
              ],
            ),
            if (booking.technicianName != null) ...[
              8.verticalSpace,
              Row(
                children: [
                  Icon(Icons.person, size: 16.w, color: Colors.grey.shade600),
                  8.horizontalSpace,
                  Text(
                    booking.technicianName!,
                    style:
                        TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              8.verticalSpace,
              Row(
                children: [
                  Icon(Icons.note, size: 16.w, color: Colors.grey.shade600),
                  8.horizontalSpace,
                  Expanded(
                    child: Text(
                      booking.notes!,
                      style: TextStyle(
                          fontSize: 14.sp, color: Colors.grey.shade700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} '
        '${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')} '
        '${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
