import 'package:flutter/material.dart';
import 'dart:math'; // 1. استيراد مكتبة الحساب لتوليد كود عشوائي

class PairingCodeScreen extends StatefulWidget {
  const PairingCodeScreen({super.key});

  @override
  State<PairingCodeScreen> createState() => _PairingCodeScreenState();
}

class _PairingCodeScreenState extends State<PairingCodeScreen> {
  final Color navyBlue = const Color(0xFF042459);
  // 2. تعريف متغير للكود
  late String pairCode;

  @override
  void initState() {
    super.initState();
    // 3. توليد الكود أول ما الشاشة تفتح
    pairCode = _generateRandomCode();
  }

  // ميثود لتوليد 6 أرقام عشوائية بتنسيق (XXX XXX)
  String _generateRandomCode() {
    var rng = Random();
    int part1 = rng.nextInt(900) + 100; // رقم من 3 خانات
    int part2 = rng.nextInt(900) + 100; // رقم تاني من 3 خانات
    return "$part1 $part2";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // أضفت الخلفية البيضاء لضمان الشكل
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CloseButton(color: navyBlue),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Pairing Code",
                style: TextStyle(
                  color: navyBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Enter this code on your child's device to link it to your account.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // الكود الـ Dynamic داخل الـ Container بتاعك
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF9ED7EB), width: 2),
                ),
                child: Text(
                  pairCode, // استخدام المتغير الـ Dynamic
                  style: TextStyle(
                    color: navyBlue,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              const SizedBox(height: 20),
              const Text(
                "Waiting for child device...",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),

              // نصيحة إضافية: ممكن تضيف زرار "Refresh" لو حابب يغير الكود
              TextButton.icon(
                onPressed: () =>
                    setState(() => pairCode = _generateRandomCode()),
                icon: Icon(Icons.refresh, color: navyBlue, size: 18),
                label: Text(
                  "Generate new code",
                  style: TextStyle(color: navyBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
