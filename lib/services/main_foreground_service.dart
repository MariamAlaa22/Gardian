import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gardians/services/alert_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:usage_stats/usage_stats.dart';
import 'upload_apps_service.dart'; // لو الملفين في نفس المجلد
import '../utils/shared_prefs_utils.dart';
import '../models/app.dart';

// 1. الدالة الأساسية (لازم تكون بره الكلاس عشان الـ Isolate يشتغل صح)
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  print("🚀 [Service] Background Isolate Started!");

  // تهيئة فايربيز في الخلفية
  try {
    await Firebase.initializeApp();
    print("🚀 [Service] Firebase Initialized");
  } catch (e) {
    print("❌ [Service] Firebase Error: $e");
  }

  // تهيئة الخزنة وسحب الـ ID
  await SharedPrefsUtils.init();
  String? childUid = SharedPrefsUtils.getString("child_uid");
  print("🚀 [Service] Child UID: $childUid");

  if (childUid == null) {
    print("❌ [Service] ERROR: child_uid is NULL! Data will not upload.");
    return; // مش هنقفل الخدمة عشان الإشعار يفضل شغال ونعرف إنها قامت
  }

  // تشغيل المحرك
  MainForegroundService.startEngine(childUid);
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

// 2. كلاس المحرك
class MainForegroundService {
  static final Battery _battery = Battery();
  static late DatabaseReference _deviceDataRef;
  static late DatabaseReference _rulesRef;
  static late DatabaseReference _alertsRef;
  static late DatabaseReference _commsRef;
  static List<App> _monitoredApps = [];

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'kidsafe_service',
      'Gardians Protection',
      description: 'Monitoring device securely in the background',
      importance: Importance.high,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart, // تم ربطها بالدالة اللي بره
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'kidsafe_service',
        initialNotificationTitle: 'Gardians Protection',
        initialNotificationContent:
            'Monitoring device securely in the background...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(onBackground: onIosBackground),
    );
  }

  static void startEngine(String childUid) {
    // 1. تعريف المراجع بناءً على الـ UID المستلم
    _deviceDataRef = FirebaseDatabase.instance.ref("devices_data/$childUid");
    _rulesRef = FirebaseDatabase.instance.ref("rules/$childUid");
    _alertsRef = FirebaseDatabase.instance.ref("alerts/$childUid");
    _commsRef = FirebaseDatabase.instance.ref("communication_logs/$childUid");

    print("🚀 [Service] Engine Started for $childUid");

    NotificationMonitor.startListening(childUid);
    // 2. تحديث حالة الاتصال (Online/Offline)
    _deviceDataRef.child("is_online").set(true);
    _deviceDataRef.child("is_online").onDisconnect().set(false);

    // 3. رفع البيانات الثابتة (بتترفع مرة واحدة عند تشغيل الخدمة)
    _uploadContacts(); // رفع جهات الاتصال
    UploadAppsService.uploadInstalledApps(
      childUid,
    ); // رفع قائمة التطبيقات المثبتة للمنيو

    // 4. دورة تحديث الموقع والبطارية (كل 10 ثواني)
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      print("🚀 [Service] Fetching Location & Battery...");
      await _updateDeviceStatus();
    });

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      print("🚀 [Service] Fetching app usage");

      await _checkActiveApp(childUid);
    });
  }

  static Future<void> _checkActiveApp(String childUid) async {
    try {
      DateTime now = DateTime.now();
      List<UsageInfo> stats = await UsageStats.queryUsageStats(
        now.subtract(const Duration(seconds: 5)),
        now,
      );

      if (stats.isNotEmpty) {
        stats.sort((a, b) => b.lastTimeUsed!.compareTo(a.lastTimeUsed!));
        String currentApp = stats.first.packageName!;

        // رفع حالة التطبيق الحالي لفايربيز (عشان الأب يشوفه لايف)
        await FirebaseDatabase.instance
            .ref("devices_data/$childUid/current_app")
            .set(currentApp);
      }
    } catch (e) {
      print("❌ [Service] App Status Error: $e");
    }
  }

  static Future<void> _updateDeviceStatus() async {
    try {
      int batteryLevel = await _battery.batteryLevel;
      await _deviceDataRef.update({
        "battery_level": batteryLevel,
        "is_online": true,
        "last_ping": ServerValue.timestamp,
      });

      // تعديل: طلب الموقع الحالي مباشرة بدقة عالية لتخطي تهنيج الـ Emulator
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best, // رفعنا الدقة لأعلى مستوى
        forceAndroidLocationManager:
            true, // بنجبره يستخدم الـ Manager بتاع أندرويد مباشرة
        timeLimit: const Duration(seconds: 8),
      );

      await _deviceDataRef.child("location").update({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "last_updated": ServerValue.timestamp,
      });
      print("🚀 [Service] New Location Uploaded: ${position.latitude}");
    } catch (e) {
      print("❌ [Service] Update Error: $e");
    }
  }

  static Future<void> _uploadContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true,
        );
        Map<String, dynamic> contactsMap = {};
        for (var i = 0; i < contacts.length; i++) {
          var c = contacts[i];
          contactsMap["contact_$i"] = {
            "name": c.displayName,
            "number": c.phones.isNotEmpty ? c.phones.first.number : "",
          };
        }
        await _commsRef.child("contacts").set(contactsMap);
        print("🚀 [Service] Contacts Uploaded!");
      }
    } catch (e) {
      print("❌ [Service] Contacts Error: $e");
    }
  }
}
