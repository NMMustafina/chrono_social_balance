import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

import '../../models/activity_type.dart';
import '../../models/entry_model.dart';
import '../widgets/activity_stats_block.dart';
import '../widgets/empty_analytics_view.dart';
import '../widgets/week_ratio_card.dart';

class WeeklyStatsView extends StatefulWidget {
  final int? selectedMonth;

  const WeeklyStatsView({super.key, this.selectedMonth});

  @override
  State<WeeklyStatsView> createState() => _WeeklyStatsViewState();
}

class _WeeklyStatsViewState extends State<WeeklyStatsView> {
  int selectedWeekIndex = 0;

  @override
  void didUpdateWidget(covariant WeeklyStatsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMonth != oldWidget.selectedMonth) {
      setState(() => selectedWeekIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = GetIt.I.get<Box<EntryModel>>();

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<EntryModel> box, _) {
        final entries = box.values.where((e) {
          return widget.selectedMonth == null ||
              e.date.month == widget.selectedMonth;
        }).toList();

        final chunks = _groupByWeeks(entries);

        if (chunks.isEmpty || selectedWeekIndex >= chunks.length) {
          return const EmptyAnalyticsView();
        }

        final week = chunks[selectedWeekIndex];
        final previousWeek =
            selectedWeekIndex > 0 ? chunks[selectedWeekIndex - 1] : null;

        final inCompany = _sumDuration(
          week.where((e) => e.activity.type == ActivityType.group),
        );
        final alone = _sumDuration(
          week.where((e) => e.activity.type == ActivityType.solo),
        );
        final total = inCompany + alone;

        final previousTotal =
            previousWeek == null ? Duration.zero : _sumDuration(previousWeek);

        final delta = total.inMinutes - previousTotal.inMinutes;
        final deltaPercent = previousTotal.inMinutes == 0
            ? 0
            : (delta / previousTotal.inMinutes * 100).clamp(-100, 100).round();

        bool _showPartialLabel(List<EntryModel> week) {
          final isLast = selectedWeekIndex == chunks.length - 1;
          final isPartial = _isPartial(week);
          return isLast && isPartial && chunks.length >= 5;
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            WeekRatioCard(
              weekLabel:
                  'Week ${selectedWeekIndex + 1}${_showPartialLabel(week) ? ' (Partial)' : ''}',
              total: total,
              inCompany: inCompany,
              alone: alone,
              changePercent: deltaPercent,
              vsLabel:
                  selectedWeekIndex == 0 ? 'Vs current week' : 'Vs last week',
              onPrev: selectedWeekIndex > 0
                  ? () => setState(() => selectedWeekIndex--)
                  : null,
              onNext: selectedWeekIndex < chunks.length - 1
                  ? () => setState(() => selectedWeekIndex++)
                  : null,
            ),
            const SizedBox(height: 16),
            ..._buildActivityBlocks(week),
          ],
        );
      },
    );
  }

  Duration _sumDuration(Iterable<EntryModel> entries) {
    return entries.fold(Duration.zero, (d, e) => d + e.end.difference(e.start));
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

  bool _isPartial(List<EntryModel> week) {
    final dates = week.map((e) => e.date.day).toSet();
    return dates.length < 7;
  }

  List<Widget> _buildActivityBlocks(List<EntryModel> week) {
    final groupStats = <String, _Agg>{};
    final soloStats = <String, _Agg>{};

    for (final entry in week) {
      final key = entry.activity.name;
      final map =
          entry.activity.type == ActivityType.group ? groupStats : soloStats;

      map.update(
        key,
        (prev) => prev..duration += entry.end.difference(entry.start),
        ifAbsent: () => _Agg(
          name: entry.activity.name,
          icon: entry.activity.iconAsset,
          duration: entry.end.difference(entry.start),
        ),
      );
    }

    return [
      if (groupStats.isNotEmpty)
        ActivityStatsBlock(
          title: 'Time in the company',
          currentTotal: groupStats.values
              .fold(Duration.zero, (sum, a) => sum + a.duration),
          stats: groupStats.values
              .map((e) => ActivityStatModel(
                    label: e.name,
                    iconAsset: e.icon,
                    duration: e.duration,
                  ))
              .toList(),
        ),
      if (soloStats.isNotEmpty)
        ActivityStatsBlock(
          title: 'Time alone',
          currentTotal: soloStats.values
              .fold(Duration.zero, (sum, a) => sum + a.duration),
          stats: soloStats.values
              .map((e) => ActivityStatModel(
                    label: e.name,
                    iconAsset: e.icon,
                    duration: e.duration,
                  ))
              .toList(),
        ),
    ];
  }
}

class _Agg {
  final String name;
  final String icon;
  Duration duration;

  _Agg({required this.name, required this.icon, required this.duration});
}
