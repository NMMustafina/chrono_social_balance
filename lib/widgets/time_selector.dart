import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class TimeSelector extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;
  final Function(DateTime) onStart;
  final Function(DateTime) onEnd;

  const TimeSelector({
    super.key,
    this.start,
    this.end,
    required this.onStart,
    required this.onEnd,
  });

  void _showPicker(BuildContext context, bool isStart) {
    DateTime picked = (isStart ? start : end) ?? DateTime.now();

    showCupertinoDialog(
      context: context,
      builder: (_) => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            height: 360.h,
            padding: EdgeInsets.only(top: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Pick a time',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, size: 20.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: picked,
                      use24hFormat: false,
                      onDateTimeChanged: (val) => picked = val,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: GestureDetector(
                    onTap: () {
                      if (isStart && end != null && picked.isAfter(end!)) {
                        Navigator.pop(context);
                        _showError(context);
                        return;
                      }
                      if (!isStart &&
                          start != null &&
                          picked.isBefore(start!)) {
                        Navigator.pop(context);
                        _showError(context);
                        return;
                      }
                      Navigator.pop(context);
                      isStart ? onStart(picked) : onEnd(picked);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Select',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Invalid time'),
        content: const Text('Start time must be before end time.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tile(context, 'Starting Time', start, true),
        SizedBox(height: 12.h),
        _tile(context, 'End Time', end, false),
      ],
    );
  }

  Widget _tile(
      BuildContext context, String label, DateTime? value, bool isStart) {
    final formatter = DateFormat.jm();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.circle,
              size: 6,
              color: Color(0xFF1284EF),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => _showPicker(context, isStart),
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
                      'assets/icons/clock.svg',
                      width: 16.w,
                      height: 16.w,
                      color: value != null
                          ? Colors.black
                          : const Color(0xFF999999),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      value != null ? formatter.format(value) : 'Select time',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: value != null
                            ? Colors.black
                            : const Color(0xFF999999),
                      ),
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
