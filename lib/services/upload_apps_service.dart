import 'package:device_apps/device_apps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// هنا بنعمل import للموديل اللي زميلك عمله عشان نستخدمه
import '../models/app.dart'; 

class UploadAppsService {
  // بنعرف المداخل لخدمات Firebase
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // دي الوظيفة اللي هترفع تطبيقات الموبايل للداتابيز
  Future<void> syncApps() async {
    try {
      // 1. التأكد إن فيه مستخدم (طفل) مسجل دخول
      final User? currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.email == null) return;

      // 2. سحب قائمة التطبيقات المتسطبة (بدون تطبيقات السيستم)
      List<Application> installedApps = await DeviceApps.getInstalledApplications(
        includeSystemApps: false,
        onlyAppsWithLaunchIntent: true,
      );

      // 3. البحث عن الـ ID بتاع الطفل ده في Firebase بالإيميل بتاعه
      final snapshot = await _dbRef.child("childs")
          .orderByChild("email")
          .equalTo(currentUser.email)
          .get();

      if (snapshot.exists) {
        // بنجيب مفتاح الطفل (الـ Key)
        Map<dynamic, dynamic> childrenMap = snapshot.value as Map;
        String childKey = childrenMap.keys.first;

        // 4. تحويل التطبيقات لشكل "List of Maps" عشان Firebase يقبلها
        List<Map<String, dynamic>> appsData = installedApps.map((app) {
          // هنا بنستخدم موديل الـ App اللي زميلك عمله
          return {
            'appName': app.appName,
            'packageName': app.packageName,
            'isBlocked': false, // القيمة الافتراضية
          };
        }).toList();

        // 5. الرفع النهائي للداتابيز
        await _dbRef.child("childs").child(childKey).child("apps").set(appsData);
        print("✅ تم رفع التطبيقات بنجاح");
      }
    } catch (e) {
      print("❌ حصل خطأ أثناء الرفع: $e");
    }
  }
}