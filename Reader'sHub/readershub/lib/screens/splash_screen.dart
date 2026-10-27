import 'package:flutter/material.dart';
import 'dart:async';

const Color nebulaPurple = Color(0xFF5E35B1);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 7), () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: nebulaPurple,
      body: Center(
        child: Image.asset('assets/splash.png'),
      ),
    );
  }
}
