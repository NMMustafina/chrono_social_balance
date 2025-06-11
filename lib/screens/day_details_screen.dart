import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../models/activity_type.dart';
import '../../models/entry_model.dart';
import '../models/friend_model.dart';
import 'add_edit_entry_screen.dart';

class DayDetailsScreen extends StatefulWidget {
  final DateTime date;

  const DayDetailsScreen({super.key, required this.date});

  @override
  State<DayDetailsScreen> createState() => _DayDetailsScreenState();
}

class _DayDetailsScreenState extends State<DayDetailsScreen> {
  late Box<EntryModel> box;
  EntryModel? expanded;

  @override
  void initState() {
    super.initState();
    box = GetIt.I.get<Box<EntryModel>>();
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = box.values
        .where((e) =>
            DateTime(e.date.year, e.date.month, e.date.day) ==
            DateTime(widget.date.year, widget.date.month, widget.date.day))
        .toList();

    allEntries.sort((a, b) => b.start.compareTo(a.start));

    final total = allEntries.fold<Duration>(
        Duration.zero, (prev, e) => prev + e.end.difference(e.start));

    final inCompany = allEntries
        .where((e) => e.activity.type == ActivityType.group)
        .fold<Duration>(
            Duration.zero, (prev, e) => prev + e.end.difference(e.start));

    final percent = total.inMinutes == 0
        ? 0
        : (inCompany.inMinutes / total.inMinutes * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Day details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final confirm = await showCupertinoDialog<bool>(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  title: const Text('Delete this day?'),
                  content: const Text(
                    'You will irretrievably lose all of that day\'s information',
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final keys = box.keys
                    .where((k) => box.get(k)?.date.day == widget.date.day)
                    .toList();
                for (final key in keys) {
                  await box.delete(key);
                }
                if (mounted) Navigator.pop(context);
              }
            },
            icon: SvgPicture.asset(
              'assets/icons/trash.svg',
              width: 24.w,
              height: 24.w,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(total, percent, allEntries.length),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.separated(
                itemCount: allEntries.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final entry = allEntries[index];
                  final isExpanded = expanded == entry;
                  final isBlurred = expanded != null && !isExpanded;

                  return GestureDetector(
                    onTap: () =>
                        setState(() => expanded = isExpanded ? null : entry),
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        entry.activity.iconAsset,
                                        width: 20.w,
                                        height: 20.w,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        entry.activity.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 20.w,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddEditEntryScreen(
                                                entry: entry),
                                          ),
                                        ).then((_) =>
                                            setState(() => expanded = null));
                                      } else if (value == 'delete') {
                                        final confirm =
                                            await showCupertinoDialog<bool>(
                                          context: context,
                                          builder: (_) => CupertinoAlertDialog(
                                            title: const Text('Delete entry?'),
                                            content: const Text(
                                              'You will lose all information about the entry',
                                              textAlign: TextAlign.center,
                                            ),
                                            actions: [
                                              CupertinoDialogAction(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              CupertinoDialogAction(
                                                isDestructiveAction: true,
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          final key = box.keys.firstWhere(
                                              (k) => box.get(k) == entry);
                                          await box.delete(key);
                                          setState(() => expanded = null);
                                        }
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/pen.svg',
                                              width: 18.w,
                                              height: 18.w,
                                              color: Colors.black,
                                            ),
                                            SizedBox(width: 8.w),
                                            const Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuDivider(),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/trash.svg',
                                              width: 18.w,
                                              height: 18.w,
                                              color: Colors.black,
                                            ),
                                            SizedBox(width: 8.w),
                                            const Text('Delete'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    icon: SvgPicture.asset(
                                      'assets/icons/dots.svg',
                                      width: 36.w,
                                      height: 36.w,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              if (isExpanded) ...[
                                SizedBox(height: 12.h),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (entry.photoPath != null &&
                                        entry.photoPath!.isNotEmpty &&
                                        File(entry.photoPath!)
                                            .existsSync()) ...[
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        child: Image.file(
                                          File(entry.photoPath!),
                                          height: 100.h,
                                          width: 120.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/clock.svg',
                                                width: 16.w,
                                                height: 16.w,
                                                color: Colors.black,
                                              ),
                                              SizedBox(width: 6.w),
                                              Text(
                                                '${DateFormat.jm().format(entry.start)} – ${DateFormat.jm().format(entry.end)}',
                                                style:
                                                    TextStyle(fontSize: 13.sp),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6.h),
                                          if (entry.activity.type ==
                                                  ActivityType.group &&
                                              entry.friendIds.isNotEmpty)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/icons/user.svg',
                                                      width: 16.w,
                                                      height: 16.w,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(width: 6.w),
                                                    Text('In company with:',
                                                        style: TextStyle(
                                                            fontSize: 13.sp)),
                                                  ],
                                                ),
                                                SizedBox(height: 6.h),
                                                ...entry.friendIds.map((id) {
                                                  final friendBox = GetIt.I
                                                      .get<Box<FriendModel>>();
                                                  final FriendModel? friend =
                                                      friendBox.get(id);
                                                  if (friend == null)
                                                    return const SizedBox();

                                                  final hasPhoto =
                                                      friend.photo != null &&
                                                          friend.photo!
                                                              .isNotEmpty &&
                                                          File(friend.photo!)
                                                              .existsSync();

                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 4.h),
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 12.r,
                                                          backgroundColor:
                                                              Colors.white,
                                                          backgroundImage: hasPhoto
                                                              ? FileImage(File(
                                                                  friend
                                                                      .photo!))
                                                              : const AssetImage(
                                                                      'assets/images/no_photo.png')
                                                                  as ImageProvider,
                                                        ),
                                                        SizedBox(width: 6.w),
                                                        Text(friend.namee,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    13.sp)),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ],
                                            )
                                          else if (entry.activity.type ==
                                              ActivityType.group)
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/user.svg',
                                                  width: 16.w,
                                                  height: 16.w,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(width: 6.w),
                                                Text('In company',
                                                    style: TextStyle(
                                                        fontSize: 13.sp)),
                                              ],
                                            )
                                          else
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/user.svg',
                                                  width: 16.w,
                                                  height: 16.w,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(width: 6.w),
                                                Text('Alone',
                                                    style: TextStyle(
                                                        fontSize: 13.sp)),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (entry.description != null &&
                                    entry.description!.isNotEmpty) ...[
                                  SizedBox(height: 12.h),
                                  Text(
                                    entry.description!,
                                    style:
                                        TextStyle(fontSize: 13.sp, height: 1.4),
                                  ),
                                ],
                              ]
                            ],
                          ),
                        ),
                        if (isBlurred)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
                                child: Container(
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(Duration total, int percent, int count) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow('assets/icons/date.svg', 'Date',
              DateFormat('MMMM dd, yyyy').format(widget.date)),
          _divider(),
          _summaryRow(
              'assets/icons/clock.svg', 'Total Time', _formatDuration(total)),
          _divider(),
          _summaryRow(
            'assets/icons/user.svg',
            'More Time Spent',
            '$percent% - ${percent >= 50 ? 'In company' : 'Alone'}',
          ),
          _divider(),
          _summaryRow('assets/icons/entry.svg', 'Total Entries', '$count'),
        ],
      ),
    );
  }

  Widget _summaryRow(String iconPath, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20.w,
            height: 20.w,
            color: Colors.black,
          ),
          SizedBox(width: 12.w),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: SizedBox(
        width: double.infinity,
        height: 1,
        child: CustomPaint(
          painter: DashedLinePainter(),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0 && d.inMinutes.remainder(60) > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}min';
    } else if (d.inHours > 0) {
      return '${d.inHours}h';
    } else {
      return '${d.inMinutes}min';
    }
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final paint = Paint()
      ..color = const Color(0xFFD9D9D9)
      ..strokeWidth = 1;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
