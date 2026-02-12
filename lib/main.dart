import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // ضيفي ده
import 'package:gardians/screens/Signup.dart';
import 'package:gardians/screens/sign_in.dart';
import 'package:gardians/screens/splash.dart';
import 'package:gardians/screens/welcome.dart';
import 'package:gardians/screens/dashboard.dart';
import 'package:gardians/utils/shared_prefs_utils.dart';
import 'package:gardians/services/main_foreground_service.dart'; // ضيفي ده
import 'test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsUtils.init(); // لازم دي عشان الـ Signup تحفظ البيانات صح

  runApp(const MyApp());
}

// الكلاس ده هتحتاجيه لما تنقلي الـ Routes للشغل الحقيقي
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const Splash(),
        "/welcome": (context) => const Welcome(),
        "/sign_in": (context) => const SignIn(),
        "/SignUp": (context) => const Signup(),
        "/dashboard": (context) => const ParentDashboard(),
      },
    );
  }
}