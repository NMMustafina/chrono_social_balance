import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

import '../models/friend_model.dart';
import 'add_friend_screen.dart';

class FriendDetailScreen extends StatelessWidget {
  const FriendDetailScreen({super.key, required this.friendModel});
  final FriendModel friendModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: ValueListenableBuilder(
          valueListenable: GetIt.I.get<Box<FriendModel>>().listenable(),
          builder: (context, Box<FriendModel> box, _) {
            final friend = box.get(friendModel.id);

            if (friend == null) {
              return const Center(child: Text('Friend not found'));
            }

            final hasPhoto = friend.photo != null &&
                friend.photo!.isNotEmpty &&
                File(friend.photo!).existsSync();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: const Color(0xFFF2F2F2),
                  elevation: 0,
                  pinned: true,
                  centerTitle: true,
                  leading: const BackButton(color: Colors.black),
                  title: Text(
                    'My friend',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  actions: [
                    GestureDetector(
                      onTap: () => _showOptions(context),
                      child: SvgPicture.asset('assets/icons/dots.svg'),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: hasPhoto
                              ? Image.file(
                                  File(friend.photo!),
                                  width: double.infinity,
                                  height: 180.h,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/no_photo.png',
                                  width: double.infinity,
                                  height: 180.h,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              friend.namee ?? 'No name',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20.sp,
                                color: Colors.black,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  friend.phoneNum ?? '',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  friend.maill ?? '',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: _buildDateSection(
                        'September ${10 - index}, 2024',
                        photo: 'assets/images/no_photo.png',
                        title: 'Meeting with friends',
                        time: '06:00 PM – 09:00 PM',
                        alsoWith: 'Alex Wiff.',
                      ),
                    );
                  },
                )
              ],
            );
          }),
    );
  }

  Widget _buildDateSection(
    String date, {
    String? photo,
    required String title,
    required String time,
    String? alsoWith,
    String? alsoWithAvatar,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(
                date,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Image.asset(
                        photo,
                        width: 127.w,
                        height: 100.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset('assets/icons/teamwork.svg'),
                            SizedBox(width: 4.w),
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            SvgPicture.asset('assets/icons/time.svg'),
                            SizedBox(width: 4.w),
                            Text(time),
                          ],
                        ),
                        if (alsoWith != null) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              SvgPicture.asset('assets/icons/user.svg'),
                              SizedBox(width: 4.w),
                              Text('Also with:'),
                            ],
                          ),
                          Row(
                            children: [
                              if (alsoWithAvatar != null)
                                Padding(
                                  padding: EdgeInsets.only(right: 4.w),
                                  child: CircleAvatar(
                                    radius: 12.r,
                                    backgroundImage: AssetImage(
                                        'assets/images/no_photo.png'),
                                  ),
                                ),
                              Text(
                                alsoWith,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddFriendScreen(friendModel: friendModel),
                ),
              );
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: Color(0xFF007AFF)),
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              showCupertinoDialog(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  title: const Text('Delete friend?'),
                  content: const Text(
                    "You will lose your friend's information\nand they will be removed from all entries",
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () async {
                        Navigator.pop(context);
                        await GetIt.I
                            .get<Box<FriendModel>>()
                            .delete(friendModel.id);
                        Navigator.pop(context);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF007AFF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
