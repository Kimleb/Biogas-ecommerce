import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../data/models/service_model.dart';
import '../modules/cart/controllers/cart_controller.dart';
import '../modules/base/controllers/base_controller.dart';
import '../routes/app_pages.dart';
import '../../config/theme/light_theme_colors.dart';

// Extension for horizontal space
extension HorizontalSpace on double {
  SizedBox get horizontalSpace => SizedBox(width: this);
}

class ServiceItem extends StatelessWidget {
  final ServiceModel service;
  const ServiceItem({Key? key, required this.service}) : super(key: key);

  // Add service to cart
  void addToCart() {
    // Ensure CartController is registered
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController());
    }

    final cartController = Get.find<CartController>();

    // Add service to cart using new system
    cartController.onIncreasePressed(service.id);

    // Update cart badge if BaseController is registered
    if (Get.isRegistered<BaseController>()) {
      Get.find<BaseController>().getCartItemsCount();
    }

    // Show success message
    Get.snackbar(
      'Added to Cart',
      '${service.name} has been added to your cart',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Modern gradient colors for cards
    final List<List<Color>> cardGradients = [
      [Color(0xFFE8F5E8), Color(0xFFF0F9E8)], // Light green
      [Color(0xFFFFF4E6), Color(0xFFFFF8F0)], // Light orange
      [Color(0xFFF0F4FF), Color(0xFFF8FAFF)], // Light blue
      [Color(0xFFFFF0F5), Color(0xFFFFF5FA)], // Light pink
    ];
    final gradient = cardGradients[service.id.hashCode % cardGradients.length];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: LightThemeColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: LightThemeColors.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.PRODUCT_DETAILS, arguments: service),
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image Section
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  child: Stack(
                    children: [
                      Center(
                        child: _buildServiceImage(),
                      ),
                      // Badge for rating if available
                      if (service.rating > 0)
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: LightThemeColors.accentColor,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: LightThemeColors.accentColor
                                      .withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 12.sp,
                                ),
                                2.horizontalSpace,
                                Text(
                                  service.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Service Details Section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Service Name and Description
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: LightThemeColors.headlinesTextColor,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          4.verticalSpace,
                          Text(
                            service.description,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: LightThemeColors.bodyTextColor,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      8.verticalSpace,
                      // Price and Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${service.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: LightThemeColors.primaryColor,
                                ),
                              ),
                              if (service.duration.isNotEmpty)
                                Text(
                                  service.duration,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: LightThemeColors.captionTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          // Add to Cart Button
                          GestureDetector(
                            onTap: addToCart,
                            child: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    LightThemeColors.primaryColor,
                                    LightThemeColors.primaryColorLight,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: LightThemeColors.primaryColor
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                                size: 18.sp,
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

  Widget _buildServiceImage() {
    // Handle different image types
    if (service.images.isNotEmpty && service.primaryImage != null) {
      final imageUrl = service.primaryImage!;

      // Network image with caching
      if (imageUrl.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            width: 80.w,
            height: 80.h,
            placeholder: (context, url) => Container(
              width: 80.w,
              height: 80.h,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    LightThemeColors.primaryColor,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => _buildDefaultIcon(),
          ),
        );
      }

      // SVG asset
      if (imageUrl.endsWith('.svg')) {
        return SvgPicture.asset(
          imageUrl,
          fit: BoxFit.contain,
          width: 80.w,
          height: 80.h,
        );
      }

      // Regular asset
      if (imageUrl.startsWith('assets')) {
        return Image.asset(
          imageUrl,
          fit: BoxFit.contain,
          width: 80.w,
          height: 80.h,
          errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
        );
      }
    }

    // Default icon
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: LightThemeColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        Icons.eco_rounded,
        size: 40.sp,
        color: LightThemeColors.primaryColor.withOpacity(0.6),
      ),
    );
  }
}

// Keep ProductItem for backward compatibility
class ProductItem extends ServiceItem {
  ProductItem({required dynamic product}) : super(service: product);
}
