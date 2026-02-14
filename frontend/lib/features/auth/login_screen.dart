

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/theme/bondbox_theme.dart';
import 'signup_screen.dart';
import '../profile/profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Initialize points if they don't exist
      if (userCredential.user != null) {
        await _initializeUserPoints(userCredential.user!.uid);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeUserPoints(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final updates = <String, dynamic>{};

        // Add weeklyPoints if missing
        if (data?['weeklyPoints'] == null) {
          updates['weeklyPoints'] = 0;
        }

        // Add totalPoints if missing (200 starting bonus)
        if (data?['totalPoints'] == null) {
          updates['totalPoints'] = 200;
        }

        // Only update if there are missing fields
        if (updates.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update(updates);
          print('✅ Initialized points for user $userId: $updates');
        }
      }
    } catch (e) {
      print('Error initializing points: $e');
      // Don't block login if this fails
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BondGradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40), // Top spacing
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
                          child: BondTextField(
                            controller: _emailController,
                            hintText: "Email",
                            prefixIcon: Icons.email_rounded,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeInRight(
                          child: BondTextField(
                            controller: _passwordController,
                            hintText: "Password",
                            prefixIcon: Icons.lock_rounded,
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(height: 40),
                        FadeInUp(
                          child: BondButton(
                            text: _isLoading ? "Logging in..." : "Login",
                            onPressed: () {
                              if (!_isLoading) {
                                _login();
                              }
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
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
                                MaterialPageRoute(
                                    builder: (context) => const SignupScreen()),
                              );
                            },
                            child: const Text(
                              "New here? Create Account",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const Spacer(),
                        FadeInUp(
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Text(
                              "No fake vibes allowed. ✌️",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}