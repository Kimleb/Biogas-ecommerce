import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/custom_button.dart';
import '../../../routes/app_pages.dart';
import '../controllers/category_controller.dart';

// Extension for string capitalization
extension StringExtension on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

class CategoryView extends GetView<CategoryController> {
  const CategoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.selectedCategory.value.isEmpty
                  ? 'Services'
                  : '${GetStringUtils(controller.selectedCategory.value).capitalizeFirst} Services',
              style: context.theme.textTheme.headlineSmall,
            )),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: controller.selectedCategory.value.isNotEmpty
            ? IconButton(
                onPressed: () => controller.selectedCategory.value = '',
                icon: Icon(Icons.arrow_back),
              )
            : null,
        actions: controller.selectedCategory.value.isNotEmpty
            ? [
                IconButton(
                  onPressed: controller.refreshServices,
                  icon: Icon(Icons.refresh),
                ),
              ]
            : null,
      ),
      body: Obx(() {
        if (controller.selectedCategory.value.isEmpty) {
          return _buildCategoriesGrid(context, theme);
        } else {
          return _buildServicesList(context, theme);
        }
      }),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    final theme = context.theme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          _navigateToCategoryServices(title);
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  icon,
                  size: 30.w,
                  color: color,
                ),
              ),
              12.verticalSpace,
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              8.verticalSpace,
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCategoryServices(String category) {
    // Load services from database for this category
    controller.loadServicesByCategory(category);
  }

  Widget _buildCategoriesGrid(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Service Category',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          16.verticalSpace,
          Text(
            'Select the type of biogas service you need',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
          24.verticalSpace,
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.0,
              children: [
                _buildCategoryCard(
                  context,
                  title: 'Installation',
                  icon: Icons.build,
                  color: Colors.blue,
                  description: 'New biogas plant',
                ),
                _buildCategoryCard(
                  context,
                  title: 'Maintenance',
                  icon: Icons.handyman,
                  color: Colors.green,
                  description: 'Regular servicing',
                ),
                _buildCategoryCard(
                  context,
                  title: 'Inspection',
                  icon: Icons.search,
                  color: Colors.orange,
                  description: 'System health check',
                ),
                _buildCategoryCard(
                  context,
                  title: 'Consultation',
                  icon: Icons.lightbulb,
                  color: Colors.purple,
                  description: 'Expert advice',
                ),
                _buildCategoryCard(
                  context,
                  title: 'Emergency',
                  icon: Icons.warning,
                  color: Colors.red,
                  description: 'Urgent repair services',
                ),
                _buildCategoryCard(
                  context,
                  title: 'Training',
                  icon: Icons.school,
                  color: Colors.teal,
                  description: 'Operator training',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(BuildContext context, ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              16.verticalSpace,
              Text(
                'Loading services...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        );
      }

      if (controller.services.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, size: 80.w, color: theme.hintColor),
              16.verticalSpace,
              Text(
                'No services found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              8.verticalSpace,
              Text(
                'in ${controller.selectedCategory.value} category',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              24.verticalSpace,
              CustomButton(
                text: 'Go Back',
                onPressed: () => controller.selectedCategory.value = '',
                fontSize: 14.sp,
                verticalPadding: 12.h,
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.services.length} services found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            16.verticalSpace,
            Expanded(
              child: ListView.builder(
                itemCount: controller.services.length,
                itemBuilder: (context, index) {
                  final service = controller.services[index];
                  return _buildServiceCard(context, theme, service);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildServiceCard(
      BuildContext context, ThemeData theme, dynamic service) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Get.toNamed(Routes.BOOKING, arguments: service);
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Service Image
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: service.primaryImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.asset(
                          service.primaryImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.eco_rounded,
                                color: theme.primaryColor, size: 30.w);
                          },
                        ),
                      )
                    : Icon(Icons.eco_rounded,
                        color: theme.primaryColor, size: 30.w),
              ),
              16.horizontalSpace,
              // Service Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name ?? 'Service',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.verticalSpace,
                    Text(
                      service.description ?? 'No description available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.verticalSpace,
                    Row(
                      children: [
                        // Price
                        Text(
                          '\$${service.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        16.horizontalSpace,
                        // Duration
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            service.duration ?? 'Unknown',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        // Rating
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16.w),
                            4.horizontalSpace,
                            Text(
                              service.rating?.toStringAsFixed(1) ?? '0.0',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
