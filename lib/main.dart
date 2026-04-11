import 'package:flutter/material.dart';
import 'screens/app_screen.dart';

void main() async {
  // This line MUST be here before any plugin initializes
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian',
      debugShowCheckedModeBanner: false,
      home: const AppsScreen(),
    );
  }
}
