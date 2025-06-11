import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

import '/widgets/month_picker_modal.dart';
import '../../models/entry_model.dart';
import 'monthly_friend_stats_view.dart';
import 'weekly_friend_stats_view.dart';

class FriendStatsScreen extends StatefulWidget {
  const FriendStatsScreen({super.key});

  @override
  State<FriendStatsScreen> createState() => _FriendStatsScreenState();
}

class _FriendStatsScreenState extends State<FriendStatsScreen> {
  int selectedTab = 0;
  int? selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now().month;
  }

  @override
  Widget build(BuildContext context) {
    final entryBox = GetIt.I.get<Box<EntryModel>>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xFFF0F0F0),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Friend statistics',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 28.sp,
          ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: entryBox.listenable(),
            builder: (context, Box<EntryModel> box, _) {
              final months = box.values.map((e) => e.date.month).toSet();
              final enabled = months.length > 1;
              return IconButton(
                onPressed: enabled
                    ? () {
                        final Map<int, Set<int>> yearToMonths = {};
                        for (final e in box.values) {
                          yearToMonths
                              .putIfAbsent(e.date.year, () => {})
                              .add(e.date.month);
                        }

                        showCupertinoMonthYearPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          yearToMonths: yearToMonths,
                          onSelected: (date) =>
                              setState(() => selectedMonth = date.month),
                        );
                      }
                    : null,
                icon: SvgPicture.asset(
                  'assets/icons/calendar.svg',
                  width: 32,
                  height: 32,
                  color: enabled ? Colors.black : Colors.black.withOpacity(0.3),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: _buildTabSection(),
          ),
          Expanded(
            child: selectedTab == 0
                ? WeeklyFriendStatsView(selectedMonth: selectedMonth)
                : MonthlyFriendStatsView(selectedMonth: selectedMonth),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      height: 48.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 0),
              child: Container(
                height: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedTab == 0
                      ? const Color(0xFF1284EF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  'Weekly',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: selectedTab == 0 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 1),
              child: Container(
                height: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedTab == 1
                      ? const Color(0xFF1284EF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  'Monthly',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: selectedTab == 1 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
