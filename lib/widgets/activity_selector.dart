import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/activity_model.dart';

class ActivitySelector extends StatelessWidget {
  final ActivityModel? activity;
  final VoidCallback onTap;

  const ActivitySelector({
    super.key,
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = activity == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Activity',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.circle, size: 6, color: Color(0xFF1284EF)),
          ],
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      activity?.isCustom == true
                          ? 'assets/icons/act.svg'
                          : activity?.iconAsset ?? 'assets/icons/act.svg',
                      width: 16.w,
                      height: 16.w,
                      color: isEmpty ? const Color(0xFF999999) : Colors.black,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      activity?.name ?? 'Select activity',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isEmpty ? const Color(0xFF999999) : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, size: 16.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
