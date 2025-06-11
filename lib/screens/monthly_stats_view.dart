import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

import '../../models/activity_type.dart';
import '../../models/entry_model.dart';
import '../widgets/activity_stats_block.dart';
import '../widgets/chart_legend.dart';
import '../widgets/empty_analytics_view.dart';
import '../widgets/monthly_activity_chart.dart';

class MonthlyStatsView extends StatelessWidget {
  final int? selectedMonth;

  const MonthlyStatsView({super.key, this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    final box = GetIt.I.get<Box<EntryModel>>();

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<EntryModel> box, _) {
        final all = box.values.toList();

        if (all.isEmpty || selectedMonth == null) {
          return const EmptyAnalyticsView();
        }

        final selectedYear = all
            .firstWhere(
              (e) => e.date.month == selectedMonth,
              orElse: () => all.first,
            )
            .date
            .year;

        final entries = all
            .where((e) =>
                e.date.month == selectedMonth && e.date.year == selectedYear)
            .toList();

        if (entries.isEmpty) return const EmptyAnalyticsView();

        final prevMonth = selectedMonth == 1 ? 12 : selectedMonth! - 1;
        final prevYear = selectedMonth == 1 ? selectedYear - 1 : selectedYear;

        final previousEntries = all
            .where((e) => e.date.month == prevMonth && e.date.year == prevYear)
            .toList();

        final prevGroupStats = <String, Duration>{};
        final prevSoloStats = <String, Duration>{};
        Duration prevInCompany = Duration.zero;
        Duration prevAlone = Duration.zero;

        for (final entry in previousEntries) {
          final duration = entry.end.difference(entry.start);
          final key = entry.activity.name;
          final isGroup = entry.activity.type == ActivityType.group;

          if (isGroup) {
            prevGroupStats.update(key, (prev) => prev + duration,
                ifAbsent: () => duration);
            prevInCompany += duration;
          } else {
            prevSoloStats.update(key, (prev) => prev + duration,
                ifAbsent: () => duration);
            prevAlone += duration;
          }
        }

        final groupStats = <String, _Agg>{};
        final soloStats = <String, _Agg>{};
        final dailyMap = <int, DailyActivity>{};

        for (final entry in entries) {
          final day = entry.date.day;
          final duration = entry.end.difference(entry.start);

          dailyMap.update(
            day,
            (prev) => DailyActivity(
              day: prev.day,
              inCompany: prev.inCompany +
                  (entry.activity.type == ActivityType.group
                      ? duration
                      : Duration.zero),
              alone: prev.alone +
                  (entry.activity.type == ActivityType.solo
                      ? duration
                      : Duration.zero),
            ),
            ifAbsent: () => DailyActivity(
              day: day,
              inCompany: entry.activity.type == ActivityType.group
                  ? duration
                  : Duration.zero,
              alone: entry.activity.type == ActivityType.solo
                  ? duration
                  : Duration.zero,
            ),
          );

          final key = entry.activity.name;
          final map = entry.activity.type == ActivityType.group
              ? groupStats
              : soloStats;

          map.update(
            key,
            (prev) => prev..duration += duration,
            ifAbsent: () => _Agg(
              name: entry.activity.name,
              icon: entry.activity.iconAsset,
              duration: duration,
            ),
          );
        }

        final daysInMonth = DateTime(selectedYear, selectedMonth! + 1, 0).day;

        for (int day = 1; day <= daysInMonth; day++) {
          dailyMap.putIfAbsent(
            day,
            () => DailyActivity(
              day: day,
              inCompany: Duration.zero,
              alone: Duration.zero,
            ),
          );
        }

        final dailyStats = dailyMap.values.toList()
          ..sort((a, b) => a.day.compareTo(b.day));

        final inCompany = dailyStats.fold<Duration>(
            Duration.zero, (sum, e) => sum + e.inCompany);
        final alone =
            dailyStats.fold<Duration>(Duration.zero, (sum, e) => sum + e.alone);
        final total = inCompany + alone;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  MonthlyActivityChart(
                    monthLabel: DateFormat.MMMM().format(
                      DateTime(selectedYear, selectedMonth!),
                    ),
                    data: dailyStats,
                    year: selectedYear,
                    month: selectedMonth!,
                  ),
                  ChartLegend(
                    total: total,
                    inCompany: inCompany,
                    alone: alone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (groupStats.isNotEmpty)
              ActivityStatsBlock(
                title: 'Time in the company',
                currentTotal: inCompany,
                prevTotal: prevInCompany,
                stats: groupStats.values
                    .map((e) => ActivityStatModel(
                          label: e.name,
                          iconAsset: e.icon,
                          duration: e.duration,
                          prevDuration: prevGroupStats[e.name],
                        ))
                    .toList(),
              ),
            if (soloStats.isNotEmpty)
              ActivityStatsBlock(
                title: 'Time alone',
                currentTotal: alone,
                prevTotal: prevAlone,
                stats: soloStats.values
                    .map((e) => ActivityStatModel(
                          label: e.name,
                          iconAsset: e.icon,
                          duration: e.duration,
                          prevDuration: prevSoloStats[e.name],
                        ))
                    .toList(),
              ),
          ],
        );
      },
    );
  }
}

class _Agg {
  final String name;
  final String icon;
  Duration duration;

  _Agg({required this.name, required this.icon, required this.duration});
}
