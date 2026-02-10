import 'package:flutter/material.dart';

class PairingCodeScreen extends StatelessWidget {
  final String pairCode = "582 941"; // ده رقم تجريبي، الـ Backend هو اللي بيبعته
  final Color navyBlue = const Color(0xFF042459);

  const PairingCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: CloseButton(color: navyBlue)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Pairing Code", style: TextStyle(color: navyBlue, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(
                "Enter this code on your child's device to link it to your account.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              
              // عرض الكود بشكل شيك
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF9ED7EB), width: 2),
                ),
                child: Text(
                  pairCode,
                  style: TextStyle(color: navyBlue, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 5),
                ),
              ),
              
              const SizedBox(height: 50),
              //const CircularProgressIndicator(), 
              const SizedBox(height: 20),
              const Text("Waiting for child device...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}