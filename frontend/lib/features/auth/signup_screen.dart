
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/theme/bondbox_theme.dart';
import '../profile/profile_setup_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController =
      TextEditingController();
  final TextEditingController _nicknameController =
      TextEditingController();
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_passwordController.text !=
        _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore
            .collection("users")
            .doc(user.uid)
            .set({
          "uid": user.uid,
          "fullName": _fullNameController.text.trim(),
          "nickname": _nicknameController.text.trim(),
          "email": _emailController.text.trim(),
          "photoUrl": null,
          "createdAt": Timestamp.now(),
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => const ProfileSetupScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup failed")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BondGradientBackground(
        gradient: BondBoxTheme.skyGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 30, vertical: 20),
            child: Column(
              children: [
                FadeInDown(
                  child: Text(
                    "Join the Chaos",
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(
                          color: Colors.white,
                          fontSize: 40,
                        ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeIn(
                  child: GestureDetector(
                    onTap: () {},
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Colors.white.withOpacity(0.5),
                          child: const Icon(
                            Icons.person_add_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding:
                                const EdgeInsets.all(4),
                            decoration:
                                const BoxDecoration(
                              color:
                                  BondBoxTheme.hotPink,
                              shape:
                                  BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeInLeft(
                  child: BondTextField(
                    controller: _fullNameController,
                    hintText: "Full Name",
                    prefixIcon:
                        Icons.person_rounded,
                  ),
                ),
                const SizedBox(height: 15),
                FadeInRight(
                  child: BondTextField(
                    controller:
                        _nicknameController,
                    hintText:
                        "Nickname (Displayed in groups)",
                    prefixIcon: Icons
                        .alternate_email_rounded,
                  ),
                ),
                const SizedBox(height: 15),
                FadeInLeft(
                  child: BondTextField(
                    controller: _emailController,
                    hintText: "Email",
                    prefixIcon:
                        Icons.email_rounded,
                  ),
                ),
                const SizedBox(height: 15),
                FadeInRight(
                  child: BondTextField(
                    controller:
                        _passwordController,
                    hintText: "Password",
                    prefixIcon:
                        Icons.lock_rounded,
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 15),
                FadeInLeft(
                  child: BondTextField(
                    controller:
                        _confirmPasswordController,
                    hintText:
                        "Confirm Password",
                    prefixIcon: Icons
                        .lock_outline_rounded,
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  child: BondButton(
                    text: _isLoading ? "Creating..." : "Enter the Chaos 🚀",
                    onPressed: () {
                      if (!_isLoading) {
                        _signUp();
                      }
                    },
                    color: Colors.white,
                    textColor: BondBoxTheme.softPurple,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold),
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