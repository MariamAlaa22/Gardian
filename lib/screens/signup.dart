import 'package:flutter/material.dart';
import 'package:gardians/screens/dashboard.dart';
import 'package:gardians/screens/sign_in.dart';
// استيراد الملفات اللي حولناها
import '../utils/validators.dart';
import '../utils/shared_prefs_utils.dart';
import '../utils/constants.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final Color navyBlue = const Color(0xFF042459);
  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // وظيفة إنشاء الحساب
  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 1. حفظ البيانات في SharedPrefs (كأننا سجلنا المستخدم محلياً)
        await SharedPrefsUtils.setBool(Constants.autoLogin, true);
        await SharedPrefsUtils.setString(
          Constants.email,
          _emailController.text,
        );

        // هنا مستقبلاً هننده على AccountUtils لإنشاء الحساب في Firebase

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // الـ buildMyField كما هي في كودك
  Widget buildMyField({
    required String label,
    required IconData icon,
    required TextEditingController myController,
    bool isPass = false,
    bool isObscured = true,
    VoidCallback? onToggle,
    String? Function(String?)? validator,
  }) {
    return Container(
      width: 266,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: myController,
        obscureText: isPass ? isObscured : false,
        validator: validator,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF5AB9D9)),
          suffixIcon: isPass
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: onToggle,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Headers
                  SizedBox(
                    width: 266,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: navyBlue,
                          ),
                        ),
                        const Text(
                          "Account :)",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5AB9D9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  // Username field
                  buildMyField(
                    label: "Username",
                    icon: Icons.person_outline,
                    myController: _nameController,
                    validator: (value) => !Validators.isValidName(value ?? "")
                        ? "Name is required (max 15 chars)"
                        : null,
                  ),

                  // Email field
                  buildMyField(
                    label: "Email",
                    icon: Icons.email_outlined,
                    myController: _emailController,
                    validator: (value) => !Validators.isValidEmail(value ?? "")
                        ? "Invalid email format"
                        : null,
                  ),

                  // Password field
                  buildMyField(
                    label: "Password",
                    icon: Icons.lock_outline,
                    myController: _passController,
                    isPass: true,
                    isObscured: _obscureText,
                    onToggle: () =>
                        setState(() => _obscureText = !_obscureText),
                    validator: (value) =>
                        !Validators.isValidPassword(value ?? "")
                        ? "At least 6 characters"
                        : null,
                  ),

                  // Confirm Password field
                  buildMyField(
                    label: "Confirm Password",
                    icon: Icons.shield_outlined,
                    myController: _confirmController,
                    isPass: true,
                    isObscured: _obscureConfirmText,
                    onToggle: () => setState(
                      () => _obscureConfirmText = !_obscureConfirmText,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Please confirm password";
                      if (value != _passController.text)
                        return "Passwords don't match";
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navyBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 15,
                      ),
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
                            "Sign Up",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
