// lib/features/onboarding/presentation/pages/onboarding_main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parkirin/features/authentication/presentation/pages/login_page.dart';
import 'package:parkirin/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingMainScreen extends StatefulWidget {
  const OnboardingMainScreen({super.key});

  @override
  State<OnboardingMainScreen> createState() => _OnboardingMainScreenState();
}

class _OnboardingMainScreenState extends State<OnboardingMainScreen> {
  final PageController _controller = PageController();
  bool _onLastPage = false;

  static const List<Map<String, String>> onboardingData = [
    {
      'lottieAsset': 'assets/animations/click_animation.json',
      'text': 'Semua Kebutuhan Parkirmu Cuman Modal Klik Aja!',
    },
    {
      'lottieAsset': 'assets/animations/cash_animation.json',
      'text': 'Belum siap pakai cashless? masih bisa pakai cash kok!',
    },
    {
      'lottieAsset': 'assets/animations/history_animation.json',
      'text': 'Semua riwayat penting tercatat disini!',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setStatusBarColor());
  }

  void _setStatusBarColor() {
    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  void _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _onLastPage = (index == onboardingData.length - 1);
              });
            },
            itemBuilder: (context, index) => OnboardingScreen(
              lottieAsset: onboardingData[index]['lottieAsset']!,
              text: onboardingData[index]['text']!,
            ),
          ),
          _buildNavigation(context),
        ],
      ),
    );
  }

  Widget _buildNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () =>
                  _controller.jumpToPage(onboardingData.length - 1),
              child: Text(
                'Skip',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: onboardingData.length,
              effect: WormEffect(
                dotColor: theme.colorScheme.secondary,
                activeDotColor: theme.colorScheme.primary,
                spacing: 16,
              ),
            ),
            TextButton(
              onPressed: _onLastPage
                  ? _goToLogin
                  : () => _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      ),
              child: Text(
                _onLastPage ? 'Done' : 'Next',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
