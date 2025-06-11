import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPicker extends StatelessWidget {
  final File? photo;
  final Function(File?) onChanged;

  const PhotoPicker({
    super.key,
    required this.photo,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) onChanged(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          onTap: () => _pick(context),
          child: Container(
            width: double.infinity,
            height: 160.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            alignment: Alignment.center,
            child: photo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Stack(
                      children: [
                        Image.file(
                          photo!,
                          width: double.infinity,
                          height: 160.h,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 4.w,
                          top: 4.h,
                          child: GestureDetector(
                            onTap: () => onChanged(null),
                            child: SvgPicture.asset(
                              'assets/icons/cross.svg',
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SvgPicture.asset('assets/icons/upload.svg'),
          ),
        ),
      ],
    );
  }
}
