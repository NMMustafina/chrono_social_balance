import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyFriendStatsView extends StatelessWidget {
  const EmptyFriendStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/user_hand_up.svg',
            height: 72.sp,
            width: 72.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'Add a friend to the record to see statistics',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
