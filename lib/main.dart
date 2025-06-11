import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

import 'cssb/cssb_boar.dart';
import 'cssb/cssb_color.dart';
import 'models/activity_model.dart';
import 'models/activity_type.dart';
import 'models/entry_model.dart';
import 'models/friend_model.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(FriendModelAdapter());
  Hive.registerAdapter(ActivityTypeAdapter());
  Hive.registerAdapter(ActivityModelAdapter());
  Hive.registerAdapter(EntryModelAdapter());

  final friii = await Hive.openBox<FriendModel>('friii');
  GetIt.I.registerSingleton<Box<FriendModel>>(friii);
  final entryBox = await Hive.openBox<EntryModel>('entries');
  GetIt.I.registerSingleton<Box<EntryModel>>(entryBox);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AntiqueLedger - Precious Opus',
        theme: ThemeData(
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(
            backgroundColor: CSSBColor.bg,
            iconTheme: IconThemeData(
              color: CSSBColor.white,
            ),
          ),
          scaffoldBackgroundColor: CSSBColor.bg,
          fontFamily: 'Inter',
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}
