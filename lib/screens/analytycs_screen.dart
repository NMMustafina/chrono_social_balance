import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

import '/widgets/month_picker_modal.dart';
import '../../models/entry_model.dart';
import '../widgets/analytics_tab_switcher.dart';
import 'friend_stats_screen.dart';
import 'monthly_stats_view.dart';
import 'weekly_stats_view.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int selectedTab = 0;
  int? selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
  }

  @override
  Widget build(BuildContext context) {
    final entryBox = GetIt.I.get<Box<EntryModel>>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xFFF0F0F0),
        elevation: 0,
        title: Text(
          'Analytics',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 28.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendStatsScreen()),
              );
            },
            icon: SvgPicture.asset('assets/icons/user_heart.svg'),
          ),
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
                          onSelected: (date) => setState(() {
                            selectedMonth = date.month;
                          }),
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: AnalyticsTabSwitcher(
              selectedIndex: selectedTab,
              onChanged: (index) => setState(() => selectedTab = index),
            ),
          ),
          Expanded(
            child: selectedTab == 0
                ? WeeklyStatsView(selectedMonth: selectedMonth)
                : MonthlyStatsView(selectedMonth: selectedMonth),
          ),
        ],
      ),
    );
  }
}
