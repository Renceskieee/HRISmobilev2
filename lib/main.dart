import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../pages/login.dart';
import '../pages/dashboard.dart';
import '../pages/notifications.dart';
import '../pages/settings.dart';

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
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const DashboardScreen(user: {}),
            '/notifications': (context) => const NotificationPage(),
            '/settings': (context) => SettingsPage(
              user: const {},
              onProfileUpdated: (Map<String, dynamic> updatedUser) {
              },
            ),
          },
        );
      },
    );
  }
}
