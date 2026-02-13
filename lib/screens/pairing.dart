import 'dart:async'; // نحتاجه للاستماع للداتابيز
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PairingCodeScreen extends StatefulWidget {
  // 1. استلام الكود من شاشة الـ AddChildScreen
  final String pairingCode;

  const PairingCodeScreen({super.key, required this.pairingCode});

  @override
  State<PairingCodeScreen> createState() => _PairingCodeScreenState();
}

class _PairingCodeScreenState extends State<PairingCodeScreen> {
  final Color navyBlue = const Color(0xFF042459);

  // 2. متغير لحفظ عملية الاستماع عشان نقفلها لما نخرج من الشاشة
  late StreamSubscription<DatabaseEvent> _pairingListener;

  @override
  void initState() {
    super.initState();
    _startListeningForPairing();
  }

  // 3. الميثود السحرية اللي بتراقب الداتابيز في الوقت الفعلي
  void _startListeningForPairing() {
    DatabaseReference codeRef = FirebaseDatabase.instance.ref(
      "pairing_codes/${widget.pairingCode}",
    );

    _pairingListener = codeRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        // لو جهاز الابن دخل الكود بنجاح وحدث الحالة لـ "linked"
        if (data['status'] == 'linked') {
          _pairingListener.cancel(); // إيقاف الاستماع

          if (!mounted) return;

          // إظهار رسالة نجاح للأب
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Device Paired Successfully! 🎉"),
              backgroundColor: Colors.green,
            ),
          );

          // إغلاق شاشة الكود والرجوع للشاشة السابقة (الداشبورد)
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _pairingListener.cancel(); // مهم جداً عشان نمنع تسريب الذاكرة (Memory Leak)
    super.dispose();
  }

  // ميثود صغيرة لتنسيق الكود بشياكة (XXX XXX) زي ما كنت عاملها
  String get formattedCode {
    String c = widget.pairingCode;
    if (c.length == 6) {
      return "${c.substring(0, 3)} ${c.substring(3, 6)}";
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  formattedCode, // استخدام الكود القادم من الشاشة السابقة بعد تنسيقه
                  style: TextStyle(
                    color: navyBlue,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // أضفنا مؤشر تحميل بيلف عشان يدي إحساس إن التطبيق منتظر جهاز الابن
              const CircularProgressIndicator(color: Color(0xFF9ED7EB)),
              const SizedBox(height: 20),

              const Text(
                "Waiting for child device...",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
