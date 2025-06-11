import 'package:chrono_social_social_balance_231_a/cssb/cssb_bot.dart';
import 'package:chrono_social_social_balance_231_a/cssb/cssb_dok.dart';
import 'package:chrono_social_social_balance_231_a/cssb/cssb_moti.dart';
import 'package:chrono_social_social_balance_231_a/cssb/cssb_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),

              /// Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Restore Purchase",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CssbBotBar()),
                    ),
                    child: const Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              Image.asset(
                "assets/images/bd_prem.png",
              ),

              SizedBox(height: 32.h),

              _featureItem(
                icon: "assets/icons/premi_1.svg",
                text: 'Get access to the “Analytics” section',
              ),
              SizedBox(height: 16.h),
              _featureItem(
                icon: "assets/icons/premi_2.svg",
                text: 'Add unlimited friends',
              ),

              SizedBox(height: 32.h),

              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1279EF), Color(0xFF1197EA)],
                    ),
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Get Premium for \$0.99",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CssbMotiiButT(
                    onPressed: () => cssbUrl(context, CssbDokum.teof),
                    child: _FooterLink(text: "Terms of use"),
                  ),
                  CssbMotiiButT(
                    onPressed: () => cssbUrl(context, CssbDokum.pp),
                    child: _FooterLink(text: "Privacy Policy"),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureItem({required String icon, required String text}) {
    return Row(
      children: [
        SvgPicture.asset(icon),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;

  const _FooterLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0C3C74)),
    );
  }
}