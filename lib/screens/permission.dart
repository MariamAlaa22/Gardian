import 'package:flutter/material.dart';
import 'package:gardians/screens/childhome.dart';

class ParentGrantPermissions extends StatefulWidget {
  const ParentGrantPermissions({super.key});

  @override
  State<ParentGrantPermissions> createState() => _ParentGrantPermissionsState();
}

class _ParentGrantPermissionsState extends State<ParentGrantPermissions> {
  // الألوان الموحدة من شاشة الـ OTP
  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);
  final Color accentBlue = const Color(0xFF5AB9D9); // اللون المستخدم في التايمر والروابط

  bool isLocationEnabled = false;
  bool isUsageEnabled = false;
  bool isOverlayEnabled = false;

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
              color: skyBlue.withValues(alpha: 0.3), // نفس ستايل الـ Step counter في الـ OTP
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: "2", style: TextStyle(color: navyBlue)),
                    TextSpan(
                        text: " / 2",
                        style: TextStyle(color: navyBlue.withValues(alpha:0.5))),
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
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: navyBlue),
            ),
            const SizedBox(height: 10),
            Text(
              "Grant the following permissions to enable full protection and monitoring features.",
              style: TextStyle(color: navyBlue.withValues(alpha:0.5), fontSize: 15),
            ),
            const SizedBox(height: 40),

            _buildPermissionItem(
              title: "Location Services",
              desc: "Allows you to track your child's live location and set safe zones.",
              icon: Icons.my_location_rounded,
              status: isLocationEnabled,
              onBtnPressed: () => setState(() => isLocationEnabled = !isLocationEnabled),
            ),

            _buildPermissionItem(
              title: "App Usage Access",
              desc: "Enables screen time reports and app blocking capabilities.",
              icon: Icons.app_registration_rounded,
              status: isUsageEnabled,
              onBtnPressed: () => setState(() => isUsageEnabled = !isUsageEnabled),
            ),

            _buildPermissionItem(
              title: "Screen Overlay",
              desc: "Required to show the 'Time's Up' screen and block restricted apps.",
              icon: Icons.layers_rounded,
              status: isOverlayEnabled,
              onBtnPressed: () => setState(() => isOverlayEnabled = !isOverlayEnabled),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: canActivate
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text("Protection Activated!", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                          ),
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const ChildHomeScreen()),
                          (route) => false,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyBlue,
                  disabledBackgroundColor: navyBlue.withValues(alpha:0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), // نفس تدويرة زرار OTP
                  elevation: 0,
                ),
                child: const Text("Activate Protection",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text("You can manage these settings later from your dashboard",
                  style: TextStyle(color: navyBlue.withValues(alpha:0.4), fontSize: 11)),
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
        // استخدام اللون السماوي الفاتح جداً كخلفية عند التفعيل
        color: status ? skyBlue.withValues(alpha:0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // نفس درجة خلفية أيقونة الـ OTP (الـ 4d تعني 30% شفافية)
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
                Text(title,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: navyBlue)),
                const SizedBox(height: 5),
                Text(desc,
                    style: TextStyle(fontSize: 13, color: navyBlue.withValues(alpha: 0.5), height: 1.4)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onBtnPressed,
                  child: Text(
                    status ? "PERMISSION GRANTED" : "ENABLE NOW",
                    style: TextStyle(
                      color: status ? Colors.green : accentBlue, // استخدام لون الـ Resend
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.1,
                      decoration: status ? TextDecoration.none : TextDecoration.underline,
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