import 'package:chrono_social_social_balance_231_a/cssb/cssb_bot.dart';
import 'package:chrono_social_social_balance_231_a/screens/prem_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardPageData> pages = [
    const _OnboardPageData(
      version: "0.1.2",
      imagePath: "assets/images/bd1.png",
      title: "My Income",
      description:
      "Enter your income by specifying the amount and the date of receipt",
      buttonText: "Continue",
    ),
    const _OnboardPageData(
      version: "0.1.3",
      imagePath: "assets/images/bd2.png",
      title: "Optimization expenses",
      description:
      "Record expenses aimed at improving your work efficiency with a work hours histogram",
      buttonText: "Continue",
    ),
    const _OnboardPageData(
      version: "0.1.4",
      imagePath: "assets/images/bd3.png",
      title: "My Goals & Task calendar",
      description: "Set goals for cost reduction and workflow optimization",
      buttonText: "Continue",
    ),
  ];

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          final page = pages[index];

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Image.asset(
                      page.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 28.h),
                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          width: double.infinity,
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D7CFF),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            page.buttonText,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OnboardPageData {
  final String version;
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;

  const _OnboardPageData({
    required this.version,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}
