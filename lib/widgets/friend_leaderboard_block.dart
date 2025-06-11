import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FriendStat {
  final String name;
  final Duration duration;
  final String? photo;
  final DateTime? lastMeeting;

  FriendStat({
    required this.name,
    required this.duration,
    this.photo,
    this.lastMeeting,
  });
}

class FriendLeaderboardBlock extends StatelessWidget {
  final List<FriendStat> friends;

  const FriendLeaderboardBlock({super.key, required this.friends});

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) return const SizedBox();

    final sorted = [...friends]
      ..sort((a, b) => b.duration.compareTo(a.duration));
    final first = sorted.length > 0 ? sorted[0] : null;
    final second = sorted.length > 1 ? sorted[1] : null;
    final third = sorted.length > 2 ? sorted[2] : null;
    final rest = sorted.length > 3 ? sorted.sublist(3) : [];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Friend leaderboard',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: second != null
                    ? _buildPlaceWithIcon(
                        second,
                        'assets/icons/cup_second.svg',
                        80.w,
                        40.h,
                        Colors.grey,
                        1,
                      )
                    : const SizedBox(),
              ),
              Expanded(
                child: first != null
                    ? _buildPlaceWithIcon(
                        first,
                        'assets/icons/cup_first.svg',
                        100.w,
                        50.h,
                        const Color(0xFFFFD700),
                        2,
                      )
                    : const SizedBox(),
              ),
              Expanded(
                child: third != null
                    ? _buildPlaceWithIcon(
                        third,
                        'assets/icons/cup_third.svg',
                        80.w,
                        40.h,
                        const Color(0xFFB07A3D),
                        1,
                      )
                    : const SizedBox(),
              ),
            ],
          ),
          if (rest.isNotEmpty) ...[
            SizedBox(height: 16.h),
            ...rest.map((f) => _buildFriendRow(f)).toList(),
          ]
        ],
      ),
    );
  }

  Widget _buildPlaceWithIcon(
    FriendStat friend,
    String icon,
    double photoSize,
    double iconSize,
    Color borderColor,
    int maxLines,
  ) {
    final hasPhoto = friend.photo != null && File(friend.photo!).existsSync();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SvgPicture.asset(icon, height: iconSize, width: iconSize),
        SizedBox(height: 8.h),
        Container(
          width: photoSize,
          height: photoSize,
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: hasPhoto
                ? Image.file(File(friend.photo!), fit: BoxFit.cover)
                : Image.asset('assets/images/no_photo.png', fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          _shorten(friend.name, maxLines),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 2.h),
        Text(
          _formatDuration(friend.duration),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildFriendRow(FriendStat f) {
    final hasPhoto = f.photo != null && File(f.photo!).existsSync();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: hasPhoto
                ? Image.file(File(f.photo!),
                    width: 40.w, height: 40.w, fit: BoxFit.cover)
                : Image.asset('assets/images/no_photo.png',
                    width: 40.w, height: 40.w, fit: BoxFit.cover),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        f.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _formatDuration(f.duration),
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  f.lastMeeting != null
                      ? 'Last meeting: ${_formatDate(f.lastMeeting!)}'
                      : 'Last meeting: —',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shorten(String name, int maxLines) {
    final parts = name.trim().split(' ');
    if (maxLines == 1) return parts.first;
    if (parts.length >= 2) return '${parts[0]} ${parts[1]}';
    return name;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = months[date.month - 1];
    final day = _two(date.day);
    return '$month $day, ${date.year}';
  }

  String _two(int x) => x.toString().padLeft(2, '0');
}
