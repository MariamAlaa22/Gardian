import 'package:flutter/material.dart';
import 'package:gardians/screens/dashboard.dart';

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
  final Color skyBlue = const Color(0xFF9ED7EB);

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

                  buildMyField(
                    label: "Username",
                    icon: Icons.person_outline,
                    myController: _nameController,
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Name is required"
                        : null,
                  ),
                  buildMyField(
                    label: "Email",
                    icon: Icons.email_outlined,
                    myController: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!value.contains('@')) return "Invalid email format";
                      return null;
                    },
                  ),
                  buildMyField(
                    label: "Password",
                    icon: Icons.lock_outline,
                    myController: _passController,
                    isPass: true,
                    isObscured: _obscureText,
                    onToggle: () =>
                        setState(() => _obscureText = !_obscureText),
                    validator: (value) => (value != null && value.length < 6)
                        ? "At least 6 characters"
                        : null,
                  ),
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
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value.length < 6) {
                        return "Must be at least 6 characters";
                      }
                      if (value != _passController.text) {
                        return "Passwords don't match";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navyBlue,
                      disabledBackgroundColor: navyBlue.withValues(alpha: 0.7),
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
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              await Future.delayed(const Duration(seconds: 2));
                              if (!context.mounted) return;
                              setState(() => _isLoading = false);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ParentDashboard(),
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
