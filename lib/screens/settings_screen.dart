import 'package:chrono_social_social_balance_231_a/cssb/cssb_dok.dart';
import 'package:chrono_social_social_balance_231_a/cssb/cssb_moti.dart';
import 'package:chrono_social_social_balance_231_a/cssb/cssb_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            CssbMotiiButT(
              onPressed: () => cssbUrl(context, CssbDokum.pp),
              child: const _SettingsTile(
                iconPath: "assets/icons/pp.svg",
                title: "Privacy Policy",
              ),
            ),
            SizedBox(height: 12.h),
            CssbMotiiButT(
              onPressed: () => cssbUrl(context, CssbDokum.teof),
              child: const _SettingsTile(
                iconPath: "assets/icons/term.svg",
                title: "Terms of Use",
              ),
            ),
            SizedBox(height: 12.h),
            CssbMotiiButT(
              onPressed: () => cssbUrl(context, CssbDokum.seds),
              child: const _SettingsTile(
                iconPath: "assets/icons/support.svg",
                title: "Support",
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String iconPath;
  final String title;

  const _SettingsTile({
    required this.iconPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3D8BFF),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20.w,
            height: 20.h,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.white),
        ],
      ),
    );
  }
}
