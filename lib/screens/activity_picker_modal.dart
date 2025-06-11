import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

import '../../models/activity_model.dart';
import '../../models/activity_type.dart';

class ActivityPickerModal extends StatefulWidget {
  final Function(ActivityModel) onSelected;

  const ActivityPickerModal({super.key, required this.onSelected});

  @override
  State<ActivityPickerModal> createState() => _ActivityPickerModalState();
}

class _ActivityPickerModalState extends State<ActivityPickerModal> {
  ActivityType selectedType = ActivityType.group;
  String? customActivity;
  bool showSave = false;
  ActivityModel? selectedActivity;
  final TextEditingController _controller = TextEditingController();
  ActivityModel? _customModel;
  List<ActivityModel> customActivities = [];
  bool infoShown = false;

  final groupActivities = [
    ActivityModel(
        name: 'Meeting with friends',
        iconAsset: 'assets/icons/friends.svg',
        type: ActivityType.group),
    ActivityModel(
        name: 'Time with family',
        iconAsset: 'assets/icons/home.svg',
        type: ActivityType.group),
    ActivityModel(
        name: 'Teamwork',
        iconAsset: 'assets/icons/teamwork.svg',
        type: ActivityType.group),
    ActivityModel(
        name: 'Romantic time',
        iconAsset: 'assets/icons/heart.svg',
        type: ActivityType.group),
    ActivityModel(
        name: 'Other',
        iconAsset: 'assets/icons/lightbulb.svg',
        type: ActivityType.group),
  ];

  final soloActivities = [
    ActivityModel(
        name: 'Resting alone',
        iconAsset: 'assets/icons/meditation.svg',
        type: ActivityType.solo),
    ActivityModel(
        name: 'Self-development',
        iconAsset: 'assets/icons/book.svg',
        type: ActivityType.solo),
    ActivityModel(
        name: 'Working alone',
        iconAsset: 'assets/icons/laptop.svg',
        type: ActivityType.solo),
    ActivityModel(
        name: 'Hobby',
        iconAsset: 'assets/icons/pallete.svg',
        type: ActivityType.solo),
    ActivityModel(
        name: 'Other',
        iconAsset: 'assets/icons/lightbulb.svg',
        type: ActivityType.solo),
  ];

  ActivityModel? _buildCustomActivity() {
    if (customActivity == null || customActivity!.trim().isEmpty) return null;
    return ActivityModel(
      name: customActivity!,
      iconAsset: 'assets/icons/act.svg',
      type: selectedType,
      isCustom: true,
    );
  }

  void _maybeShowInfoAlert() async {
    if (infoShown) return;
    final box = await Hive.openBox('settings');
    final shown = box.get('custom_activity_hint_shown', defaultValue: false);
    if (!shown) {
      infoShown = true;
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Saving activities'),
          content: const Text(
              'You can save the activity for future use by clicking the “Save” button. To delete your saved activity use a long press'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      await box.put('custom_activity_hint_shown', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activities = [
      ...customActivities.where((a) => a.type == selectedType),
      ...(selectedType == ActivityType.group
          ? groupActivities
          : soloActivities),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.only(bottom: 72.h),
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
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Text(
                              'Activity',
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
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                              child: _typeButton(
                                  'With company', ActivityType.group)),
                          SizedBox(width: 10.w),
                          Expanded(
                              child: _typeButton('Alone', ActivityType.solo)),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: SvgPicture.asset('assets/icons/divider_act.svg'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset('assets/icons/pen.svg',
                                  width: 20.w),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  maxLength: 30,
                                  decoration: InputDecoration(
                                    hintText: 'Add your own activity',
                                    counterText: '',
                                    hintStyle: TextStyle(
                                        fontSize: 14.sp, color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) {
                                    _maybeShowInfoAlert();
                                    setState(() {
                                      customActivity = val;
                                      showSave = val.trim().isNotEmpty;
                                      _customModel = _buildCustomActivity();
                                    });
                                  },
                                ),
                              ),
                              Text('${_controller.text.length}/30',
                                  style: TextStyle(
                                      fontSize: 14.sp, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      if (_customModel != null) ...[
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () {
                            if (_customModel == null) return;

                            setState(() {
                              final exists = customActivities
                                  .any((a) => a.name == _customModel!.name);
                              if (!exists) {
                                customActivities.add(_customModel!);
                              }
                              selectedActivity = _customModel!;
                              _controller.clear();
                              customActivity = null;
                              _customModel = null;
                              showSave = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 14.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1284EF),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final a = activities[index];
                      final isSelected = selectedActivity == a;

                      return GestureDetector(
                        onTap: () => setState(() => selectedActivity = a),
                        onLongPress: () {
                          if (a.isCustom) {
                            showCupertinoDialog(
                              context: context,
                              builder: (_) => CupertinoAlertDialog(
                                title: const Text('Delete category?'),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('Cancel'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    child: const Text('Delete'),
                                    onPressed: () {
                                      setState(
                                          () => customActivities.remove(a));
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(a.iconAsset,
                                  width: 24.w, height: 24.w),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  a.name,
                                  style: TextStyle(fontSize: 15.sp),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? const Color(0xFF1284EF)
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              minimum: EdgeInsets.all(16.w),
              child: ElevatedButton(
                onPressed: selectedActivity == null
                    ? null
                    : () {
                        widget.onSelected(selectedActivity!);
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1284EF),
                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  'Select',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: selectedActivity == null
                        ? Colors.grey[200]
                        : Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _typeButton(String text, ActivityType type) {
    final isActive = selectedType == type;

    return GestureDetector(
      onTap: () => setState(() {
        selectedType = type;
        selectedActivity = null;
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1284EF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFF1284EF)),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }
}
