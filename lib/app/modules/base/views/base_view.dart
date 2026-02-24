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
import '../../home/views/home_view.dart';

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
                    HomeView(),
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
              label: 'Home',
              icon: Constants.homeIcon,
            ),
            _mBottomNavItem(
              label: 'category',
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          onPressed: () => Get.toNamed(Routes.CART),
          child: GetBuilder<BaseController>(
            id: 'CartBadge',
            builder: (_) => badges.Badge(
              position: badges.BadgePosition.bottomEnd(bottom: -16, end: 13),
              badgeContent: Text(
                controller.cartItemsCount.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              badgeStyle: badges.BadgeStyle(
                elevation: 2,
                badgeColor: theme.colorScheme.secondary,
                borderSide: const BorderSide(color: Colors.white, width: 1),
              ),
              child: CircleAvatar(
                radius: 22.r,
                backgroundColor: theme.primaryColor,
                child: SvgPicture.asset(
                  Constants.cartIcon,
                  fit: BoxFit.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
