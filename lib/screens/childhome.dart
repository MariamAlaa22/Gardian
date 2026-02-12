import 'package:flutter/material.dart';

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});

  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 80, bottom: 40, left: 25, right: 25),
            decoration: BoxDecoration(
              color: navyBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withValues(alpha:0.1),
                  child: const Icon(Icons.videogame_asset, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Hello, Hero! 🛡️",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
              ],
            ),
          ),

          const Spacer(flex: 1), 

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha:0.05), 
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.green.withValues(alpha:0.2), width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha:0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.security_rounded, color: Colors.green, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Active Protection",
                          style: TextStyle(color: navyBlue, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Gardian is keeping your device safe in the background.",
                          style: TextStyle(color: navyBlue.withValues(alpha:0.6), fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(flex: 2),

          Opacity(
            opacity: 0.5,
            child: Column(
              children: [
                Icon(Icons.extension_rounded, size: 40, color: navyBlue),
                const SizedBox(height: 10),
                const Text("Gardian Game Coming Soon", 
                  style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}