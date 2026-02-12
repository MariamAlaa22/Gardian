import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/app.dart';

class UploadAppsService {
  final _dbRef = FirebaseDatabase.instance.ref("users/childs");
  final _auth = FirebaseAuth.instance;

  Future<void> syncApps() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null || user.email == null) return;

      // 1. جلب قائمة التطبيقات (v1.0.1 بترجع List<AppInfo> غير قابلة للـ null)
      List<AppInfo> deviceApps = await InstalledApps.getInstalledApps();
      
      // 2. الفلترة النظيفة (بدل builtIn وبدون تشيك null ملوش لازمة)
      deviceApps.removeWhere((app) => 
        app.packageName.contains("com.google") || 
        app.packageName == "com.android.chrome" ||
        app.packageName.startsWith("com.android.systemui")
      );

      // 3. جلب البيانات من Firebase للمزامنة
      final snapshot = await _dbRef.orderByChild("email").equalTo(user.email).get();

      if (snapshot.exists) {
        final childKey = snapshot.children.first.key;
        final childData = snapshot.children.first.value as Map<dynamic, dynamic>;
        
        List<App> onlineApps = [];
        if (childData['apps'] != null) {
          var appsListFromDb = childData['apps'] as List<dynamic>;
          onlineApps = appsListFromDb.map((e) => App.fromMap(Map<String, dynamic>.from(e))).toList();
        }

        List<Map<String, dynamic>> finalAppsToUpload = [];

        for (var dApp in deviceApps) {
          // البحث عن التطبيق أونلاين للحفاظ على حالة الـ blocked
          App existingApp = onlineApps.firstWhere(
            (oApp) => oApp.packageName == dApp.packageName,
            orElse: () => App(appName: dApp.name, packageName: dApp.packageName, blocked: false)
          );

          App syncApp = App(
            appName: dApp.name,
            packageName: dApp.packageName,
            blocked: existingApp.blocked,
            screenLock: existingApp.screenLock,
          );

          finalAppsToUpload.add(syncApp.toMap());
        }

        // 4. الرفع النهائي
        await _dbRef.child(childKey!).child("apps").set(finalAppsToUpload);
        // تم استبدال print بـ log أو حذفها لراحة العين في الـ Console
      }
    } catch (e) {
      // خطأ بسيط في حالة الفشل
    }
  }
}