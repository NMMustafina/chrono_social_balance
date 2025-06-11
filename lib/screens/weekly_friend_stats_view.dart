import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../models/entry_model.dart';
import '../../models/friend_model.dart';
import '../widgets/empty_friend_stats_view.dart';
import '../widgets/friend_leaderboard_block.dart';
import '../widgets/friend_stats_summary_block.dart';
import '../widgets/week_switcher.dart';

class WeeklyFriendStatsView extends StatefulWidget {
  final int? selectedMonth;

  const WeeklyFriendStatsView({super.key, this.selectedMonth});

  @override
  State<WeeklyFriendStatsView> createState() => _WeeklyFriendStatsViewState();
}

class _WeeklyFriendStatsViewState extends State<WeeklyFriendStatsView> {
  int selectedWeekIndex = 0;

  @override
  void didUpdateWidget(covariant WeeklyFriendStatsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMonth != oldWidget.selectedMonth) {
      setState(() => selectedWeekIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryBox = GetIt.I.get<Box<EntryModel>>();
    final friendBox = GetIt.I.get<Box<FriendModel>>();

    if (entryBox.values.isEmpty) return const EmptyFriendStatsView();

    final now = DateTime.now();
    final month = widget.selectedMonth ?? now.month;
    final selectedYear = entryBox.values
        .where((e) => e.date.month == month)
        .map((e) => e.date.year)
        .fold(now.year, (prev, curr) => curr);

    final entries = entryBox.values.where((e) {
      final inMonth = e.date.month == month && e.date.year == selectedYear;
      final hasFriends = e.friendIds.isNotEmpty;
      return inMonth && hasFriends;
    }).toList();

    final chunks = _groupByWeeks(entries);
    if (chunks.isEmpty || selectedWeekIndex >= chunks.length) {
      return const EmptyFriendStatsView();
    }

    final week = chunks[selectedWeekIndex];
    final friendStats = _calculateFriendStats(week, friendBox);
    if (friendStats.isEmpty) return const EmptyFriendStatsView();

    final total = friendStats.fold<Duration>(
      Duration.zero,
      (sum, f) => sum + f.duration,
    );
    final meetings = week.length;
    final average = meetings > 0 ? total ~/ meetings : Duration.zero;

    return Column(
      children: [
        WeekSwitcher(
          currentWeek: selectedWeekIndex + 1,
          totalWeeks: chunks.length,
          onPrev: selectedWeekIndex > 0
              ? () => setState(() => selectedWeekIndex--)
              : null,
          onNext: selectedWeekIndex < chunks.length - 1
              ? () => setState(() => selectedWeekIndex++)
              : null,
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            children: [
              FriendLeaderboardBlock(friends: friendStats),
              SizedBox(height: 16.h),
              FriendStatsSummaryBlock(
                total: total,
                meetings: meetings,
                average: average,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<List<EntryModel>> _groupByWeeks(List<EntryModel> entries) {
    final grouped = <List<EntryModel>>[];
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    if (sorted.isEmpty) return grouped;

    DateTime start = _startOfWeek(sorted.first.date);
    List<EntryModel> currentWeek = [];

    for (final entry in sorted) {
      final weekStart = _startOfWeek(entry.date);
      if (weekStart != start) {
        grouped.add(currentWeek);
        currentWeek = [];
        start = weekStart;
      }
      currentWeek.add(entry);
    }

    if (currentWeek.isNotEmpty) grouped.add(currentWeek);
    return grouped;
  }

  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  List<FriendStat> _calculateFriendStats(
      List<EntryModel> week, Box<FriendModel> friendBox) {
    final Map<String, Duration> durations = {};
    final Map<String, DateTime> lastDates = {};

    for (final entry in week) {
      final duration = entry.end.difference(entry.start);
      for (final id in entry.friendIds) {
        durations.update(id, (d) => d + duration, ifAbsent: () => duration);
        final lastDate = lastDates[id];
        if (lastDate == null || entry.date.isAfter(lastDate)) {
          lastDates[id] = entry.date;
        }
      }
    }

    return durations.entries
        .map((entry) {
          final id = entry.key;
          final friend = friendBox.get(id);
          if (friend == null) return null;

          return FriendStat(
            name: friend.namee,
            duration: entry.value,
            photo: friend.photo,
            lastMeeting: lastDates[id],
          );
        })
        .whereType<FriendStat>()
        .toList()
      ..sort((a, b) => b.duration.compareTo(a.duration));
  }
}
