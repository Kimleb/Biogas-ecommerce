import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/technician_controller.dart';
import '../../../data/models/technician_model.dart';

// Extension for spacing
extension HorizontalSpace on double {
  SizedBox get horizontalSpace => SizedBox(width: this);
}

extension VerticalSpace on double {
  SizedBox get verticalSpace => SizedBox(height: this);
}

class TechnicianManagementView extends GetView<TechnicianController> {
  const TechnicianManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Technician Management',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFFFF8C00)),
            onPressed: () => _showAddTechnicianDialog(),
          ),
        ],
      ),
      body: Obx(() => Column(
            children: [
              // Search Bar
              Container(
                padding: EdgeInsets.all(16.w),
                child: TextField(
                  onChanged: controller.searchTechnicians,
                  decoration: InputDecoration(
                    hintText: 'Search technicians...',
                    prefixIcon: Icon(Icons.search),
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
              ),
              16.verticalSpace,

              // Loading Indicator
              if (controller.isLoading.value)
                Container(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Color(0xFFFF8C00)),
                        16.verticalSpace,
                        Text(
                          'Loading technicians...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Error Message
              if (controller.errorMessage.value.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(16.w),
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[600]),
                      12.horizontalSpace,
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.red[600],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red[600]),
                        onPressed: controller.clearError,
                      ),
                    ],
                  ),
                ),

              // Technicians List
              Expanded(
                child: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return _buildTechniciansList(controller.technicians);
                  } else {
                    final filtered = controller.technicians
                        .where((tech) =>
                            tech.name.toLowerCase().contains(
                                controller.searchQuery.value.toLowerCase()) ||
                            (tech.specialization?.toLowerCase().contains(
                                    controller.searchQuery.value
                                        .toLowerCase()) ??
                                false) ||
                            (tech.location?.toLowerCase().contains(controller
                                    .searchQuery.value
                                    .toLowerCase()) ??
                                false))
                        .toList();
                    return _buildTechniciansList(filtered);
                  }
                }),
              ),
            ],
          )),
      floatingActionButton: Obx(() => controller.isAddingTechnician.value
          ? SizedBox.shrink()
          : FloatingActionButton(
              onPressed: () => _showAddTechnicianDialog(),
              backgroundColor: Color(0xFFFF8C00),
              child: Icon(Icons.add, color: Colors.white),
            )),
    );
  }

  Widget _buildTechniciansList(List<TechnicianModel> technicians) {
    if (technicians.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64.sp, color: Colors.grey[400]),
            16.verticalSpace,
            Text(
              'No technicians found',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            8.verticalSpace,
            ElevatedButton(
              onPressed: controller.loadTechnicians,
              child: Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.loadTechnicians,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: technicians.length,
        itemBuilder: (context, index) {
          final technician = technicians[index];
          return _buildTechnicianCard(technician);
        },
      ),
    );
  }

  Widget _buildTechnicianCard(TechnicianModel technician) {
    return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => _showTechnicianDetails(technician),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Technician Avatar
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF8C00).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: technician.profileImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30.r),
                                child: Image.network(
                                  technician.profileImage!,
                                  width: 60.w,
                                  height: 60.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.person,
                                          size: 30.sp, color: Colors.grey[400]),
                                ),
                              )
                            : Icon(Icons.person,
                                size: 30.sp, color: Color(0xFFFF8C00)),
                      ),
                      16.horizontalSpace,
                      // Technician Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              technician.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            4.verticalSpace,
                            Text(
                              technician.specialization ?? 'General Technician',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            4.verticalSpace,
                            Row(
                              children: [
                                Icon(Icons.phone,
                                    size: 14.sp, color: Colors.grey[600]),
                                8.horizontalSpace,
                                Text(
                                  technician.phone,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            4.verticalSpace,
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 14.sp, color: Colors.grey[600]),
                                8.horizontalSpace,
                                Expanded(
                                  child: Text(
                                    technician.location ??
                                        'Location not specified',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            4.verticalSpace,
                            Row(
                              children: [
                                // Availability Badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: technician.isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    technician.isAvailable
                                        ? 'Available'
                                        : 'Unavailable',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                16.horizontalSpace,
                                // Rating
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        size: 14.sp, color: Colors.amber[600]),
                                    8.horizontalSpace,
                                    Text(
                                      technician.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Action Buttons
                      Column(
                        children: [
                          8.verticalSpace,
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      _showTechnicianDetails(technician),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Color(0xFFFF8C00)),
                                  ),
                                  child: Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Color(0xFFFF8C00),
                                    ),
                                  ),
                                ),
                              ),
                              8.horizontalSpace,
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _updateAvailability(technician),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: technician.isAvailable
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  child: Text(
                                    technician.isAvailable
                                        ? 'Set Unavailable'
                                        : 'Set Available',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void _showTechnicianDetails(TechnicianModel technician) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFFF8C00).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: technician.profileImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(25.r),
                              child: Image.network(
                                technician.profileImage!,
                                width: 50.w,
                                height: 50.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.person,
                                        size: 24.sp, color: Colors.grey[400]),
                              ),
                            )
                          : Icon(Icons.person,
                              size: 24.sp, color: Color(0xFFFF8C00)),
                    ),
                    16.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            technician.name,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          4.verticalSpace,
                          Text(
                            technician.specialization ?? 'General Technician',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          8.verticalSpace,
                          Text(
                            technician.phone,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Color(0xFFFF8C00),
                            ),
                          ),
                          4.verticalSpace,
                          Text(
                            technician.location ?? 'Location not specified',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          8.verticalSpace,
                          Row(
                            children: [
                              Icon(Icons.email,
                                  size: 16.sp, color: Colors.grey[600]),
                              8.horizontalSpace,
                              Text(
                                technician.email,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          8.verticalSpace,
                          Row(
                            children: [
                              Icon(Icons.star,
                                  size: 16.sp, color: Colors.amber[600]),
                              8.horizontalSpace,
                              Text(
                                '${technician.rating.toStringAsFixed(1)} (${technician.completedJobs} jobs)',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          8.verticalSpace,
                          Text(
                            'Skills: ${technician.skills.join(', ')}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          16.verticalSpace,
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16.sp, color: Colors.grey[600]),
                              8.horizontalSpace,
                              Text(
                                'Last Active: ${technician.lastActive != null ? _formatDate(technician.lastActive!) : 'Never'}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Close Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Color(0xFFFF8C00),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    );
  }

  void _updateAvailability(TechnicianModel technician) {
    Get.dialog(
      AlertDialog(
        title: Text('Update Availability'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Do you want to ${technician.isAvailable ? 'set unavailable' : 'set available'} ${technician.name}?',
              style: TextStyle(fontSize: 16.sp),
            ),
            16.verticalSpace,
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateAvailability(
                  technician.id, !technician.isAvailable);
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showAddTechnicianDialog() {
    Get.dialog(AlertDialog(
      title: Text('Add Technician'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            16.verticalSpace,
            TextField(
              controller: controller.emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            16.verticalSpace,
            TextField(
              controller: controller.phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            16.verticalSpace,
            TextField(
              controller: controller.specializationController,
              decoration: InputDecoration(
                labelText: 'Specialization',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            16.verticalSpace,
            TextField(
              controller: controller.locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel'),
        ),
        Obx(() => ElevatedButton(
              onPressed: controller.isAddingTechnician.value
                  ? null
                  : controller.addTechnician,
              child: controller.isAddingTechnician.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Add Technician'),
            )),
      ],
    ));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
