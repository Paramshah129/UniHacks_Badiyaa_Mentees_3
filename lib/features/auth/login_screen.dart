import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/theme/bondbox_theme.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BondGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  child: Text(
                    "BondBox",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 48,
                          letterSpacing: -2,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    "Welcome back to the chaos.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ),
                const SizedBox(height: 60),
                FadeInLeft(
                  child: const BondTextField(
                    hintText: "Email",
                    prefixIcon: Icons.email_rounded,
                  ),
                ),
                const SizedBox(height: 20),
                FadeInRight(
                  child: const BondTextField(
                    hintText: "Password",
                    prefixIcon: Icons.lock_rounded,
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  child: BondButton(
                    text: "Login",
                    onPressed: () {
                      // Login Logic
                    },
                    color: Colors.white,
                    textColor: BondBoxTheme.softPurple,
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
                    label: const Text("Continue with Google"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "New here? Create Account",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Spacer(),
                FadeInUp(
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "No fake vibes allowed. ✌️",
                      style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
