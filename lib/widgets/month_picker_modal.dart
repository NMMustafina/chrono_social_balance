import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

void showCupertinoMonthYearPicker({
  required BuildContext context,
  required Map<int, Set<int>> yearToMonths,
  required DateTime initialDate,
  required void Function(DateTime selected) onSelected,
}) {
  List<int> years = yearToMonths.keys.toList()..sort();
  int selectedYear = initialDate.year;
  int selectedMonth = initialDate.month;

  List<int> getMonthsForYear(int year) =>
      (yearToMonths[year]?.toList() ?? [])..sort();

  List<int> months = getMonthsForYear(selectedYear);

  int selectedMonthIndex = months.indexOf(selectedMonth);

  showCupertinoModalPopup(
    context: context,
    builder: (_) => Center(
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      Text(
                        'Select a month',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        height: 24.r,
                        width: 24.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.9),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 150.h,
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                  initialItem: selectedMonthIndex >= 0
                                      ? selectedMonthIndex
                                      : 0),
                              itemExtent: 32.h,
                              onSelectedItemChanged: (i) {
                                final newMonth = months[i];
                                final validYears = years
                                    .where((y) =>
                                        yearToMonths[y]!.contains(newMonth))
                                    .toList();
                                final updatedYear =
                                    validYears.contains(selectedYear)
                                        ? selectedYear
                                        : validYears.isNotEmpty
                                            ? validYears.first
                                            : selectedYear;

                                setState(() {
                                  selectedMonth = newMonth;
                                  selectedYear = updatedYear;
                                });
                              },
                              selectionOverlay: Container(),
                              children: months
                                  .map((m) => Center(
                                      child: Text(
                                          DateFormat.MMMM()
                                              .format(DateTime(0, m)),
                                          style: TextStyle(fontSize: 20.sp))))
                                  .toList(),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                  initialItem: years.indexOf(selectedYear)),
                              itemExtent: 32.h,
                              onSelectedItemChanged: (i) {
                                selectedYear = years[i];
                                months = getMonthsForYear(selectedYear);
                                selectedMonth = months.first;
                                setState(() {});
                              },
                              selectionOverlay: Container(),
                              children: years
                                  .map((y) => Center(
                                      child: Text('$y',
                                          style: TextStyle(fontSize: 20.sp))))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: (150.h - 32.h) / 2,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 32.h,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 1.2),
                            borderRadius: BorderRadius.circular(6.r),
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onSelected(DateTime(selectedYear, selectedMonth));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Select',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
