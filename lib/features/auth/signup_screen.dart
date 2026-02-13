import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/theme/bondbox_theme.dart';
import '../profile/profile_setup_screen.dart';


class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BondGradientBackground(
        gradient: BondBoxTheme.skyGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                FadeInDown(
                  child: Text(
                    "Join the Chaos",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 40,
                        ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeIn(
                  child: GestureDetector(
                    onTap: () {
                      // Profile Photo Upload
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.5),
                          child: const Icon(Icons.person_add_rounded, size: 40, color: Colors.white),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: BondBoxTheme.hotPink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeInLeft(
                  child: const BondTextField(
                    hintText: "Full Name",
                    prefixIcon: Icons.person_rounded,
                  ),
                ),
                const SizedBox(height: 15),
                FadeInRight(
                  child: const BondTextField(
                    hintText: "Nickname (Displayed in groups)",
                    prefixIcon: Icons.alternate_email_rounded,
                  ),
                ),
                const SizedBox(height: 15),
                FadeInLeft(
                  child: const BondTextField(
                    hintText: "Email",
                    prefixIcon: Icons.email_rounded,
                  ),
                ),
                const SizedBox(height: 15),
                FadeInRight(
                  child: const BondTextField(
                    hintText: "Password",
                    prefixIcon: Icons.lock_rounded,
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 15),
                FadeInLeft(
                  child: const BondTextField(
                    hintText: "Confirm Password",
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  child: BondButton(
                    text: "Enter the Chaos 🚀",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
                      );
                    },
                    color: Colors.white,
                    textColor: BondBoxTheme.softPurple,
                  ),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
