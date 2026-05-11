import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home_screen.dart';
import 'rating_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (_, snap) {
          final data = snap.data?.data() as Map<String, dynamic>? ?? {};
          final status = data['status'] ?? 'placed';
          final steps = _getSteps();
          final currentStep = _getCurrentStep(status);
          final eta = _getETA(status);
          final rated = data['rated'] ?? false;

          return Column(children: [
            Container(padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFFF7F50),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                    child: const Icon(Icons.arrow_back, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Order Tracking 🛵', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Order #$orderId', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ])),
                ]),
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(eta, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ])),
              ])),

            Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
              // Map
              Container(height: 150, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: const Color(0xFFE8F5E9)),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('🏪', style: TextStyle(fontSize: 32)),
                  Expanded(child: Stack(alignment: Alignment.center, children: [
                    Container(height: 2, color: const Color(0xFF2E8B57)),
                    Align(alignment: status == 'on_the_way' ? Alignment.center : (status == 'delivered' ? Alignment.centerRight : Alignment.centerLeft),
                      child: const Text('🛵', style: TextStyle(fontSize: 24))),
                  ])),
                  const Text('🏠', style: TextStyle(fontSize: 32)),
                ]))),
              const SizedBox(height: 16),

              // Steps
              Container(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                child: Column(children: List.generate(steps.length, (i) {
                  final isDone = i <= currentStep;
                  final isCurrent = i == currentStep;
                  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Column(children: [
                      Container(width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: isDone ? const Color(0xFF2E8B57) : Colors.grey[200],
                          shape: BoxShape.circle,
                          boxShadow: isCurrent ? [BoxShadow(color: const Color(0xFF2E8B57).withOpacity(0.4), blurRadius: 8, spreadRadius: 2)] : null),
                        child: Icon(steps[i]['icon'] as IconData, color: isDone ? Colors.white : Colors.grey, size: 16)),
                      if (i < steps.length - 1) Container(width: 2, height: 36, color: isDone ? const Color(0xFF2E8B57) : Colors.grey[200]),
                    ]),
                    const SizedBox(width: 14),
                    Expanded(child: Padding(padding: const EdgeInsets.only(top: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(steps[i]['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? Colors.black : Colors.grey)),
                      Text(steps[i]['sub'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      const SizedBox(height: 20),
                    ]))),
                  ]);
                }))),
              const SizedBox(height: 14),

              // Order Details
              Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Vendor', style: TextStyle(color: Colors.grey[600])),
                    Text(data['vendorName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Total', style: TextStyle(color: Colors.grey[600])),
                    Text('৳${(data['total'] ?? 0).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E8B57))),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Payment', style: TextStyle(color: Colors.grey[600])),
                    Text(data['paymentMethod'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ]),
                ])),

              if (status == 'on_the_way' || status == 'delivered') ...[
                const SizedBox(height: 14),
                Container(padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                  child: Row(children: [
                    Container(width: 46, height: 46, decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                      child: const Center(child: Text('👨', style: TextStyle(fontSize: 24)))),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Rahim • Your Rider', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(children: [Icon(Icons.star_rounded, color: Colors.amber, size: 13), Text(' 4.9 • Honda CB125', style: TextStyle(color: Colors.grey, fontSize: 12))]),
                    ])),
                    Container(width: 38, height: 38, decoration: const BoxDecoration(color: Color(0xFF2E8B57), shape: BoxShape.circle),
                      child: const Icon(Icons.phone, color: Colors.white, size: 18)),
                  ])),
              ],

              if (status == 'delivered') ...[
                const SizedBox(height: 14),
                if (!rated) ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RatingScreen(
                    orderId: orderId,
                    vendorId: data['vendorId'] ?? '',
                    vendorName: data['vendorName'] ?? ''))),
                  icon: const Icon(Icons.star_outlined),
                  label: const Text('Rate Your Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ])),
          ]);
        },
      )),
    );
  }

  List<Map<String, dynamic>> _getSteps() => [
    {'title': 'Order Placed', 'sub': 'Waiting for vendor', 'icon': Icons.check_circle_outline},
    {'title': 'Being Prepared', 'sub': 'Vendor is cooking', 'icon': Icons.restaurant_outlined},
    {'title': 'On the Way', 'sub': 'Rider is coming', 'icon': Icons.delivery_dining_outlined},
    {'title': 'Delivered', 'sub': 'Enjoy your meal!', 'icon': Icons.home_outlined},
  ];

  int _getCurrentStep(String status) {
    switch (status) {
      case 'placed': return 0;
      case 'preparing': return 1;
      case 'on_the_way': return 2;
      case 'delivered': return 3;
      default: return 0;
    }
  }

  String _getETA(String status) {
    switch (status) {
      case 'placed': return 'Waiting for vendor to accept...';
      case 'preparing': return 'Being prepared — 15-20 min';
      case 'on_the_way': return 'On the way — arriving soon!';
      case 'delivered': return 'Delivered!';
      default: return 'Processing...';
    }
  }
}
