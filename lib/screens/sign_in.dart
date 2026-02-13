import 'package:flutter/material.dart';
import 'package:gardians/screens/dashboard.dart'; // تأكد من اسم الملف الصحيح عندك
import 'package:gardians/screens/signup.dart'; // تأكد من اسم الملف الصحيح عندك
import '../utils/validators.dart';
import '../utils/shared_prefs_utils.dart';
import '../utils/constants.dart';
// 1. استيراد الخدمة اللي عملناها
import '../services/auth_service.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final Color navyBlue = const Color(0xFF042459);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Widget buildMyField({
    required String label,
    required IconData icon,
    required TextEditingController myController,
    bool isPass = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      width: 266,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: myController,
        obscureText: isPass ? _obscureText : false,
        validator: validator,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF5AB9D9)),
          suffixIcon: isPass
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF5AB9D9),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0x4D9ED7EB),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Color(0xFF5AB9D9), width: 1.5),
          ),
          errorStyle: const TextStyle(fontSize: 10, height: 0.8),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
        ),
      ),
    );
  }

  // 2. تعديل الوظيفة لترتبط بـ Firebase
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // نداء خدمة الـ Firebase
        String? result = await AuthService().login(
          _emailController.text.trim(),
          _passController.text.trim(),
        );

        if (result == "success") {
          // إذا نجح الدخول، نفعل الـ Auto Login ونحفظ الإيميل محلياً
          await SharedPrefsUtils.setBool(Constants.autoLogin, true);
          await SharedPrefsUtils.setString(
            Constants.email,
            _emailController.text.trim(),
          );

          if (!mounted) return;

          // التوجه للداشبورد ومسح شريط التنقل بالكامل
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ParentDashboard()),
            (route) => false,
          );
        } else {
          // إذا فشل، نظهر رسالة الخطأ القادمة من Firebase (مثل: الباسورد خطأ)
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result ?? "Login Failed"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An unexpected error occurred: $e")),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 266,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome back!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF042459),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please log into your existing account",
                        style: TextStyle(
                          fontSize: 14,
                          color: navyBlue.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                buildMyField(
                  label: "Email",
                  icon: Icons.person_outline,
                  myController: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Email is required";
                    if (!Validators.isValidEmail(value))
                      return "Enter a valid email";
                    return null;
                  },
                ),
                buildMyField(
                  label: "Password",
                  icon: Icons.lock_outline,
                  myController: _passController,
                  isPass: true,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Password is required";
                    if (!Validators.isValidPassword(value))
                      return "Password too short";
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    // تأكد من استيراد ملف الـ signup.dart فوق
                    MaterialPageRoute(builder: (context) => const Signup()),
                  ),
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                      color: navyBlue.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF042459),
                    disabledBackgroundColor: const Color(
                      0xFF042459,
                    ).withOpacity(0.7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),

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
                          "LogIn",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
