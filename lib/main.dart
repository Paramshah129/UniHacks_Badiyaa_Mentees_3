import 'package:flutter/material.dart';
import 'features/onboarding/onboarding_screen.dart'; // adjust if needed

void main() {
  runApp(const BondBoxApp());
}

class BondBoxApp extends StatelessWidget {
  const BondBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BondBox',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}