import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActivityStatModel {
  final String label;
  final String iconAsset;
  final Duration duration;
  final Duration? prevDuration;

  ActivityStatModel({
    required this.label,
    required this.iconAsset,
    required this.duration,
    this.prevDuration,
  });
}

class ActivityStatsBlock extends StatelessWidget {
  final String title;
  final List<ActivityStatModel> stats;
  final Duration? prevTotal;
  final Duration currentTotal;

  const ActivityStatsBlock({
    super.key,
    required this.title,
    required this.stats,
    this.prevTotal,
    required this.currentTotal,
  });

  @override
  Widget build(BuildContext context) {
    final deltaText = _buildDeltaText(currentTotal, prevTotal);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
          if (deltaText != null)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                deltaText,
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          SizedBox(height: 12.h),
          ...List.generate(stats.length, (i) {
            final s = stats[i];
            final isLast = i == stats.length - 1;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    children: [
                      SvgPicture.asset(s.iconAsset, width: 20.w),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          s.label,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                      Text(
                        _formatDuration(s.duration),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    height: 1,
                    color: const Color(0xFFE0E0E0),
                    margin: EdgeInsets.only(top: 2.h),
                  ),
              ],
            );
          })
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String? _buildDeltaText(Duration current, Duration? previous) {
    if (previous == null || previous.inMinutes == 0) return null;
    final prevMin = previous.inMinutes;
    final currMin = current.inMinutes;
    final diff = currMin - prevMin;
    final percent = (diff / prevMin * 100);
    final rounded = percent.toStringAsFixed(1);
    final sign = percent > 0 ? '+' : '';
    return '$sign$rounded% vs last month';
  }
}
