import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

import '/widgets/empty_state.dart';
import '/widgets/month_picker_modal.dart';
import '/widgets/past_day_card.dart';
import '/widgets/today_card.dart';
import '../../models/activity_type.dart';
import '../../models/entry_model.dart';
import 'add_edit_entry_screen.dart';
import 'day_details_screen.dart';

class TimeTrScreen extends StatefulWidget {
  const TimeTrScreen({super.key});

  @override
  State<TimeTrScreen> createState() => _TimeTrScreenState();
}

class _TimeTrScreenState extends State<TimeTrScreen> {
  int? selectedMonth;

  @override
  Widget build(BuildContext context) {
    final box = GetIt.I.get<Box<EntryModel>>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xFFF0F0F0),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Time Tracker',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 28.sp,
          ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<EntryModel> box, _) {
              final months = box.values.map((e) => e.date.month).toSet();
              final enabled = months.length > 1;
              return IconButton(
                  onPressed: enabled
                      ? () {
                          final entries = box.values;
                          final Map<int, Set<int>> yearToMonths = {};
                          for (final e in entries) {
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
                  icon: SvgPicture.asset('assets/icons/calendar.svg',
                      width: 32,
                      height: 32,
                      color: enabled
                          ? Colors.black
                          : Colors.black.withOpacity(0.3)));
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<EntryModel> box, _) {
          final entries = box.values
              .where(
                  (e) => selectedMonth == null || e.date.month == selectedMonth)
              .toList();

          if (entries.isEmpty) {
            return EmptyState(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditEntryScreen()),
              );
            });
          }

          final grouped = <String, List<EntryModel>>{};
          for (var entry in entries) {
            final key = DateFormat('yyyy-MM-dd').format(entry.date);
            grouped.putIfAbsent(key, () => []).add(entry);
          }

          final dates = grouped.keys.toList()
            ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

          final today = DateTime.now();
          final hasToday = grouped.keys.any((k) {
            final d = DateTime.parse(k);
            return d.year == today.year &&
                d.month == today.month &&
                d.day == today.day;
          });

          return Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.all(16.w)
                    .copyWith(bottom: hasToday ? 16.h : 96.h),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = DateTime.parse(dates[index]);
                  final dayEntries = grouped[dates[index]]!;
                  final isToday = date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;

                  final inCompany = dayEntries
                      .where((e) => e.activity.type == ActivityType.group)
                      .fold<Duration>(Duration.zero,
                          (prev, e) => prev + e.end.difference(e.start));
                  final alone = dayEntries
                      .where((e) => e.activity.type == ActivityType.solo)
                      .fold<Duration>(Duration.zero,
                          (prev, e) => prev + e.end.difference(e.start));
                  final total = inCompany + alone;
                  final percentCompany = total.inMinutes > 0
                      ? (inCompany.inMinutes / total.inMinutes * 100).round()
                      : 0;

                  if (isToday) {
                    final sortedEntries = [...dayEntries]
                      ..sort((a, b) => b.start.compareTo(a.start));
                    final isOnlyToday = dates.length == 1;

                    return Column(
                      children: [
                        TodayCard(
                          total: total,
                          count: dayEntries.length,
                          last: sortedEntries.first.activity.name,
                          type: sortedEntries.first.activity.type,
                          lastActivity: sortedEntries.first.activity,
                          percent: percentCompany,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DayDetailsScreen(date: date)),
                            );
                          },
                          onAdd: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddEditEntryScreen()),
                            );
                          },
                        ),
                        if (!isOnlyToday)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: SvgPicture.asset(
                                'assets/icons/divider_time.svg'),
                          ),
                      ],
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: PastDayCard(
                      title: _formatDateTitle(date),
                      duration: _formatDuration(total),
                      count: dayEntries.length,
                      percent: percentCompany,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DayDetailsScreen(date: date)),
                        );
                      },
                    ),
                  );
                },
              ),
              if (!hasToday)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    minimum: EdgeInsets.all(16.w),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddEditEntryScreen()),
                        );
                      },
                      child: Container(
                        height: 56.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          color: const Color(0xFF1284EF),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Start Tracking',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            SvgPicture.asset('assets/icons/add.svg'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0 && d.inMinutes.remainder(60) > 0) {
      return '${d.inHours} Hrs ${d.inMinutes.remainder(60)} min';
    } else if (d.inHours > 0) {
      return '${d.inHours} Hrs';
    } else {
      return '${d.inMinutes} min';
    }
  }

  String _formatDateTitle(DateTime d) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    if (d.year == today.year && d.month == today.month && d.day == today.day)
      return 'Today';
    if (d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day)
      return 'Yesterday, ${DateFormat.MMMM().format(d)} ${d.day.toString().padLeft(2, '0')}';
    return DateFormat('MMMM dd, yyyy').format(d);
  }
}
