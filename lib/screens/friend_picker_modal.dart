import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../models/friend_model.dart';

class FriendPickerModal extends StatefulWidget {
  final List<String> initiallySelected;
  final void Function(List<FriendModel>) onSelected;

  const FriendPickerModal({
    super.key,
    required this.initiallySelected,
    required this.onSelected,
  });

  @override
  State<FriendPickerModal> createState() => _FriendPickerModalState();
}

class _FriendPickerModalState extends State<FriendPickerModal> {
  late List<String> selectedIds;

  @override
  void initState() {
    super.initState();
    selectedIds = [...widget.initiallySelected];
  }

  @override
  Widget build(BuildContext context) {
    final box = GetIt.I.get<Box<FriendModel>>();
    final friends = box.values.toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'Friends',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: friends.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'You don’t have any added friends yet :(',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Add them by going to the “Friends” section',
                            style:
                                TextStyle(fontSize: 14.sp, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        final isSelected = selectedIds.contains(friend.id);
                        final hasPhoto = friend.photo != null &&
                            friend.photo!.isNotEmpty &&
                            File(friend.photo!).existsSync();

                        return Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20.r,
                                backgroundColor: Colors.white,
                                backgroundImage: hasPhoto
                                    ? FileImage(File(friend.photo!))
                                    : const AssetImage(
                                            'assets/images/no_photo.png')
                                        as ImageProvider,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(friend.namee,
                                    style: TextStyle(fontSize: 15.sp)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelected
                                        ? selectedIds.remove(friend.id)
                                        : selectedIds.add(friend.id);
                                  });
                                },
                                child: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? const Color(0xFF1284EF)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: ElevatedButton(
                onPressed: selectedIds.isEmpty
                    ? null
                    : () {
                        final selected = friends
                            .where((f) => selectedIds.contains(f.id))
                            .toList();
                        widget.onSelected(selected);
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedIds.isEmpty
                      ? const Color(0xFF999999)
                      : const Color(0xFF1284EF),
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Select',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color:
                        selectedIds.isEmpty ? Colors.grey[200] : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
