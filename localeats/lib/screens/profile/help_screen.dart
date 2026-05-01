import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'q': 'How do I track my order?', 'a': 'Go to your order and tap "Track Order" to see real-time updates.'},
      {'q': 'How do I cancel an order?', 'a': 'You can cancel within 2 minutes of placing. Go to Order History and tap Cancel.'},
      {'q': 'How do refunds work?', 'a': 'Refunds are processed within 3-5 business days to your original payment method.'},
      {'q': 'How do I become a vendor?', 'a': 'Tap "LocalEats for business" in your profile to register as a vendor.'},
      {'q': 'What is the delivery fee?', 'a': 'Delivery fee is ৳40 flat rate. Free delivery on orders above ৳500.'},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, title: const Text('Help Center'), elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF2E8B57), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.headset_mic_outlined, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Need more help?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('Contact our support team', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF2E8B57), minimumSize: const Size(120, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Chat with us')),
            ])),
          ])),
        const SizedBox(height: 20),
        const Text('Frequently Asked Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...faqs.map((faq) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: ExpansionTile(
            title: Text(faq['q']!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Text(faq['a']!, style: TextStyle(color: Colors.grey[600], fontSize: 13)))],
          ),
        )),
      ]),
    );
  }
}
