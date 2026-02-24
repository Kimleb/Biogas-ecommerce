import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_icon_button.dart';
import '../../../data/services/unsplash_service.dart';
import '../controllers/product_details_controller.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(
              height: 330.h,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SvgPicture.asset(
                      Constants.container,
                      fit: BoxFit.fill,
                      color: theme.cardColor,
                    ),
                  ),
                  Positioned(
                    top: 24.h,
                    left: 24.w,
                    right: 24.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomIconButton(
                          onPressed: () => Get.back(),
                          icon: SvgPicture.asset(
                            Constants.backArrowIcon,
                            fit: BoxFit.none,
                            color: theme.appBarTheme.iconTheme?.color,
                          ),
                        ),
                        CustomIconButton(
                          onPressed: () {},
                          icon: SvgPicture.asset(
                            Constants.searchIcon,
                            fit: BoxFit.none,
                            color: theme.appBarTheme.iconTheme?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 80.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 250.w,
                        height: 225.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          color: theme.primaryColor.withOpacity(0.1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: controller.product.images.contains('.svg')
                              ? SvgPicture.asset(
                                  controller.product.images.toString(),
                                  fit: BoxFit.contain)
                              : controller.product.images.contains('assets')
                                  ? Image.asset(
                                      controller.product.images.toString(),
                                      fit: BoxFit.cover)
                                  : Image.network(
                                      UnsplashService.getServiceImage(controller
                                          .product.name
                                          .toLowerCase()),
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                              Icons.miscellaneous_services,
                                              size: 60.sp,
                                              color: theme.primaryColor),
                                        );
                                      },
                                    ),
                        ),
                      ),
                    ).animate().fade().scale(
                          duration: 800.ms,
                          curve: Curves.fastOutSlowIn,
                        ),
                  ),
                ],
              ),
            ),
            30.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.product.name,
                      style: theme.textTheme.displayMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fade().slideX(
                          duration: 300.ms,
                          begin: -1,
                          curve: Curves.easeInSine,
                        ),
                  ),
                  8.horizontalSpace,
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      controller.product.duration,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).animate().fade(duration: 200.ms),
                ],
              ),
            ),
            8.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                '${controller.product.duration} • \$${controller.product.price.toStringAsFixed(0)}',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ).animate().fade().slideX(
                    duration: 300.ms,
                    begin: -1,
                    curve: Curves.easeInSine,
                  ),
            ),
            8.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Icon(Icons.person, size: 16.sp, color: theme.hintColor),
                  8.horizontalSpace,
                  Text(
                    controller.product.technician ?? 'No technician assigned',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            16.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                controller.product.description,
                style: theme.textTheme.bodyLarge,
              ).animate().fade().slideX(
                    duration: 300.ms,
                    begin: -1,
                    curve: Curves.easeInSine,
                  ),
            ),
            30.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: CustomButton(
                text: 'Book Service',
                onPressed: () => controller.onAddToCartPressed(),
                fontSize: 16.sp,
                radius: 50.r,
                verticalPadding: 16.h,
                hasShadow: false,
              ).animate().fade().slideY(
                    duration: 300.ms,
                    begin: 1,
                    curve: Curves.easeInSine,
                  ),
            ),
            30.verticalSpace,
          ],
        ),
      ),
    );
  }
}
