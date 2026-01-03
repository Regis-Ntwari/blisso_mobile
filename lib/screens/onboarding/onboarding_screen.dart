import 'dart:async';
import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

/// ---------------------------------------------------------------------------
/// MODEL
/// ---------------------------------------------------------------------------
class OnboardingItem {
  final String image;
  final String title;
  final String description;

  const OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}

/// ---------------------------------------------------------------------------
/// SCREEN
/// ---------------------------------------------------------------------------
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  static const Duration _autoScrollInterval = Duration(seconds: 4);

  Timer? _autoScrollTimer;
  int _currentIndex = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      image: 'assets/images/peace.png',
      title: 'Welcome',
      description: 'Discover meaningful connections and new experiences.',
    ),
    OnboardingItem(
      image: 'assets/images/hold.png',
      title: 'Connect',
      description: 'Chat, share moments, and stay in touch effortlessly.',
    ),
    OnboardingItem(
      image: 'assets/images/foster.png',
      title: 'Started',
      description: 'Create your profile and begin your journey today.',
    ),
    OnboardingItem(
      image: 'assets/images/heart.png',
      title: 'Peace',
      description: 'Create your profile and begin your journey today.',
    ),
    OnboardingItem(
      image: 'assets/images/handshake.png',
      title: 'Started',
      description: 'Create your profile and begin your journey today.',
    ),
  ];

  /// -------------------------------------------------------------------------
  /// LIFECYCLE
  /// -------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// -------------------------------------------------------------------------
  /// AUTO SCROLL LOGIC
  /// -------------------------------------------------------------------------
  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (_currentIndex < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        _autoScrollTimer?.cancel();
      }
    });
  }

  void _resetAutoScroll() {
    _autoScrollTimer?.cancel();
    _startAutoScroll();
  }

  /// -------------------------------------------------------------------------
  /// NAVIGATION
  /// -------------------------------------------------------------------------
  void _finishOnboarding() {
    _autoScrollTimer?.cancel();

    Routemaster.of(context).replace('/register/EMAIL');
  }

  void _onNextPressed() {
    _autoScrollTimer?.cancel();

    if (_currentIndex == _pages.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    }
  }

  /// -------------------------------------------------------------------------
  /// UI
  /// -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            /// Skip Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(
                      color: isLightTheme
                          ? Colors.black.withOpacity(0.5)
                          : Colors.grey.shade400),
                ),
              ),
            ),

            /// Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  _resetAutoScroll();
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          item.image,
                          height: index == 5 ? 400 : 280,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentIndex == index ? 20 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? GlobalColors.primaryColor
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Next / Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ButtonComponent(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  onTap: _onNextPressed,
                  text: _currentIndex == _pages.length - 1
                      ? 'Get Started'
                      : 'Next',
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
