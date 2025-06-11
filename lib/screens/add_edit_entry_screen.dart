import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '/widgets/activity_selector.dart';
import '/widgets/description_field.dart';
import '/widgets/friend_selector.dart';
import '/widgets/photo_picker.dart';
import '/widgets/time_selector.dart';
import '../../models/activity_model.dart';
import '../../models/activity_type.dart';
import '../../models/entry_model.dart';
import '../../models/friend_model.dart';
import 'activity_picker_modal.dart';
import 'friend_picker_modal.dart';

class AddEditEntryScreen extends StatefulWidget {
  final EntryModel? entry;

  const AddEditEntryScreen({super.key, this.entry});

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  File? photo;
  DateTime? startTime;
  DateTime? endTime;
  ActivityModel? activity;
  List<FriendModel> selectedFriends = [];
  String? description;

  bool get isValid =>
      startTime != null && endTime != null && activity != null && isDirty;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      startTime = widget.entry!.start;
      endTime = widget.entry!.end;
      activity = widget.entry!.activity;
      description = widget.entry!.description;

      final path = widget.entry!.photoPath;
      if (path != null && path.isNotEmpty && File(path).existsSync()) {
        photo = File(path);
      }

      final friendBox = GetIt.I.get<Box<FriendModel>>();
      selectedFriends = widget.entry!.friendIds
          .map((id) => friendBox.get(id))
          .whereType<FriendModel>()
          .toList();
    }
  }

  void _onSave() async {
    if (!isValid) return;

    final newEntry = EntryModel(
      start: startTime!,
      end: endTime!,
      activity: activity!,
      friendIds: selectedFriends.map((f) => f.id).toList(),
      description: description,
      photoPath: photo?.path,
      date: DateTime(startTime!.year, startTime!.month, startTime!.day),
    );

    final box = GetIt.I.get<Box<EntryModel>>();

    if (widget.entry != null) {
      final key = box.keys.firstWhere((k) => box.get(k) == widget.entry);
      await box.put(key, newEntry);
    } else {
      final id = const Uuid().v4();
      await box.put(id, newEntry);
    }

    if (mounted) Navigator.pop(context);
  }

  void _openActivityPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ActivityPickerModal(
        onSelected: (selected) => setState(() {
          activity = selected;
          if (selected.type == ActivityType.solo) {
            selectedFriends.clear();
          }
        }),
      ),
    );
  }

  void _openFriendPicker() {
    if (activity?.type != ActivityType.group) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FriendPickerModal(
        initiallySelected: selectedFriends.map((f) => f.id).toList(),
        onSelected: (friends) => setState(() => selectedFriends = friends),
      ),
    );
  }

  bool get isDirty {
    final original = widget.entry;
    if (original == null) return true;

    final sameFriends = selectedFriends
            .map((f) => f.id)
            .toSet()
            .containsAll(original.friendIds) &&
        original.friendIds
            .toSet()
            .containsAll(selectedFriends.map((f) => f.id));

    return startTime != original.start ||
        endTime != original.end ||
        activity != original.activity ||
        description != original.description ||
        photo?.path != original.photoPath ||
        !sameFriends;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!isDirty) return true;

        final shouldLeave = await showCupertinoDialog<bool>(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('Leave the screen?'),
            content: const Text(
              'If you leave the screen, your entry will not be saved.',
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Leave'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );

        return shouldLeave ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF2F2F2),
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: Text(
            widget.entry != null ? 'Edit entry' : 'New entry',
            style: TextStyle(
              color: Colors.black,
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhotoPicker(
                    photo: photo,
                    onChanged: (file) => setState(() => photo = file)),
                SizedBox(height: 16.h),
                TimeSelector(
                  start: startTime,
                  end: endTime,
                  onStart: (val) => setState(() => startTime = val),
                  onEnd: (val) => setState(() => endTime = val),
                ),
                SizedBox(height: 16.h),
                ActivitySelector(
                    activity: activity, onTap: _openActivityPicker),
                SizedBox(height: 16.h),
                FriendSelector(
                    friends: selectedFriends,
                    type: activity?.type,
                    onTap: _openFriendPicker),
                SizedBox(height: 16.h),
                DescriptionField(
                    initial: description,
                    onChanged: (val) => setState(() => description = val)),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: GestureDetector(
          onTap: isValid ? _onSave : null,
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 56.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color:
                  isValid ? const Color(0xFF1284EF) : const Color(0xFF999999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.entry != null ? 'Done' : 'Save Entry',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.entry == null) SizedBox(width: 8.w),
                if (widget.entry == null)
                  SvgPicture.asset(
                    'assets/icons/save.svg',
                    color: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
