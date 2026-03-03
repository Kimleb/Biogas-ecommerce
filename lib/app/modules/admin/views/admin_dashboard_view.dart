import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/admin_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../../data/services/auth_service.dart';

extension HorizontalSpace on double {
  SizedBox get horizontalSpace => SizedBox(width: this);
}

extension VerticalSpace on double {
  SizedBox get verticalSpace => SizedBox(height: this);
}

class AdminDashboardView extends GetView<AdminController> {
  const AdminDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }
        return RefreshIndicator(
          onRefresh: () => controller.loadData(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Modern Header
                _buildHeader(),
                // Summary Cards
                _buildSummarySection(),
                // Quick Actions Section
                _buildQuickActionsSection(),
                // Tab Section
                _buildTabSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2E3192), // Deep blue
            Color(0xFF1B1464), // Darker blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2E3192).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
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
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  6.verticalSpace,
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Manage your biogas services',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showLogoutDialog(),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
              ),
            ],
          ),
          24.verticalSpace,
          // Summary Cards
          _buildSummaryCards(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E3192), Color(0xFFFF8C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          24.verticalSpace,
          Text(
            'Loading Dashboard...',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3192),
            ),
          ),
          8.verticalSpace,
          Text(
            'Please wait while we fetch your data',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xFF2E3192).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Color(0xFF2E3192), size: 16.sp),
                    4.horizontalSpace,
                    Text(
                      'Last updated: Just now',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Color(0xFF2E3192),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          16.verticalSpace,
          _buildSummaryCards(),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          16.verticalSpace,
          _buildQuickActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          _buildModernTabBar(),
          16.verticalSpace,
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Color(0xFF2E3192).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Color(0xFF2E3192).withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2E3192), size: 20.sp),
                8.horizontalSpace,
                Expanded(
                  child: Text(
                    'Navigate to different management sections using the tabs above',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Color(0xFF2E3192),
                      fontWeight: FontWeight.w500,
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

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildAnimatedSummaryCard(
            'Total Services',
            '${controller.services.length}',
            Icons.eco_rounded,
            Color(0xFF4CAF50),
            '',
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: _buildAnimatedSummaryCard(
            'Total Bookings',
            '${controller.bookings.length}',
            Icons.calendar_today,
            Color(0xFF2196F3),
            '',
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: _buildAnimatedSummaryCard(
            'Total Parts',
            '${controller.parts.length}',
            Icons.build,
            Color(0xFFFF9800),
            '',
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSummaryCard(
      String title, String value, IconData icon, Color color, String trend) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.white, size: 22.sp),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 12.sp),
                    2.horizontalSpace,
                    Text(
                      '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          4.verticalSpace,
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
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
                'Test Cloudinary',
                Icons.cloud_upload_outlined,
                Color(0xFF9C27B0),
                () => _testCloudinaryConfig(),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: _buildQuickActionButton(
                'Force Refresh',
                Icons.refresh,
                Color(0xFFFF5722),
                () => controller.loadData(),
              ),
            ),
          ],
        ),
        12.verticalSpace,
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                'Test Image Picker',
                Icons.image_search_outlined,
                Color(0xFFE91E63),
                () => controller.testImagePicker(),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: _buildQuickActionButton(
                'Export Data',
                Icons.download_outlined,
                Color(0xFFFF9800),
                () => Get.toNamed(Routes.ADMIN_SERVICES),
              ),
            ),
          ],
        ),
        12.verticalSpace,
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                'Settings',
                Icons.settings_outlined,
                Color(0xFF607D8B),
                () => _showSettingsDialog(),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: SizedBox(), // Empty placeholder
            ),
          ],
        ),
      ],
    );
  }

  void _testCloudinaryConfig() {
    final cloudinaryService = Get.find<CloudinaryService>();
    cloudinaryService.testConfiguration();
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                      size: 24.sp,
                    ),
                  ),
                  16.horizontalSpace,
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              16.verticalSpace,
              Text(
                'Are you sure you want to logout from the admin dashboard?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              24.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Close dialog
                        await AuthService.to.signOut(); // Logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
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
    );
  }

  void _showDebugInfo() {
    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Debug Information',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              16.verticalSpace,
              Text('Services: ${controller.services.length}'),
              Text('Bookings: ${controller.bookings.length}'),
              Text('Parts: ${controller.parts.length}'),
              Text('Loading: ${controller.isLoading.value}'),
              16.verticalSpace,
              Text(
                  'Controller Registered: ${Get.isRegistered<AdminController>()}'),
              16.verticalSpace,
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
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
      child: Row(
        children: [
          _buildModernTab('Services', 0, Icons.eco_rounded),
          _buildModernTab('Bookings', 1, Icons.calendar_today),
          _buildModernTab('Parts', 2, Icons.build),
        ],
      ),
    );
  }

  Widget _buildModernTab(String title, int index, IconData icon) {
    final isSelected = false;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            Get.toNamed(Routes.ADMIN_SERVICES);
          } else if (index == 1) {
            Get.toNamed(Routes.ADMIN_BOOKINGS);
          } else if (index == 2) {
            Get.toNamed(Routes.ADMIN_PARTS);
          }
        },
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
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Color(0xFFF8F9FA),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.w),
                leading: Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF5F9E8),
                        Color(0xFFE8F5E8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF8C00).withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.eco_rounded,
                      color: Color(0xFFFF8C00), size: 28.sp),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Colors.black87,
                      ),
                    ),
                    8.verticalSpace,
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF8C00).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '\$${service.price.toStringAsFixed(2)} • ${service.duration}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0xFFFF8C00),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue, size: 16.sp),
                            8.horizontalSpace,
                            Text('Edit'),
                          ],
                        ),
                        value: 'edit',
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 16.sp),
                            8.horizontalSpace,
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
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
            margin: EdgeInsets.only(bottom: 16.h),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Color(0xFFF8F9FA),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
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
                              fontSize: 16.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: controller
                                .getStatusColor(booking.status)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: controller
                                  .getStatusColor(booking.status)
                                  .withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            booking.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: controller.getStatusColor(booking.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    12.verticalSpace,
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          _buildBookingInfoRow(
                            Icons.person_outline,
                            'Customer',
                            booking.customerName,
                          ),
                          8.verticalSpace,
                          _buildBookingInfoRow(
                            Icons.calendar_today_outlined,
                            'Date',
                            '${booking.serviceDate.day}/${booking.serviceDate.month}/${booking.serviceDate.year}',
                          ),
                          if (booking.selectedParts.isNotEmpty) ...[
                            8.verticalSpace,
                            _buildBookingInfoRow(
                              Icons.inventory_2_outlined,
                              'Parts',
                              '${booking.selectedParts.length} items',
                            ),
                          ],
                        ],
                      ),
                    ),
                    12.verticalSpace,
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF8C00).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.attach_money,
                              color: Color(0xFFFF8C00), size: 16.sp),
                          4.horizontalSpace,
                          Text(
                            'Total: \$${booking.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8C00),
                            ),
                          ),
                        ],
                      ),
                    ),
                    16.verticalSpace,
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 36.h,
                            child: ElevatedButton(
                              onPressed: () => controller.updateBookingStatus(
                                  booking, 'confirmed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text('Confirm',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ),
                        ),
                        8.horizontalSpace,
                        Expanded(
                          child: Container(
                            height: 36.h,
                            child: ElevatedButton(
                              onPressed: () => controller.updateBookingStatus(
                                  booking, 'completed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text('Complete',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ),
                        ),
                        8.horizontalSpace,
                        Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Colors.red, size: 18.sp),
                            onPressed: () =>
                                controller.deleteBooking(booking.id),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildBookingInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: Color(0xFFFF8C00).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: Color(0xFFFF8C00), size: 16.sp),
        ),
        12.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Color(0xFFF8F9FA),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.w),
                leading: Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFF4E6),
                        Color(0xFFFFE0B2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF9800).withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child:
                      Icon(Icons.build, color: Color(0xFFFF9800), size: 28.sp),
                ),
                title: Text(
                  part.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    part.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ),
                trailing: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Color(0xFFFF9800).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '\$${part.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: Color(0xFFFF9800),
                    ),
                  ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.analytics_outlined,
                  color: Color(0xFF2196F3), size: 24.sp),
            ),
            12.horizontalSpace,
            Text(
              'Analytics Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Container(
          width: 300.w,
          height: 250.h,
          child: Column(
            children: [
              _buildAnalyticsItem(
                Icons.attach_money,
                'Total Revenue',
                '\$12,450.00',
                Color(0xFF4CAF50),
                '',
              ),
              16.verticalSpace,
              _buildAnalyticsItem(
                Icons.people_outline,
                'Active Users',
                '1,234',
                Color(0xFF2196F3),
                '',
              ),
              16.verticalSpace,
              _buildAnalyticsItem(
                Icons.eco_rounded,
                'Services Completed',
                '89',
                Color(0xFFFF8C00),
                '',
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child:
                  Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(
      IconData icon, String title, String value, Color color, String trend) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                4.verticalSpace,
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 10.sp),
                2.horizontalSpace,
                Text(
                  '',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.settings_outlined,
                  color: Color(0xFF9C27B0), size: 24.sp),
            ),
            12.horizontalSpace,
            Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Container(
          width: 300.w,
          height: 200.h,
          child: Column(
            children: [
              _buildSettingsTile(
                'Enable Notifications',
                'Receive push notifications',
                Icons.notifications_outlined,
                true,
                (value) {},
              ),
              8.verticalSpace,
              _buildSettingsTile(
                'Auto-refresh Data',
                'Automatically refresh dashboard',
                Icons.refresh_outlined,
                false,
                (value) {},
              ),
              8.verticalSpace,
              _buildSettingsActionTile(
                'Clear Cache',
                'Clear application cache',
                Icons.clear_all_outlined,
                () {
                  Get.back();
                  Get.snackbar(
                    'Cache Cleared',
                    'Application cache has been cleared',
                    backgroundColor: Color(0xFF4CAF50),
                    colorText: Colors.white,
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child:
                  Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, IconData icon,
      bool value, Function(bool) onChanged) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Color(0xFF9C27B0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: Color(0xFF9C27B0), size: 20.sp),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF9C27B0),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsActionTile(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: Colors.red, size: 20.sp),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16.sp),
          ],
        ),
      ),
    );
  }
}
