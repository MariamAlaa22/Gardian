import 'package:flutter/material.dart';
import 'package:gardians/screens/commdetails.dart';
import 'package:gardians/screens/location.dart';
import 'package:gardians/screens/otp.dart';
import 'package:gardians/screens/pairing.dart';

class TestHubScreen extends StatefulWidget {
  const TestHubScreen({super.key});

  @override
  State<TestHubScreen> createState() => _TestHubScreenState();
}

class _TestHubScreenState extends State<TestHubScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guardian Test Hub')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Open Test Screens', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _navButton(context, 'Parent Code', const PairingCodeScreen()),
          _navButton(context, 'Child Code', const OTPScreen()),
          _navButton(context, 'Communication Screen', const CommunicationDetailsScreen()),
          _navButton(context, 'Geo Screen', const ChildLocationScreen()),
        ],
      ),
    );
  }

  Widget _navButton(BuildContext context, String title, Widget screen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        child: Text(title),
      ),
    );
  }
}
