import 'package:flutter/material.dart';
import 'package:gardians/screens/otp.dart';
import 'package:gardians/screens/sign_in.dart';
import 'package:gardians/screens/signup.dart';
import 'package:flutter/gestures.dart';

class Parent extends StatelessWidget {
  const Parent({super.key});

  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity, 
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 300, 
                  width: 250, 
                  child: Image.asset(
                    'assets/images/logo2.png',
                    fit: BoxFit
                        .contain,
                  ),
                ),

                Text(
                  "Welcome to Gardian",
                  style: TextStyle(
                    color: navyBlue,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your child's safety is our top priority.\nJoin us to start monitoring.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: navyBlue.withValues(alpha: 0.5), fontSize: 15),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: 250,
                  height: 55,
                  child: ElevatedButton(
        onPressed: () {   Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignIn()),
                      ); },
        style: ElevatedButton.styleFrom(
          backgroundColor: navyBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        child: const Text("Login as Parent", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    ),
    const SizedBox(height: 15),
    
    // 2. زرار إنشاء حساب جديد (ثانوي)
    SizedBox(
      width: 280,
      height: 55,
      child: OutlinedButton(
        onPressed: () { Navigator.push(

                        context,

                        MaterialPageRoute(builder: (context) => const Signup()),

                      ); },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: navyBlue, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        child: Text("Create Account", style: TextStyle(color: navyBlue, fontSize: 18)),
      ),
    ),
    
    const SizedBox(height: 30),
    
    // 3. زرار الطفل (بشكل مختلف خالص عشان ما يتلخبطش)
    RichText(
  text: TextSpan(
    style: TextStyle(
      color: navyBlue.withValues(alpha: 0.5), // اللون الهادي للنص العادي
      fontSize: 14,
    ),
    children: [
      const TextSpan(text: "Setting up a child's device? "),
      TextSpan(
        text: "Click here",
        style: TextStyle(
          color: navyBlue, // لون الكحلي الصريح للكلمة اللي بتداس
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline, // خط تحتها عشان تبان إنها لينك
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // التوجيه لشاشة الـ OTP بتاعة الطفل
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OTPScreen()),
            );
          },
      ),
    ],
  ),
)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
