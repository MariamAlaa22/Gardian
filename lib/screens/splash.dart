import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// استيراد الـ Utils اللي عملناها
import '../utils/shared_prefs_utils.dart';
import '../utils/constants.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final Color navyBlue = const Color(0xFF042459);

  @override
  void initState() {
    super.initState();
    _handleStartUp();
  }

  // الوظيفة الذكية لفحص حالة الدخول
  void _handleStartUp() {
    Timer(const Duration(seconds: 3), () {
      // 1. فحص حالة الـ autoLogin من الخزنة
      bool isLoggedIn = SharedPrefsUtils.getBool(Constants.autoLogin) ?? false;

      if (!mounted) return;

      // 2. اتخاذ القرار: Dashboard لو مسجل، أو Welcome لو جديد
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, "/dashboard");
      } else {
        Navigator.pushReplacementNamed(context, "/welcome");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animation/My kick us bear.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              // أضفت لك معالجة خطأ لو ملف الـ Json فيه مشكلة عشان الكود ميعلقش
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.shield_outlined, size: 100, color: navyBlue);
              },
            ),
            const SizedBox(height: 20),
            Text(
              "Gardians",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: navyBlue,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
