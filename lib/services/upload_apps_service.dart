import 'package:usage_stats/usage_stats.dart';
import 'package:firebase_database/firebase_database.dart';

class UploadAppsService {
  static Future<void> uploadInstalledApps(String childUid) async {
    try {
      DateTime end = DateTime.now();
      DateTime start = end.subtract(const Duration(days: 7));
      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(start, end);

      Map<String, dynamic> appsMap = {};
      for (var usage in usageStats) {
        String pkg = usage.packageName ?? "";

        // الفلتر الذكي: استبعاد أي حاجة تبع أندرويد أو جوجل سيستم أو واجهة الجهاز
        bool isSystem =
            pkg.contains("com.android") ||
            pkg.contains("android") ||
            pkg.contains("com.sec.android") || // لجهزة سامسونج
            pkg.contains("com.miui"); // لأجهزة شاومي

        if (pkg.isNotEmpty && !isSystem) {
          String packageKey = pkg.replaceAll('.', '_');

          // تحسين اسم التطبيق: بناخد آخر جزء ونخليه Capitalize
          String rawName = pkg.split('.').last;
          String formattedName =
              rawName[0].toUpperCase() + rawName.substring(1);

          appsMap[packageKey] = {
            "app_name": formattedName,
            "package_name": pkg,
            "is_blocked": false,
          };
        }
      }

      await FirebaseDatabase.instance
          .ref("devices_data/$childUid/installed_apps")
          .set(appsMap);
      print("✅ [Service] Clean Apps List Synced!");
    } catch (e) {
      print("❌ [Service] Sync Apps Error: $e");
    }
  }
}
