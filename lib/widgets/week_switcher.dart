import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeekSwitcher extends StatelessWidget {
  final int currentWeek;
  final int totalWeeks;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const WeekSwitcher({
    super.key,
    required this.currentWeek,
    required this.totalWeeks,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = currentWeek == 1;
    final isLast = currentWeek == totalWeeks;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.chevron_left,
                  size: 28.sp, color: isFirst ? Colors.grey : Colors.black),
              onPressed: isFirst ? null : onPrev,
            ),
          ),
          Text(
            'Week $currentWeek',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.chevron_right,
                  size: 28.sp, color: isLast ? Colors.grey : Colors.black),
              onPressed: isLast ? null : onNext,
            ),
          ),
        ],
      ),
    );
  }
}
