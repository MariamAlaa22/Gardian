import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gardians/screens/splash.dart';
import 'package:gardians/screens/welcome.dart';
import 'package:gardians/screens/sign_in.dart';
import 'package:gardians/screens/Signup.dart';
import 'package:gardians/screens/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('com.kidsafe/sms');

  @override
  void initState() {
    super.initState();
    _initSmsListener();
  }

  void _initSmsListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onMessageReceived") {
        final String sender = call.arguments['sender'];
        final String body = call.arguments['body'];

        // الرفع للـ Firebase بأمان من كود الـ Dart
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          DatabaseReference ref = FirebaseDatabase.instance.ref("users/childs/${user.uid}/messages");
          await ref.push().set({
            "senderPhoneNumber": sender,
            "messageBody": body,
            "timeReceived": DateTime.now().toString(),
            "contactName": "Unknown"
          });
        }
      }
    });
  }

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