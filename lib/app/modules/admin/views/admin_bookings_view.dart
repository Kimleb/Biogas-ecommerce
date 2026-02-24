import 'package:biogas_technician_app/app/data/models/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/admin_controller.dart';

class AdminBookingsView extends GetView<AdminController> {
  const AdminBookingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Bookings Management',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2E3192),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (controller.bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today,
                    size: 64.sp, color: Colors.grey[300]),
                16.verticalSpace,
                Text(
                  'No bookings yet',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
                8.verticalSpace,
                Text(
                  'Bookings will appear here',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.bookings.length,
          itemBuilder: (context, index) {
            final booking = controller.bookings[index];
            return Card(
              margin: EdgeInsets.only(bottom: 12.h),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            booking.serviceName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking.status)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            booking.status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(booking.status),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    12.verticalSpace,

                    // Customer Info
                    Row(
                      children: [
                        Icon(Icons.person, size: 16.w, color: Colors.grey[600]),
                        8.horizontalSpace,
                        Text(
                          booking.customerName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    8.verticalSpace,

                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16.w, color: Colors.grey[600]),
                        8.horizontalSpace,
                        Expanded(
                          child: Text(
                            booking.address,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),

                    12.verticalSpace,

                    // Date and Time
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 16.w, color: Colors.grey[600]),
                        8.horizontalSpace,
                        Text(
                          '${booking.serviceDate.day}/${booking.serviceDate.month}/${booking.serviceDate.year}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        16.horizontalSpace,
                        Icon(Icons.access_time,
                            size: 16.w, color: Colors.grey[600]),
                        8.horizontalSpace,
                        Text(
                          '${booking.serviceDate.hour.toString().padLeft(2, '0')}:${booking.serviceDate.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    if (booking.selectedParts.isNotEmpty) ...[
                      12.verticalSpace,
                      Row(
                        children: [
                          Icon(Icons.build,
                              size: 16.w, color: Colors.grey[600]),
                          8.horizontalSpace,
                          Expanded(
                            child: Text(
                              '${booking.selectedParts.length} parts selected',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Actions
                    16.verticalSpace,
                    Row(
                      children: [
                        if (booking.status.toLowerCase() == 'pending') ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => controller.updateBookingStatus(
                                  booking.id as BookingModel, 'confirmed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: Size(double.infinity, 36.h),
                              ),
                              child: Text('Confirm',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          8.horizontalSpace,
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => controller.updateBookingStatus(
                                  booking.id as BookingModel, 'cancelled'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red),
                                minimumSize: Size(double.infinity, 36.h),
                              ),
                              child: Text('Cancel',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ] else if (booking.status.toLowerCase() ==
                            'confirmed') ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => controller.updateBookingStatus(
                                  booking.id as BookingModel, 'completed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF8C00),
                                minimumSize: Size(double.infinity, 36.h),
                              ),
                              child: Text('Mark Complete',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          8.horizontalSpace,
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => controller.updateBookingStatus(
                                  booking.id as BookingModel, 'cancelled'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red),
                                minimumSize: Size(double.infinity, 36.h),
                              ),
                              child: Text('Cancel',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Booking ${booking.status}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Color(0xFF2E3192);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
