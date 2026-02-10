import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminDashboardView extends GetView<AdminController> {
  const AdminDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Modern Header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8C00), Color(0xFFFF6B00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.r),
                bottomRight: Radius.circular(30.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        4.verticalSpace,
                        Text(
                          'Manage your biogas services',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.dashboard,
                          color: Colors.white, size: 24.sp),
                    ),
                  ],
                ),
                20.verticalSpace,
                // Summary Cards
                _buildSummaryCards(),
              ],
            ),
          ),

          // Quick Actions Section
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                16.verticalSpace,
                _buildQuickActionButtons(),
              ],
            ),
          ),

          // Tab Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _buildModernTabBar(),
          ),

          16.verticalSpace,

          // Content Section
          Expanded(
            child: Container(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFF8C00)));
                }

                switch (controller.selectedTab.value) {
                  case 0:
                    return _buildServicesTab();
                  case 1:
                    return _buildBookingsTab();
                  case 2:
                    return _buildPartsTab();
                  default:
                    return _buildServicesTab();
                }
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.selectedTab.value == 0) {
          return FloatingActionButton.extended(
            onPressed: () => controller.showAddServiceDialog(),
            backgroundColor: Color(0xFFFF8C00),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text('Add Service', style: TextStyle(color: Colors.white)),
          );
        }
        return SizedBox.shrink();
      }),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Services',
            '${controller.services.length}',
            Icons.eco_rounded,
            Color(0xFF4CAF50),
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: _buildSummaryCard(
            'Total Bookings',
            '${controller.bookings.length}',
            Icons.calendar_today,
            Color(0xFF2196F3),
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: _buildSummaryCard(
            'Total Parts',
            '${controller.parts.length}',
            Icons.build,
            Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          8.verticalSpace,
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          4.verticalSpace,
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                'Add Service',
                Icons.add_circle_outline,
                Color(0xFF4CAF50),
                () => controller.showAddServiceDialog(),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: _buildQuickActionButton(
                'View Analytics',
                Icons.analytics_outlined,
                Color(0xFF2196F3),
                () => _showAnalyticsDialog(),
              ),
            ),
          ],
        ),
        12.verticalSpace,
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                'Export Data',
                Icons.download_outlined,
                Color(0xFFFF9800),
                () => _exportData(),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: _buildQuickActionButton(
                'Settings',
                Icons.settings_outlined,
                Color(0xFF9C27B0),
                () => _showSettingsDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            8.verticalSpace,
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Row(
            children: [
              _buildModernTab('Services', 0, Icons.eco_rounded),
              _buildModernTab('Bookings', 1, Icons.calendar_today),
              _buildModernTab('Parts', 2, Icons.build),
            ],
          )),
    );
  }

  Widget _buildModernTab(String title, int index, IconData icon) {
    final isSelected = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected
                ? Color(0xFFFF8C00).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Color(0xFFFF8C00) : Colors.grey,
                size: 20.sp,
              ),
              4.verticalSpace,
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Color(0xFFFF8C00) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
    return Obx(() {
      if (controller.services.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco_rounded, size: 64.sp, color: Colors.grey[300]),
              16.verticalSpace,
              Text(
                'No services yet',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
              8.verticalSpace,
              Text(
                'Tap + to add a service',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.services.length,
        itemBuilder: (context, index) {
          final service = controller.services[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(12.w),
              leading: Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F9E8),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.eco_rounded, color: Color(0xFFFF8C00)),
              ),
              title: Text(
                service.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  4.verticalSpace,
                  Text(
                    '\$${service.price.toStringAsFixed(2)} • ${service.duration}',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  4.verticalSpace,
                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('Edit'),
                    value: 'edit',
                  ),
                  PopupMenuItem(
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                    value: 'delete',
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    controller.deleteService(service.id.toString());
                  }
                },
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildBookingsTab() {
    return Obx(() {
      if (controller.bookings.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64.sp, color: Colors.grey[300]),
              16.verticalSpace,
              Text(
                'No bookings yet',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.serviceName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: controller
                              .getStatusColor(booking.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          booking.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: controller.getStatusColor(booking.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  8.verticalSpace,
                  Text(
                    'Customer: ${booking.customerName}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                  ),
                  4.verticalSpace,
                  Text(
                    'Date: ${booking.serviceDate.day}/${booking.serviceDate.month}/${booking.serviceDate.year}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                  ),
                  4.verticalSpace,
                  Text(
                    'Total: \$${booking.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8C00),
                    ),
                  ),
                  if (booking.selectedParts.isNotEmpty) ...[
                    8.verticalSpace,
                    Text(
                      'Parts: ${booking.selectedParts.length} items',
                      style:
                          TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                    ),
                  ],
                  12.verticalSpace,
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => controller.updateBookingStatus(
                              booking, 'confirmed'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.blue),
                          ),
                          child: Text('Confirm',
                              style: TextStyle(fontSize: 11.sp)),
                        ),
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => controller.updateBookingStatus(
                              booking, 'completed'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.green),
                          ),
                          child: Text('Complete',
                              style: TextStyle(fontSize: 11.sp)),
                        ),
                      ),
                      8.horizontalSpace,
                      IconButton(
                        icon:
                            Icon(Icons.delete, color: Colors.red, size: 20.sp),
                        onPressed: () => controller.deleteBooking(booking.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildPartsTab() {
    return Obx(() {
      if (controller.parts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.build, size: 64.sp, color: Colors.grey[300]),
              16.verticalSpace,
              Text(
                'No parts yet',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.parts.length,
        itemBuilder: (context, index) {
          final part = controller.parts[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            child: ListTile(
              leading: Icon(Icons.build, color: Color(0xFFFF8C00)),
              title: Text(part.name,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(part.description),
              trailing: Text(
                '\$${part.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8C00),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // Quick Action Methods
  void _showAnalyticsDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Analytics'),
        content: Container(
          height: 200.h,
          child: Column(
            children: [
              Text('Analytics dashboard coming soon!'),
              16.verticalSpace,
              Text('Total Revenue: \$0'),
              Text('Active Users: 0'),
              Text('Services Completed: 0'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    Get.snackbar(
      'Export Data',
      'Data export feature coming soon!',
      backgroundColor: Color(0xFFFF8C00),
      colorText: Colors.white,
    );
  }

  void _showSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Settings'),
        content: Container(
          height: 200.h,
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Enable Notifications'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: Text('Auto-refresh Data'),
                value: false,
                onChanged: (value) {},
              ),
              ListTile(
                title: Text('Clear Cache'),
                leading: Icon(Icons.clear),
                onTap: () {
                  Get.back();
                  Get.snackbar(
                      'Cache Cleared', 'Application cache has been cleared');
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
