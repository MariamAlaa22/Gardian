import 'package:flutter/material.dart';
import 'package:gardians/screens/profile/simple_settings_scaffold.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleSettingsScaffold(
      title: 'Terms of Service',
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'By using SafeGuard, you agree to use monitoring tools responsibly and in compliance with local laws. '
          'Parents remain responsible for consent, account security, and protected-device configuration.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF526077),
            height: 1.45,
          ),
        ),
      ),
    );
  }
}
