import 'package:flutter/material.dart';
import 'package:gardians/screens/dashboard.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});


  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

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
  }) {
    return Container(
      width: 266,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: myController,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF5AB9D9)), 
          filled: true,
          fillColor: const Color(0x4D9ED7EB), 
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Color(0xFF5AB9D9), width: 1.5),
          ),
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
                      color: navyBlue.withValues(alpha: 0.5),
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
            ),

            buildMyField(
              label: "Password",
              icon: Icons.lock_outline,
              myController: _passController,
              isPass: true,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ParentDashboard()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF042459), 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text("LogIn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
