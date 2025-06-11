import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../models/friend_model.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key, this.friendModel});

  final FriendModel? friendModel;

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final mailController = TextEditingController();

  File? selectedImage;
  bool isValid = false;

  @override
  void initState() {
    super.initState();

    if (widget.friendModel != null) {
      nameController.text = widget.friendModel!.namee ?? '';
      phoneController.text = widget.friendModel!.phoneNum ?? '';
      mailController.text = widget.friendModel!.maill ?? '';

      if ((widget.friendModel!.photo ?? '').isNotEmpty &&
          File(widget.friendModel!.photo!).existsSync()) {
        selectedImage = File(widget.friendModel!.photo!);
      }
    }

    nameController.addListener(_validate);
    _validate();
  }

  void _validate() {
    setState(() {
      isValid = nameController.text.trim().isNotEmpty;
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    mailController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (nameController.text.isNotEmpty) {
      try {
        final frid = widget.friendModel?.id ?? DateTime.now().toIso8601String();
        final addFrr = FriendModel(
          id: frid,
          photo: selectedImage?.path ?? '',
          namee: nameController.text,
          phoneNum: phoneController.text,
          maill: mailController.text,
        );

        final box = GetIt.I.get<Box<FriendModel>>();
        await box.put(frid, addFrr);

        Navigator.pop(context, addFrr);
      } catch (e) {
        print('Error saving income: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          widget.friendModel != null ? 'Edit' : 'Add friend',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 28.sp,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a photo',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                  width: double.infinity,
                  height: 160.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  alignment: Alignment.center,
                  child: selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: Stack(
                            children: [
                              Image.file(
                                selectedImage!,
                                width: double.infinity,
                                height: 160.h,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 4.w,
                                top: 4.h,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedImage = null;
                                    });
                                  },
                                  child: SvgPicture.asset(
                                    'assets/icons/cross.svg',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SvgPicture.asset('assets/icons/upload.svg')),
            ),
            SizedBox(height: 16.h),
            _buildField('Full Name*', 'Enter a friend\'s name',
                controller: nameController),
            SizedBox(height: 12.h),
            _buildField('Phone Number', 'Your friend\'s phone number',
                controller: phoneController),
            SizedBox(height: 12.h),
            _buildField('Mail', 'Enter a friend\'s e-mail',
                controller: mailController),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: isValid
            ? () {
                _onSave();
              }
            : null,
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 56.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: isValid ? const Color(0xFF1284EF) : const Color(0xFF999999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.friendModel != null ? 'Done' : 'Save Friend',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.friendModel == null) SizedBox(width: 8.w),
              if (widget.friendModel == null)
                SvgPicture.asset(
                  'assets/icons/save.svg',
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint,
      {required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 4.h),
        TextField(
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black,
          ),
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: Color(0xFF999999),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(12.w),
          ),
        ),
      ],
    );
  }
}
