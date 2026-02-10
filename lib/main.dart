import 'package:flutter/material.dart';
import 'package:gardians/screens/Signup.dart';
import 'package:gardians/screens/sign_in.dart';
import 'package:gardians/screens/splash.dart';
import 'package:gardians/screens/welcome.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/" ,
      routes: {
        "/":(context)=> const Splash(),
        "/welcome":(context)=> const Welcome(),
        "/sign_in":(context)=> const SignIn(),
        "/SignUp":(context)=> const Signup(),
      },
    );
  }
}