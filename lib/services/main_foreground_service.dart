import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:usage_stats/usage_stats.dart';
import '../models/app.dart';
// هنا بنستخدم as my_model عشان نحل مشكلة الـ Ambiguous import مع مكتبة الـ Contacts
import '../models/contact.dart' as my_model;
import '../models/location.dart' as loc_model;

class MainForegroundService {
  static final _dbRef = FirebaseDatabase.instance.ref("users/childs");
  static List<App> _monitoredApps = [];
  static String? _uid;

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'kidsafe_service',
        initialNotificationTitle: 'KidSafe Monitoring',
        initialNotificationContent: 'Protecting your child...',
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    _uid = FirebaseAuth.instance.currentUser?.uid;
    if (_uid == null) return;

    // 1. رفع الأسماء عند التشغيل
    _uploadContacts();

    // 2. مراقبة قائمة التطبيقات من الداتابيز
    _dbRef.child(_uid!).child("apps").onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as List<dynamic>;
        _monitoredApps = data.map((e) => App.fromMap(Map<String, dynamic>.from(e))).toList();
      }
    });

    // 3. تحديث الموقع والـ GeoFence كل 10 ثواني (عشان البطارية)
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _handleLocationAndFence();
    });

    // 4. الـ App Locker (مراقبة التطبيق المفتوح كل ثانية)
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _checkForegroundApp();
    });
  }

  static Future<void> _checkForegroundApp() async {
    try {
      DateTime now = DateTime.now();
      // في الإصدار الحالي المكتبة بتستخدم UsageInfo
      List<UsageInfo> stats = await UsageStats.queryUsageStats(
          now.subtract(const Duration(seconds: 5)), now);
      
      if (stats.isEmpty) return;
      
      stats.sort((a, b) => b.lastTimeUsed!.compareTo(a.lastTimeUsed!));
      String foregroundPkg = stats.first.packageName!;

      for (var app in _monitoredApps) {
        if (app.packageName == foregroundPkg && app.blocked) {
          print("🚨🚨 APP BLOCKED: $foregroundPkg");
          // هنا ممكن تبعت Notification أو تفتح شاشة القفل
        }
      }
    } catch (e) {
      print("Locker Error: $e");
    }
  }

  static Future<void> _handleLocationAndFence() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      await _dbRef.child(_uid!).child("location").update({
        "latitude": position.latitude,
        "longitude": position.longitude,
      });

      final locSnap = await _dbRef.child(_uid!).child("location").get();
      if (locSnap.exists) {
        final loc = loc_model.Location.fromMap(Map<String, dynamic>.from(locSnap.value as Map));
        if (loc.geoFence && loc.fenceCenterLatitude != null) {
          double distance = Geolocator.distanceBetween(
            loc.fenceCenterLatitude!, loc.fenceCenterLongitude!,
            position.latitude, position.longitude
          );
          
          bool isOut = distance > (loc.fenceDiameter ?? 0);
          await _dbRef.child(_uid!).child("location").update({"outOfFence": isOut});
        }
      }
    } catch (e) {
      print("Location Error: $e");
    }
  }

  static Future<void> _uploadContacts() async {
    if (await FlutterContacts.requestPermission()) {
      // سحب الأسماء بالتفاصيل
      List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);
      
      List<Map<String, dynamic>> contactsToUpload = contacts.map((c) => {
        "contactName": c.displayName,
        "contactNumber": c.phones.isNotEmpty ? c.phones.first.number : "",
      }).toList();
      
      await _dbRef.child(_uid!).child("contacts").set(contactsToUpload);
    }
  }
}