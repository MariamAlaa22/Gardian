import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

    final Color navyBlue = const Color(0xFF042459);

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, "/welcome");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
            'assets/animation/My kick us bear.json', 
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
              Text(
              "Gardians",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color:navyBlue , 
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
