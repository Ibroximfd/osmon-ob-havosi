import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/routes/app_routes.dart';

class OnboardingStep {
  final String title;
  final String desc;
  final Widget icon;
  final List<Color> bg; // gradient colors
  final String action;

  OnboardingStep({
    required this.title,
    required this.desc,
    required this.icon,
    required this.bg,
    required this.action,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 0;
  final PageController _pageController = PageController();

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: "Osmon sizga nima deyapti?",
      desc:
          "O'zbekistonning barcha hududlari uchun aniq va ishonchli ob-havo ma'lumotlari.",
      icon: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0), // primary
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 32),
        child: const Text(
          'O',
          style: TextStyle(
            color: Colors.white,
            fontSize: 60,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bg: const [
        Colors.blueAccent,
        Color(0xFF0D47A1),
      ], // blue-500 to blue-900 equivalent
      action: "Boshlash",
    ),
    OnboardingStep(
      title: "Joylashuvingizni aniqlash",
      desc:
          "Siz turgan joydagi eng aniq ob-havo ma'lumotlarini taqdim etishimiz uchun ruxsat bering.",
      icon: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        margin: const EdgeInsets.only(bottom: 32),
        alignment: Alignment.center,
        child: const Icon(LucideIcons.mapPin, color: Colors.white, size: 48),
      ),
      bg: const [
        Color(0xFF10B981),
        Color(0xFF064E3B),
      ], // emerald-500 to emerald-900
      action: "Ruxsat berish",
    ),
    OnboardingStep(
      title: "Ogohlantirishlar",
      desc:
          "Favqulodda ob-havo o'zgarishlari haqida birinchilardan bo'lib xabardor bo'ling.",
      icon: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        margin: const EdgeInsets.only(bottom: 32),
        alignment: Alignment.center,
        child: const Icon(LucideIcons.bell, color: Colors.white, size: 48),
      ),
      bg: const [
        Color(0xFFF97316),
        Color(0xFF7C2D12),
      ], // orange-500 to orange-900
      action: "Tugatish",
    ),
  ];

  void _handleNext() async {
    if (_step == 1) {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
      } catch (e) {
        // Ignore errors if location services are disabled or denied forever
      }
    }

    if (_step == 2) {
      try {
        await Permission.notification.request();
      } catch (e) {
        // Ignore errors if notification permission is not available
      }
    }

    if (_step < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_onboarding', false);
      if (mounted) {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (val) {
              setState(() {
                _step = val;
              });
            },
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: step.bg,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative background icons
                    Positioned(
                      top: 80,
                      left: 40,
                      child: Opacity(
                        opacity: 0.2,
                        child: const Icon(
                          LucideIcons.sun,
                          size: 120,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 160,
                      right: 40,
                      child: Opacity(
                        opacity: 0.1,
                        child: const Icon(
                          LucideIcons.mapPin,
                          size: 180,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Main Content
                    SafeArea(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              step.icon,
                              Text(
                                step.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                step.desc,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(
                                height: 100,
                              ), // spacing for bottom nav
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Bottom Controls
          Positioned(
            bottom: 48,
            left: 32,
            right: 32,
            child: Column(
              children: [
                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: i == _step ? 32 : 8,
                      decoration: BoxDecoration(
                        color: i == _step
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                // Action Button
                GestureDetector(
                  onTap: _handleNext,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _steps[_step].action,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A), // slate-900 equivalent
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.chevronRight,
                          color: Color(0xFF0F172A),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
