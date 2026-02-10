import 'package:flutter/material.dart';
import 'package:gardians/screens/permission.dart';
import 'package:pinput/pinput.dart';
import 'dart:async'; 

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _seconds = 30;
  late Timer _timer;

  final Color skyBlue = const Color(0xFF9ED7EB);
  final Color navyBlue = const Color(0xFF042459);

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer(); 
  }

  @override
  void dispose() {
    _timer.cancel(); 
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: "1", style: TextStyle(color: navyBlue)),
                    TextSpan(text: " / 2", style: TextStyle(color: navyBlue.withValues(alpha: 0.5))),
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
                    "Verification",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: navyBlue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter the code sent to your email",
                    style: TextStyle(color: navyBlue.withValues(alpha: 0.5), fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "00:${_seconds.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _seconds < 10 ? Colors.red : const Color(0xFF5AB9D9),
              ),
            ),

            const SizedBox(height: 15),

            Pinput(
              length: 4,
              controller: _otpController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: const Color(0xFF9ED7EB), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: navyBlue,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              onPressed: () {
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text("Paired Successfully!", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  ),
                );

                
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ParentGrantPermissions()),
                );
              },
              child: const Text("Verify", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't receive code? ", style: TextStyle(color: navyBlue.withValues(alpha: 0.5))),
                GestureDetector(
                  onTap: _seconds == 0 ? () {
                    setState(() { _seconds = 30; });
                    startTimer();
                  } : null,
                  child: Text(
                    "Resend",
                    style: TextStyle(
                      color: _seconds == 0 ? const Color(0xFF5AB9D9) : navyBlue.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}