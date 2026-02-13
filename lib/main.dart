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
import 'package:gardians/screens/addchild.dart';
import 'package:gardians/screens/devices.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // تأكدي إن ملف google-services.json في مكانه
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // تعريف القنوات (Channels) للربط مع كود الجافا
  static const smsChannel = MethodChannel('com.kidsafe/sms');
  static const callChannel = MethodChannel('com.kidsafe/calls');

  @override
  void initState() {
    super.initState();
    _initNativeListeners();
  }

  void _initNativeListeners() {
    // 1. استقبال الرسائل النصية
    smsChannel.setMethodCallHandler((call) async {
      print("🔔 إشارة رسالة وصلت من الأندرويد: ${call.method}"); // للتأكد في الـ Debug Console
      
      if (call.method == "onMessageReceived") {
        final String sender = call.arguments['sender'] ?? "Unknown";
        final String body = call.arguments['body'] ?? "";
        
        print("📩 محتوى الرسالة: من $sender نصها: $body");
        _uploadToFirebase("messages", {
          "senderPhoneNumber": sender,
          "messageBody": body,
          "timeReceived": DateTime.now().toString(),
        });
      }
      return null;
    });

    // 2. استقبال بيانات المكالمات
    callChannel.setMethodCallHandler((call) async {
      print("📞 إشارة مكالمة وصلت من الأندرويد: ${call.method}");
      
      if (call.method == "onCallEvent") {
        final String status = call.arguments['status'] ?? "Unknown";
        final String number = call.arguments['phoneNumber'] ?? "Private";
        final String duration = call.arguments['duration'] ?? "0";
        
        print("📱 حدث مكالمة: $status رقم: $number مدة: $duration");
        _uploadToFirebase("calls", {
          "callType": status,
          "phoneNumber": number,
          "callDuration": duration,
          "callTime": DateTime.now().toString(),
        });
      }
      return null;
    });
  }

  // دالة رفع البيانات للفيربيز
  void _uploadToFirebase(String folder, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference ref = FirebaseDatabase.instance.ref("users/childs/${user.uid}/$folder");
      await ref.push().set(data);
      print("✅ تم الرفع إلى Firebase في مجلد $folder");
    } else {
      print("⚠️ تنبيه: البيانات وصلت لفلاتر بس مفيش مستخدم مسجل دخول للرفع للفيربيز!");
    }
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
        '/add_child': (context) => const AddChildScreen(),
        '/devices': (context) => const DevicesScreen(),
      },
    );
  }
}
