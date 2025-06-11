import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FriendReminderBlock extends StatelessWidget {
  final String name;
  final DateTime lastDate;

  const FriendReminderBlock({
    super.key,
    required this.name,
    required this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(lastDate);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset('assets/icons/lightbulb.svg',
                  width: 24.w, height: 24.h),
              SizedBox(width: 8.w),
              Text(
                'Reminder',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "You haven't seen $name since $formattedDate. Maybe you should set up a meeting.",
            style: TextStyle(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    final month = months[date.month - 1];
    final day = date.day;
    return '$month ${_ordinal(day)}';
  }

  String _ordinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }
}
