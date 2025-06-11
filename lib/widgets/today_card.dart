import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../models/activity_model.dart';
import '../../models/activity_type.dart';

class TodayCard extends StatelessWidget {
  final Duration total;
  final int count;
  final String last;
  final ActivityType type;
  final ActivityModel lastActivity;
  final int percent;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  const TodayCard({
    super.key,
    required this.total,
    required this.count,
    required this.last,
    required this.type,
    required this.percent,
    required this.lastActivity,
    required this.onAdd,
    this.onTap,
  });

  String _formatDuration(Duration d) {
    if (d.inHours > 0 && d.inMinutes.remainder(60) > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    } else if (d.inHours > 0) {
      return '${d.inHours}h';
    } else {
      return '${d.inMinutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Today, ${DateFormat.MMMM().format(DateTime.now())} ${DateTime.now().day}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 120.h,
                      width: 120.w,
                      child: CustomPaint(
                        painter: _ArcPainter(percent / 100),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 18.h),
                        Text(
                          _formatDuration(total),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Total time',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF9900),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text('In company',
                                style: TextStyle(fontSize: 13.sp)),
                            SizedBox(width: 12.w),
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFF5BD3B1),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text('Alone', style: TextStyle(fontSize: 13.sp)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/icons/entry.svg',
                              width: 20.w),
                          SizedBox(width: 6.w),
                          Text('$count Entries',
                              style: TextStyle(fontSize: 16.sp)),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            lastActivity.iconAsset,
                            width: 20.w,
                            height: 20.w,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Latest:',
                                    style: TextStyle(fontSize: 16.sp)),
                                Text(
                                  last,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: onAdd,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/add.svg',
                              width: 24.w,
                              color: const Color(0xFF1284EF),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'New entry',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1284EF),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double percent;

  _ArcPainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFF5BD3B1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = const Color(0xFFFF9900)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = 2.9;
    const sweepAngle = 7 * 3.14 / 6;

    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);
    canvas.drawArc(rect, startAngle, sweepAngle * percent, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
