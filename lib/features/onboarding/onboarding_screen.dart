import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/theme/bondbox_theme.dart';
import '../auth/login_screen.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _screens = [
    OnboardingData(
      title: "Friendships deserve more than just chats.",
      subtitle: "Turn your group chaos into memories.",
      buttonText: "Get Started",
      gradient: BondBoxTheme.primaryGradient,
      icon: Icons.favorite_rounded,
    ),
    OnboardingData(
      title: "Play. Roast. Compete.",
      subtitle: "Compete with friends and earn points for being the funniest.",
      buttonText: "Next",
      gradient: BondBoxTheme.skyGradient,
      icon: Icons.sports_esports_rounded,
    ),
    OnboardingData(
      title: "Lock moments. Unlock nostalgia.",
      subtitle: "Create time capsules to reveal memories in the future.",
      buttonText: "Continue",
      gradient: BondBoxTheme.primaryGradient,
      icon: Icons.lock_clock_rounded,
    ),
    OnboardingData(
      title: "Let’s build your friendship universe.",
      subtitle: "The chaos is waiting for you.",
      buttonText: "Create Account",
      gradient: BondBoxTheme.skyGradient,
      icon: Icons.rocket_launch_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _screens.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return OnboardingPageView(
            data: _screens[index],
            onNext: () {
              if (index < _screens.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          );
        },
      ),
    );
  }
}


class OnboardingData {
  final String title;
  final String subtitle;
  final String buttonText;
  final LinearGradient gradient;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.gradient,
    required this.icon,
  });
}

class OnboardingPageView extends StatelessWidget {
  final OnboardingData data;
  final VoidCallback onNext;

  const OnboardingPageView({
    super.key,
    required this.data,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return BondGradientBackground(
      gradient: data.gradient,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.icon,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 800),
                child: Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                      ),
                ),
              ),
              const SizedBox(height: 60),
              FadeIn(
                delay: const Duration(milliseconds: 500),
                child: BondButton(
                  text: data.buttonText,
                  onPressed: onNext,
                  color: Colors.white,
                  textColor: BondBoxTheme.softPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
