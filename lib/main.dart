import 'package:flutter/material.dart';
import 'package:gardians/screens/profile/profile.dart';

void main() {
  runApp(const GuardianApp());
}

class GuardianApp extends StatelessWidget {
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian',
      debugShowCheckedModeBanner: false,
      home: const ProfileScreen(),
    );
  }
}
