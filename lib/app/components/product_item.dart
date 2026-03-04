import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../data/models/service_model.dart';
import '../modules/cart/controllers/cart_controller.dart';
import '../modules/base/controllers/base_controller.dart';
import '../routes/app_pages.dart';

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
    // Pastel background colors for cards
    final List<Color> cardColors = [
      Color(0xFFF5F9E8), // Light green
      Color(0xFFFFF4E6), // Light orange
      Color(0xFFF0F4FF), // Light blue
      Color(0xFFFFF0F5), // Light pink
    ];
    final cardColor = cardColors[service.id.hashCode % cardColors.length];

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PRODUCT_DETAILS, arguments: service),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            Container(
              height: 140.h,
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: service.images.contains('.svg')
                    ? SvgPicture.asset(
                        service.images as String,
                        fit: BoxFit.contain,
                        width: 50.w,
                        height: 50.h,
                      )
                    : service.images.contains('assets')
                        ? Image.asset(
                            service.images as String,
                            fit: BoxFit.contain,
                            width: 50.w,
                            height: 50.h,
                          )
                        : Icon(
                            Icons.eco_rounded,
                            size: 60.sp,
                            color: Color(0xFFFF8C00).withOpacity(0.3),
                          ),
              ),
            ),
            // Service Details
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Name
                  Text(
                    service.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.verticalSpace,
                  8.verticalSpace,
                  // Price and Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${service.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          if (service.rating > 0)
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color: Colors.amber, size: 12.sp),
                                2.horizontalSpace,
                                Text(
                                  service.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: addToCart,
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF8C00),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep ProductItem for backward compatibility
class ProductItem extends ServiceItem {
  ProductItem({required dynamic product}) : super(service: product);
}
