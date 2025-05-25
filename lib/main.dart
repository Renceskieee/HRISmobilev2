import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../pages/login.dart';

void main() => runApp(const EARISTHRIS());

class EARISTHRIS extends StatelessWidget {
  const EARISTHRIS({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 715),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'EARIST HRIS',
          home: const LoginScreen(),
        );
      },
    );
  }
}
