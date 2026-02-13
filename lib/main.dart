import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/login_screen.dart';
=======
import 'core/theme/bondbox_theme.dart';
>>>>>>> Stashed changes
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

<<<<<<< Updated upstream
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
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
      home: OnboardingScreen(),
    );
  }
}
=======
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BondBox',
      theme: BondBoxTheme.lightTheme,
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
>>>>>>> Stashed changes
