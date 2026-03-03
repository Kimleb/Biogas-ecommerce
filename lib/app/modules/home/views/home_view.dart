import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/dark_transition.dart';
import '../../../components/product_item.dart';
import '../controllers/home_controller.dart';
import '../../payment/views/payment_view.dart';

// Extension for horizontal space
extension HorizontalSpace on double {
  SizedBox get horizontalSpace => SizedBox(width: this);
}

// Extension for vertical space
extension VerticalSpace on double {
  SizedBox get verticalSpace => SizedBox(height: this);
}

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DarkTransition(
      offset: Offset(context.width, -1),
      isDark: !controller.isLightTheme,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Modern Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4A90E2), // Light blue
                        Color(0xFF357ABD), // Medium blue
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4A90E2).withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Biogas',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'Services, Simplified',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.95),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Admin button - show for all users
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () => Get.to(() => PaymentView()),
                                  icon: Icon(Icons.shopping_bag_outlined,
                                      size: 22.sp),
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFF6B6B),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
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
                ),
              ),

              // Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommended for You',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF8C00),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Products Grid
              GetBuilder<HomeController>(
                builder: (ctrl) {
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                    sliver: ctrl.services.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.h),
                                child: Column(
                                  children: [
                                    const CircularProgressIndicator(
                                        color: Color(0xFFFF8C00)),
                                    16.verticalSpace,
                                    Text(
                                      'Loading services...',
                                      style: TextStyle(
                                          fontSize: 14.sp, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12.w,
                              mainAxisSpacing: 12.h,
                              childAspectRatio: 0.75,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => ProductItem(
                                product: ctrl.services[index],
                              ),
                              childCount: ctrl.services.length,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFFF8C00) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
