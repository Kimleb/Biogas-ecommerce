import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/calendar_controller.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar', style: context.theme.textTheme.headlineSmall),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              Get.snackbar(
                'Calendar',
                'Calendar sync coming soon!',
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                colorText: theme.textTheme.bodyLarge?.color,
              );
            },
            icon: Icon(Icons.sync),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Get.snackbar(
                      'Navigation',
                      'Month navigation coming soon!',
                      backgroundColor: theme.hintColor.withOpacity(0.1),
                      colorText: theme.textTheme.bodyLarge?.color,
                    );
                  },
                  icon: Icon(Icons.chevron_left),
                ),
                Text(
                  '${_getMonthName(now.month)} ${now.year}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.snackbar(
                      'Navigation',
                      'Month navigation coming soon!',
                      backgroundColor: theme.hintColor.withOpacity(0.1),
                      colorText: theme.textTheme.bodyLarge?.color,
                    );
                  },
                  icon: Icon(Icons.chevron_right),
                ),
              ],
            ),
            24.verticalSpace,

            // Calendar Grid
            Expanded(
              child: Column(
                children: [
                  // Weekday Headers
                  Row(
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map((day) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  8.verticalSpace,

                  // Calendar Days Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: 35, // 5 weeks * 7 days
                      itemBuilder: (context, index) {
                        final dayNumber = index - _getFirstDayOfMonth(now) + 1;
                        final isValidDay =
                            dayNumber > 0 && dayNumber <= _getDaysInMonth(now);
                        final isToday = isValidDay && dayNumber == now.day;
                        final hasBooking =
                            isValidDay && _hasBookingOnDay(dayNumber);

                        return Container(
                          margin: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: isToday
                                ? theme.primaryColor.withOpacity(0.2)
                                : hasBooking
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                            border: isToday
                                ? Border.all(
                                    color: theme.primaryColor, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isValidDay)
                                  Text(
                                    '$dayNumber',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isToday
                                          ? theme.primaryColor
                                          : theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                if (hasBooking && isValidDay)
                                  Container(
                                    width: 4.w,
                                    height: 4.w,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            16.verticalSpace,

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                  context,
                  color: theme.primaryColor,
                  label: 'Today',
                ),
                _buildLegendItem(
                  context,
                  color: Colors.green,
                  label: 'Bookings',
                ),
                _buildLegendItem(
                  context,
                  color: theme.hintColor,
                  label: 'Available',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context,
      {required Color color, required String label}) {
    final theme = context.theme;

    return Row(
      children: [
        Container(
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: color, width: 1),
          ),
        ),
        8.horizontalSpace,
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  int _getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  bool _hasBookingOnDay(int day) {
    // Simulate some bookings on specific days
    return [5, 12, 15, 20, 25].contains(day);
  }
}

// Extension for horizontal space
extension HorizontalSpace on double {
  SizedBox get horizontalSpace => SizedBox(width: this);
}

// Extension for vertical space
extension VerticalSpace on double {
  SizedBox get verticalSpace => SizedBox(height: this);
}
