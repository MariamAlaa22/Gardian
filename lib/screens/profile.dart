import 'package:flutter/material.dart';
// 1. استيراد الملفات اللي هنربط بيها
import '../models/parent.dart' as model;
import '../utils/shared_prefs_utils.dart';
import '../utils/constants.dart';
import '../utils/background_generator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);

  // 2. تعريف موديل الأب اللي هيشيل البيانات الحقيقية
  late model.Parent currentParent;

  @override
  void initState() {
    super.initState();
    // 3. جلب البيانات من الـ SharedPrefs اللي اتخزنت وقت الـ Login
    String name = SharedPrefsUtils.getString(Constants.name) ?? "null";
    String email = SharedPrefsUtils.getString(Constants.email) ?? "null";

    currentParent = model.Parent(name: name, email: email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 4. استخدام الـ BackgroundGenerator للصورة بدلاً من الصورة الثابتة
            CircleAvatar(
              radius: 50,
              backgroundColor: BackgroundGenerator.getRandomColor(),
              child: Text(
                BackgroundGenerator.getFirstCharacters(currentParent.name!),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 5. عرض الاسم الحقيقي من الموديل
            Text(
              currentParent.name!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: navyBlue,
              ),
            ),

            // 6. عرض الإيميل الحقيقي من الموديل
            Text(
              currentParent.email!,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: navyBlue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                // هنا ممكن نفتح شاشة الـ Upgrade مستقبلاً
              },
              child: const Text(
                "Upgrade now - Go Pro",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // خيارات البروفايل
            _buildProfileOption(Icons.person_outline, "Change Account", () {
              // هنا ممكن نربط التنقل لشاشة تعديل البيانات
            }),
            _buildProfileOption(Icons.group_outlined, "Sub-account", () {}),
            _buildProfileOption(
              Icons.phone_android_outlined,
              "Device Management",
              () {
                // نربطها بشاشة الـ Devices اللي عندك في القائمة
                Navigator.pushNamed(context, "/devices");
              },
            ),
            _buildProfileOption(Icons.language_outlined, "APP Language", () {}),
            _buildProfileOption(Icons.lock_outline, "Pin Set", () {}),
            _buildProfileOption(
              Icons.volume_up_outlined,
              "Sound Settings",
              () {},
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // تحديث الـ Widget ليقبل وظيفة الـ onTap
  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0x4D9ED7EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Icon(icon, color: navyBlue),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: navyBlue,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: navyBlue),
        onTap: onTap,
      ),
    );
  }
}
