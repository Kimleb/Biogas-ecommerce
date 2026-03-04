import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart' as badges;
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../routes/app_pages.dart';
import '../../booking/views/booking_view.dart';
import '../../calendar/views/calendar_view.dart';
import '../../category/views/category_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/base_controller.dart';
import '../../booking/controllers/booking_controller.dart';

// Extension for vertical space
extension VerticalSpace on double {
  SizedBox get verticalSpace => SizedBox(height: this);
}

class BaseView extends StatelessWidget {
  const BaseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = context.theme;

    // Ensure BaseController is initialized
    if (!Get.isRegistered<BaseController>()) {
      Get.put(BaseController());
    }
    // Ensure BookingController is initialized (used by IndexedStack)
    if (!Get.isRegistered<BookingController>()) {
      Get.lazyPut(() => BookingController());
    }

    final controller = Get.find<BaseController>();

    return GetBuilder<BaseController>(
        builder: (_) => Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Welcome header for signed-in users
                    if (controller.isUserSignedIn)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16.r),
                            bottomRight: Radius.circular(16.r),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back! 👋',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            4.verticalSpace,
                            Text(
                              controller.userName,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.primaryColorDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Main content
                    Expanded(
                      child: IndexedStack(
                        index: controller.currentIndex,
                        children: const [
                          CategoryView(),
                          BookingView(),
                          CalendarView(),
                          ProfileView(), // Removed the space before ProfileView
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: controller.currentIndex,
                type: BottomNavigationBarType.fixed,
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                selectedFontSize: 0.0,
                items: [
                  _mBottomNavItem(
                    label: 'Category',
                    icon: Constants.categoryIcon,
                  ),
                  _mBottomNavItem(
                    label: 'Booking',
                    icon: Constants.bookingIcon,
                  ),
                  _mBottomNavItem(
                    label: 'Calendar',
                    icon: Constants.calendarIcon,
                  ),
                  _mBottomNavItem(
                    label: 'Profile',
                    icon: Constants.userIcon,
                  ),
                ],
                onTap: controller.changeScreen,
              ),
            ));
  }

  _mBottomNavItem({required String label, required String icon}) {
    return BottomNavigationBarItem(
      label: label,
      icon: SvgPicture.asset(icon, color: Get.theme.iconTheme.color),
      activeIcon:
          SvgPicture.asset(icon, color: Get.theme.appBarTheme.iconTheme?.color),
    );
  }
}
