import 'package:flutter/material.dart';
import 'package:gardians/game/peat/guardians_peat_game_screen.dart';

/// App entry that hosts the Peat full-screen experience.
class GuardiansMainScreen extends StatelessWidget {
  const GuardiansMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: GuardiansPeatGameScreen(),
    );
  }
}
