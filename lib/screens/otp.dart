import 'package:flutter/material.dart';
import 'package:gardians/screens/permission.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_database/firebase_database.dart';
// استيراد الـ Utils عشان نحفظ بيانات الربط محلياً
import '../utils/shared_prefs_utils.dart';
import '../utils/constants.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  final Color skyBlue = const Color(0xFF9ED7EB);
  final Color navyBlue = const Color(0xFF042459);

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: const Color(0x4D9ED7EB),
        borderRadius: BorderRadius.circular(15),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: skyBlue.withValues(alpha: 0.3),
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
                      text: "1",
                      style: TextStyle(color: navyBlue),
                    ),
                    TextSpan(
                      text: " / 2",
                      style: TextStyle(color: navyBlue.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 266,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pairing Device",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: navyBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // تعديل النص ليكون مناسباً للـ Logic الحقيقي
                  Text(
                    "Enter the 6-digit code displayed on your parent's screen.",
                    style: TextStyle(
                      color: navyBlue.withValues(alpha: 0.5),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Pinput(
              length: 6,
              controller: _otpController,
              defaultPinTheme: defaultPinTheme,
              onChanged: (value) => setState(() {}),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: const Color(0xFF9ED7EB), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: navyBlue,
                disabledBackgroundColor: navyBlue.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: (_isLoading || _otpController.text.length < 6)
                  ? null
                  : () async {
                      setState(() => _isLoading = true);

                      try {
                        String enteredCode = _otpController.text.trim();
                        DatabaseReference codeRef = FirebaseDatabase.instance
                            .ref("pairing_codes/$enteredCode");

                        DataSnapshot snapshot = await codeRef.get();

                        if (!context.mounted) return;

                        if (snapshot.exists) {
                          Map data = snapshot.value as Map<dynamic, dynamic>;

                          if (data['status'] == 'linked') {
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "This code has already been used!",
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          String parentUid = data['parent_uid'];
                          String childName = data['child_name'];

                          String childUid = FirebaseDatabase.instance
                              .ref()
                              .push()
                              .key!;

                          await FirebaseDatabase.instance
                              .ref("users/children/$childUid")
                              .set({
                                "name": childName,
                                "parent_uid": parentUid,
                                "is_paired": true,
                                "joinedAt": ServerValue.timestamp,
                              });

                          await FirebaseDatabase.instance
                              .ref(
                                "users/parents/$parentUid/children/$childUid",
                              )
                              .set(true);
                          await codeRef.update({"status": "linked"});

                          await SharedPrefsUtils.setString(
                            "child_uid",
                            childUid,
                          );
                          await SharedPrefsUtils.setString(
                            "parent_uid",
                            parentUid,
                          );
                          await SharedPrefsUtils.setBool(
                            "is_child_device",
                            true,
                          );

                          setState(() => _isLoading = false);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Paired Successfully!",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.only(
                                bottom: 20,
                                left: 20,
                                right: 20,
                              ),
                            ),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ParentGrantPermissions(),
                            ),
                          );
                        } else {
                          setState(() => _isLoading = false);
                          _otpController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Invalid Code! Please check the parent device.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => _isLoading = false);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Verify",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
