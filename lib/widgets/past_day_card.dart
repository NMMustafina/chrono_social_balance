import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class PastDayCard extends StatelessWidget {
  final String title;
  final String duration;
  final int count;
  final int percent;
  final VoidCallback onTap;

  const PastDayCard({
    super.key,
    required this.title,
    required this.duration,
    required this.count,
    required this.percent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            SizedBox(height: 6.h),
            Row(
              children: [
                SvgPicture.asset('assets/icons/record.svg', width: 20.w),
                SizedBox(width: 4.w),
                Text('Time recorded: $duration',
                    style: TextStyle(fontSize: 16.sp)),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                SvgPicture.asset('assets/icons/entry.svg', width: 20.w),
                SizedBox(width: 4.w),
                Text('$count Entries', style: TextStyle(fontSize: 16.sp)),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$percent% In company', style: TextStyle(fontSize: 12.sp)),
                Text('Alone ${100 - percent}%',
                    style: TextStyle(fontSize: 12.sp)),
              ],
            ),
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                minHeight: 8.h,
                value: percent / 100,
                backgroundColor: const Color(0xFF5BD3B1),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFF9900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
