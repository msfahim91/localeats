import 'package:flutter/material.dart';
import 'dart:async';
import '../home/home_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _currentStep = 0;
  late Timer _timer;
  int _eta = 12;

  final List<Map<String, dynamic>> _steps = [
    {'title': 'Order Placed', 'subtitle': 'Confirmed', 'time': '2:30 PM', 'icon': Icons.check_circle},
    {'title': 'Being Prepared', 'subtitle': 'In kitchen', 'time': '2:35 PM', 'icon': Icons.restaurant},
    {'title': 'On the Way', 'subtitle': 'En route', 'time': '2:48 PM', 'icon': Icons.delivery_dining},
    {'title': 'Delivered', 'subtitle': 'Expected', 'time': '3:00 PM', 'icon': Icons.home},
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (_currentStep < _steps.length - 1) {
        setState(() {
          _currentStep++;
          if (_eta > 0) _eta -= 3;
        });
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFF7F50),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const HomeScreen())),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order Tracking 🛵',
                            style: TextStyle(color: Colors.white,
                              fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Order #LE-20240225-4821',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _currentStep >= _steps.length - 1
                            ? '✅ Delivered!'
                            : 'Arriving in $_eta minutes',
                          style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Map placeholder
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFFE8F5E9),
                    ),
                    child: Stack(
                      children: [
                        // Grid lines
                        CustomPaint(
                          size: const Size(double.infinity, 180),
                          painter: _GridPainter(),
                        ),
                        // Route animation
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text('🏪', style: TextStyle(fontSize: 32)),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(height: 2, color: const Color(0xFF2E8B57)),
                                    Align(
                                      alignment: Alignment(_currentStep >= 2 ? 0.5 : -1, 0),
                                      child: const Text('🛵', style: TextStyle(fontSize: 28)),
                                    ),
                                  ],
                                ),
                              ),
                              const Text('🏠', style: TextStyle(fontSize: 32)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status Steps
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      children: List.generate(_steps.length, (i) {
                        final step = _steps[i];
                        final isDone = i <= _currentStep;
                        final isCurrent = i == _currentStep;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: isDone ? const Color(0xFF2E8B57) : Colors.grey[200],
                                    shape: BoxShape.circle,
                                    boxShadow: isCurrent ? [BoxShadow(
                                      color: const Color(0xFF2E8B57).withOpacity(0.4),
                                      blurRadius: 8, spreadRadius: 2)] : null,
                                  ),
                                  child: Icon(step['icon'],
                                    color: isDone ? Colors.white : Colors.grey,
                                    size: 18),
                                ),
                                if (i < _steps.length - 1)
                                  Container(
                                    width: 2, height: 40,
                                    color: isDone ? const Color(0xFF2E8B57) : Colors.grey[200]),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(step['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDone ? Colors.black : Colors.grey,
                                      )),
                                    Text('${step['time']} • ${step['subtitle']}',
                                      style: TextStyle(
                                        color: Colors.grey[500], fontSize: 12)),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rider Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(child: Text('👨', style: TextStyle(fontSize: 28))),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Rahim • Your Rider',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                  Text(' 4.9 • Honda CB125',
                                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40, height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E8B57),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E8B57).withOpacity(0.1)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
