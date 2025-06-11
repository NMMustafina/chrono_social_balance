import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../models/entry_model.dart';
import '../../models/friend_model.dart';
import '../widgets/empty_friend_stats_view.dart';
import '../widgets/friend_leaderboard_block.dart';
import '../widgets/friend_reminder_block.dart';
import '../widgets/friend_stats_summary_block.dart';

class MonthlyFriendStatsView extends StatelessWidget {
  final int? selectedMonth;

  const MonthlyFriendStatsView({super.key, this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    final entryBox = GetIt.I.get<Box<EntryModel>>();
    final friendBox = GetIt.I.get<Box<FriendModel>>();

    if (entryBox.values.isEmpty) return const EmptyFriendStatsView();

    final now = DateTime.now();
    final month = selectedMonth ?? now.month;
    final selectedYear = entryBox.values
        .where((e) => e.date.month == month)
        .map((e) => e.date.year)
        .fold(now.year, (prev, curr) => curr);

    final entries = entryBox.values.where((e) {
      final inMonth = e.date.month == month && e.date.year == selectedYear;
      final hasFriends = e.friendIds.isNotEmpty;
      return inMonth && hasFriends;
    }).toList();

    if (entries.isEmpty) return const EmptyFriendStatsView();

    final friendStats = _calculateFriendStats(entries, friendBox);
    if (friendStats.isEmpty) return const EmptyFriendStatsView();

    final total = friendStats.fold<Duration>(
      Duration.zero,
      (sum, f) => sum + f.duration,
    );
    final meetings = entries.length;
    final average = meetings > 0 ? total ~/ meetings : Duration.zero;

    final reminderCandidate = friendStats
        .where((f) => f.lastMeeting != null)
        .reduce((a, b) => a.lastMeeting!.isBefore(b.lastMeeting!) ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FriendLeaderboardBlock(friends: friendStats),
        SizedBox(height: 16.h),
        FriendStatsSummaryBlock(
          total: total,
          meetings: meetings,
          average: average,
        ),
        SizedBox(height: 16.h),
        FriendReminderBlock(
          name: reminderCandidate.name,
          lastDate: reminderCandidate.lastMeeting!,
        ),
      ],
    );
  }

  List<FriendStat> _calculateFriendStats(
      List<EntryModel> entries, Box<FriendModel> friendBox) {
    final Map<String, Duration> durations = {};
    final Map<String, DateTime> lastDates = {};

    for (final entry in entries) {
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
