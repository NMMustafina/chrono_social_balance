import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/activity_type.dart';
import '../../models/friend_model.dart';

class FriendSelector extends StatelessWidget {
  final List<FriendModel> friends;
  final ActivityType? type;
  final VoidCallback onTap;

  const FriendSelector({
    super.key,
    required this.friends,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = type == ActivityType.solo;
    final isEmpty = friends.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Friend',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 6.h),
        if (!isEmpty)
          Column(
            children: friends.map((friend) {
              final hasPhoto = friend.photo != null &&
                  friend.photo!.isNotEmpty &&
                  File(friend.photo!).existsSync();

              return GestureDetector(
                onTap: onTap,
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          image: hasPhoto
                              ? DecorationImage(
                                  image: FileImage(File(friend.photo!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !hasPhoto
                            ? ClipOval(
                                child: Image.asset(
                                  'assets/images/no_photo.png',
                                  fit: BoxFit.contain,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          friend.namee,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        else
          GestureDetector(
            onTap: isBlocked ? null : onTap,
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: isBlocked ? const Color(0xFFE0E0E0) : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/user.svg',
                        width: 16.w,
                        height: 16.w,
                        color:
                            isBlocked ? const Color(0xFF999999) : Colors.grey,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        isBlocked
                            ? 'Not applicable for solo'
                            : 'Who did you spend time with?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color:
                              isBlocked ? const Color(0xFF999999) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16.sp),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
