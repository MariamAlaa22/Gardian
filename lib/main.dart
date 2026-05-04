import 'package:flutter/material.dart';
import 'package:gardians/screens/guardians_main_screen.dart';

void main() {
  runApp(const GuardianApp());
}

class GuardianApp extends StatelessWidget {
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardians',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF042459)),
        useMaterial3: true,
      ),
      home: const GuardiansMainScreen(),
    );
  }
}
