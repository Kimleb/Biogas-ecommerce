import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/admin_controller.dart';

class AdminServicesView extends GetView<AdminController> {
  const AdminServicesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Services Management',
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.w),
                leading: Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: service.primaryImage != null && service.primaryImage!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            service.primaryImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.eco_rounded, 
                                color: Color(0xFF4CAF50), 
                                size: 30.w
                              );
                            },
                          ),
                        )
                      : Icon(Icons.eco_rounded, 
                        color: Color(0xFF4CAF50), 
                        size: 30.w
                      ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    8.verticalSpace,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                    if (service.category != null) ...[
                      4.verticalSpace,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          service.category![0].toUpperCase() + service.category!.substring(1),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) {
                    if (value == 'delete') {
                      controller.deleteService(service.id.toString());
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20.w),
                          8.horizontalSpace,
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.showAddServiceDialog(),
        backgroundColor: Color(0xFFFF8C00),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add Service', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
