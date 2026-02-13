import 'package:flutter/material.dart';
import 'package:gardians/screens/childhome.dart';
import 'package:gardians/services/main_foreground_service.dart';
import 'package:gardians/services/upload_apps_service.dart'; // استيراد خدمة الرفع
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:shared_preferences/shared_preferences.dart'; // مهم للـ UID

class ParentGrantPermissions extends StatefulWidget {
  const ParentGrantPermissions({super.key});

  @override
  State<ParentGrantPermissions> createState() => _ParentGrantPermissionsState();
}

class _ParentGrantPermissionsState extends State<ParentGrantPermissions> {
  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);
  final Color accentBlue = const Color(0xFF5AB9D9);

  bool isLocationEnabled = false;
  bool isUsageEnabled = false;
  bool isOverlayEnabled = false;

  // دالة التعامل مع التفعيل النهائي
  Future<void> _handleActivation() async {
    // 1. تشغيل الخدمة في الخلفية
    await MainForegroundService.initializeService();
    FlutterBackgroundService().startService();

    // 2. رفع قائمة التطبيقات فوراً (الـ Quick Sync)
    final prefs = await SharedPreferences.getInstance();
    String? childUid = prefs.getString('child_uid');

    if (childUid != null) {
      print("🚀 [Manual Trigger] Uploading apps list for: $childUid");
      // نرفعها "Background" عشان منأخرش الانتقال للشاشة اللي بعدها
      UploadAppsService.uploadInstalledApps(childUid);
    }

    // 3. إظهار رسالة النجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              "Protection Activated & Apps Synced!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // 4. الانتقال لشاشة الطفل
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ChildHomeScreen()),
      (route) => false,
    );
  }

  Future<void> _requestLocation() async {
    PermissionStatus status = await Permission.location.request();
    await Permission.notification.request();
    if (status.isGranted) {
      PermissionStatus bgStatus = await Permission.locationAlways.request();
      if (bgStatus.isGranted) {
        setState(() => isLocationEnabled = true);
      } else {
        openAppSettings();
      }
    } else {
      openAppSettings();
    }
  }

  Future<void> _requestOverlay() async {
    if (await Permission.systemAlertWindow.isGranted) {
      setState(() => isOverlayEnabled = true);
    } else {
      PermissionStatus status = await Permission.systemAlertWindow.request();
      if (status.isGranted) {
        setState(() => isOverlayEnabled = true);
      } else {
        openAppSettings();
      }
    }
  }

  Future<void> _requestUsage() async {
    // 1. نشيك هل هي موجودة أصلاً؟
    bool? isGranted = await UsageStats.checkUsagePermission();

    if (isGranted == true) {
      setState(() => isUsageEnabled = true);
    } else {
      // 2. لو مش موجودة، نفتح الإعدادات
      await UsageStats.grantUsagePermission();

      // 3. (تريك المحترفين) ننتظر رجوع المستخدم
      // هنضيف مستمع (Listener) يتأكد أول ما الأبليكيشن يرجع يشتغل (Resume)
      _checkPermissionOnResume();
    }
  }

  // دالة مساعدة للتأكد بعد العودة من الإعدادات
  void _checkPermissionOnResume() async {
    // ننتظر ثانية عشان نضمن إن الأبليكيشن رجع للـ Foreground
    await Future.delayed(const Duration(milliseconds: 500));
    bool? isGranted = await UsageStats.checkUsagePermission();
    if (isGranted == true) {
      setState(() => isUsageEnabled = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canActivate = isLocationEnabled && isUsageEnabled && isOverlayEnabled;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: skyBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "2",
                      style: TextStyle(color: navyBlue),
                    ),
                    TextSpan(
                      text: " / 2",
                      style: TextStyle(color: navyBlue.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Setup Child's Device",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: navyBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Grant the following permissions to enable full protection.",
              style: TextStyle(color: navyBlue.withOpacity(0.5), fontSize: 15),
            ),
            const SizedBox(height: 40),
            _buildPermissionItem(
              title: "Location Services",
              desc: "Track live location and set safe zones.",
              icon: Icons.my_location_rounded,
              status: isLocationEnabled,
              onBtnPressed: _requestLocation,
            ),
            _buildPermissionItem(
              title: "App Usage Access",
              desc: "Enables screen time reports and app blocking.",
              icon: Icons.app_registration_rounded,
              status: isUsageEnabled,
              onBtnPressed: _requestUsage,
            ),
            _buildPermissionItem(
              title: "Screen Overlay",
              desc: "Required to block restricted apps.",
              icon: Icons.layers_rounded,
              status: isOverlayEnabled,
              onBtnPressed: _requestOverlay,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: canActivate
                    ? _handleActivation
                    : null, // نداء الدالة الجديدة
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyBlue,
                  disabledBackgroundColor: navyBlue.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Activate Protection",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                "You can manage these settings later from your dashboard",
                style: TextStyle(
                  color: navyBlue.withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required String title,
    required String desc,
    required IconData icon,
    required bool status,
    required VoidCallback onBtnPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status ? skyBlue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0x4D9ED7EB),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              status ? Icons.check_circle_rounded : icon,
              color: status ? Colors.green : navyBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: navyBlue,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: navyBlue.withOpacity(0.5),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: status ? null : onBtnPressed,
                  child: Text(
                    status ? "PERMISSION GRANTED" : "ENABLE NOW",
                    style: TextStyle(
                      color: status ? Colors.green : accentBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.1,
                      decoration: status
                          ? TextDecoration.none
                          : TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
