import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FriendStatsSummaryBlock extends StatelessWidget {
  final Duration total;
  final int meetings;
  final Duration average;

  const FriendStatsSummaryBlock({
    super.key,
    required this.total,
    required this.meetings,
    required this.average,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _item('Total time with\nfriends', _format(total)),
          _item('Number of\nmeetings', meetings.toString()),
          _item('Average\nduration', _format(average)),
        ],
      ),
    );
  }

  Widget _item(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.black)),
          SizedBox(height: 8.h),
          Text(value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              )),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
