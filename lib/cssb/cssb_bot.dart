import 'package:chrono_social_social_balance_231_a/screens/analytycs_screen.dart';
import 'package:chrono_social_social_balance_231_a/screens/friends_screen.dart';
import 'package:chrono_social_social_balance_231_a/screens/settings_screen.dart';
import 'package:chrono_social_social_balance_231_a/screens/time_tr_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CssbBotBar extends StatefulWidget {
  const CssbBotBar({super.key, this.indexScr = 0});
  final int indexScr;

  @override
  State<CssbBotBar> createState() => _CssbBotBarState();
}

class _CssbBotBarState extends State<CssbBotBar> {
  late int _currentIndex;

  final List<Widget> screens = const [
    TimeTrScreen(),
    FriendsScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  final List<String> icons = [
    "assets/icons/time.svg",
    "assets/icons/friend.svg",
    "assets/icons/analytic.svg",
    "assets/icons/settings.svg",
  ];

  final List<String> activeIcons = [
    "assets/icons/time.svg",
    "assets/icons/friend.svg",
    "assets/icons/analytic.svg",
    "assets/icons/settings.svg",
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.indexScr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        height: 80.h + MediaQuery.of(context).padding.bottom,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(icons.length, (index) {
            final isSelected = _currentIndex == index;
            final iconPath = icons[index];

            return GestureDetector(
              onTap: () => setState(() => _currentIndex = index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 12.h),
                  SvgPicture.asset(
                    iconPath,
                    colorFilter: ColorFilter.mode(
                      isSelected ? const Color(0xFF3D8BFF) : Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    height: 2.h,
                    width: 20.w,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3D8BFF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
