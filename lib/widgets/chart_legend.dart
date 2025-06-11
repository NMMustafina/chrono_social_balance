import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChartLegend extends StatelessWidget {
  final Duration total;
  final Duration inCompany;
  final Duration alone;

  const ChartLegend({
    super.key,
    required this.total,
    required this.inCompany,
    required this.alone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item('assets/icons/clock.svg', 'Total', total),
          _item('assets/icons/friends.svg', 'In company', inCompany,
              underline: const Color(0xFFFF9900)),
          _item('assets/icons/user.svg', 'Alone', alone,
              underline: const Color(0xFF5BD3B1)),
        ],
      ),
    );
  }

  Widget _item(String icon, String label, Duration time, {Color? underline}) {
    final formatted = _format(time);

    return Column(
      children: [
        Row(
          children: [
            SvgPicture.asset(icon, width: 16.w, color: Colors.black),
            SizedBox(width: 4.w),
            Text(label, style: TextStyle(fontSize: 12.sp)),
          ],
        ),
        SizedBox(height: 4.h),
        Stack(
          children: [
            Text(
              formatted,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (underline != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2.h,
                  color: underline,
                ),
              ),
          ],
        ),
      ],
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
