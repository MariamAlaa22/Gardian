import 'package:flutter/material.dart';
import 'package:gardians/screens/profile/profile_constants.dart';

class SimpleSettingsScaffold extends StatelessWidget {
  const SimpleSettingsScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.pageBackground,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 151, 207, 220),
        elevation: 0,
        iconTheme: const IconThemeData(color: ProfileColors.navyBlue),
        title: Text(
          title,
          style: const TextStyle(
            color: ProfileColors.navyBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: child,
    );
  }
}
