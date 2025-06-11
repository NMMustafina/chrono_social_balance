import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';

class WeekRatioCard extends StatelessWidget {
  final String weekLabel;
  final Duration total;
  final Duration inCompany;
  final Duration alone;
  final int changePercent;
  final String vsLabel;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;

  const WeekRatioCard({
    super.key,
    required this.weekLabel,
    required this.total,
    required this.inCompany,
    required this.alone,
    required this.changePercent,
    required this.vsLabel,
    this.onNext,
    this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    final percentCompany = total.inMinutes == 0
        ? 0
        : ((inCompany.inMinutes / total.inMinutes) * 100).round();
    final percentAlone = 100 - percentCompany;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ratio of time spent',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onPrev,
                child: Icon(
                  Icons.chevron_left,
                  size: 24,
                  color: onPrev == null ? Colors.grey : Colors.black,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                weekLabel,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4.w),
              GestureDetector(
                onTap: onNext,
                child: Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: onNext == null ? Colors.grey : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              CircularPercentIndicator(
                radius: 60.r,
                lineWidth: 14.w,
                percent: total.inMinutes == 0
                    ? 0
                    : inCompany.inMinutes / total.inMinutes,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDuration(total),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Total time',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF5BD3B1),
                progressColor: const Color(0xFFFF9900),
                circularStrokeCap: CircularStrokeCap.round,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statLine(
                      icon: 'assets/icons/friends.svg',
                      color: const Color(0xFFFF9900),
                      label: 'In company',
                      duration: inCompany,
                      percent: percentCompany,
                    ),
                    SizedBox(height: 4.h),
                    _statLine(
                      icon: 'assets/icons/user.svg',
                      color: const Color(0xFF5BD3B1),
                      label: 'Alone',
                      duration: alone,
                      percent: percentAlone,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/diagram.svg',
                            width: 20.w),
                        SizedBox(width: 6.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${changePercent >= 0 ? '+' : ''}$changePercent% activity',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              vsLabel,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statLine({
    required String icon,
    required Color color,
    required String label,
    required Duration duration,
    required int percent,
  }) {
    return Row(
      children: [
        Container(width: 2.w, height: 32.h, color: color),
        SizedBox(width: 8.w),
        SvgPicture.asset(icon, width: 20.w),
        SizedBox(width: 6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDuration(duration),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
            ),
            Text(
              '$label | $percent%',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        )
      ],
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
