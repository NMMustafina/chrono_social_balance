import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnalyticsTabSwitcher extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onChanged;

  const AnalyticsTabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildTab('Weekly', 0)),
        Expanded(child: _buildTab('Monthly', 1)),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onChanged(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF1284EF) : Colors.black,
            ),
          ),
          SizedBox(height: 6.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 4.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1284EF) : Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }
}
