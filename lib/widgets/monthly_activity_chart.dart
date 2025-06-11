import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DailyActivity {
  final int day;
  final Duration inCompany;
  final Duration alone;

  DailyActivity({
    required this.day,
    required this.inCompany,
    required this.alone,
  });

  Duration get total => inCompany + alone;
}

class MonthlyActivityChart extends StatelessWidget {
  final String monthLabel;
  final int year;
  final int month;
  final List<DailyActivity> data;

  const MonthlyActivityChart({
    super.key,
    required this.monthLabel,
    required this.data,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final maxMinutes = data
        .map((e) => e.total.inMinutes)
        .fold<int>(0, (a, b) => a > b ? a : b);

    final bool showInHoursOnly = maxMinutes >= 300;

    final int horizontalLines = maxMinutes < 60
        ? 5
        : maxMinutes < 180
            ? 6
            : maxMinutes < 600
                ? 7
                : 8;

    final List<double> ySteps = List.generate(
        horizontalLines, (i) => maxMinutes * (i + 1) / horizontalLines);
    final List<double> intervals = ySteps.map((v) {
      if (showInHoursOnly) {
        return (v / 60).roundToDouble() * 60;
      } else {
        return (v / 10).roundToDouble() * 10;
      }
    }).toList();

    final interval = intervals[0];
    final maxY = intervals.last;

    final inCompanySpots = data
        .map((e) => FlSpot(
              e.day.toDouble() - 0.15,
              e.inCompany.inMinutes.toDouble(),
            ))
        .toList();

    final aloneSpots = data
        .map((e) => FlSpot(
              e.day.toDouble() + 0.15,
              e.alone.inMinutes.toDouble(),
            ))
        .toList();

    List<FlSpot> verticalize(List<FlSpot> spots) {
      final active = spots.where((s) => s.y > 0).toList();
      if (active.length == 1) {
        return [FlSpot(active.first.x, 0), active.first];
      }
      return spots;
    }

    final inCompanyLine = verticalize(inCompanySpots);
    final aloneLine = verticalize(aloneSpots);

    bool hasData(List<FlSpot> spots) {
      return spots.any((s) => s.y > 0);
    }

    return SizedBox(
      height: 240.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: daysInMonth * 20.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: 45.h, right: 12.w, left: 8.w, bottom: 0),
                child: LineChart(
                  LineChartData(
                    minX: 1,
                    maxX: daysInMonth.toDouble(),
                    minY: 0,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      horizontalInterval: interval,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (_) => FlLine(
                        color: Colors.grey.withOpacity(0.08),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: interval,
                          getTitlesWidget: (value, _) => Padding(
                            padding: EdgeInsets.only(right: 4.w),
                            child: Text(
                              _formatTimeLabel(value, showInHoursOnly),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          reservedSize: 40.w,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, _) {
                            final day = value.toInt();
                            return Text(
                              day.toString().padLeft(2, '0'),
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.black),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      if (hasData(inCompanySpots))
                        LineChartBarData(
                          spots: inCompanyLine,
                          isCurved: false,
                          color: const Color(0xFFFF9900),
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                        ),
                      if (hasData(aloneSpots))
                        LineChartBarData(
                          spots: aloneLine,
                          isCurved: false,
                          color: const Color(0xFF5BD3B1),
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    'Your activity for $monthLabel',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeLabel(double value, bool hoursOnly) {
    final int totalMinutes = value.round();
    final int hours = totalMinutes ~/ 60;
    final int minutes = (totalMinutes % 60 / 10).round() * 10;

    if (hoursOnly) return '${hours}h';
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}
