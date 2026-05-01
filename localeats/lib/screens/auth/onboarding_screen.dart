import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'emoji': '🥗',
      'title': 'Local Food At Your Door',
      'subtitle': 'Order from the best home chefs and local restaurants in Bogura, delivered fresh to your doorstep.',
      'color': const Color(0xFF2E8B57),
      'btnText': 'Next →',
    },
    {
      'emoji': '🛵',
      'title': 'Fast & Reliable Delivery',
      'subtitle': 'Get your food delivered in just 15-25 minutes. Hot, fresh and on time — every time.',
      'color': const Color(0xFFFF7F50),
      'btnText': 'Next →',
    },
    {
      'emoji': '💚',
      'title': 'Support Local Businesses',
      'subtitle': 'Only 10% commission — support local vendors and help your community grow together.',
      'color': const Color(0xFF1877F2),
      'btnText': 'Get Started 🚀',
    },
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _skip() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemCount: _pages.length,
        itemBuilder: (_, i) {
          final page = _pages[i];
          return Container(
            color: page['color'] as Color,
            child: SafeArea(child: Column(children: [
              const Spacer(),
              Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle),
                child: Center(child: Text(page['emoji'], style: const TextStyle(fontSize: 90)))),
              const Spacer(),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Column(children: [
                Text(page['title'], textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)),
                const SizedBox(height: 16),
                Text(page['subtitle'], textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
              ])),
              const Spacer(),
              // Dots
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pages.length, (j) =>
                Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: _currentPage == j ? 24 : 8, height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == j ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(4))))),
              const SizedBox(height: 32),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: [
                SizedBox(width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: page['color'] as Color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 0),
                    child: Text(page['btnText'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 12),
                if (_currentPage < _pages.length - 1)
                  TextButton(onPressed: _skip, child: const Text('Skip', style: TextStyle(color: Colors.white70, fontSize: 15)))
                else const SizedBox(height: 40),
              ])),
              const SizedBox(height: 24),
            ])),
          );
        },
      ),
    );
  }
}
