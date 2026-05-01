import 'package:flutter/material.dart';

class VouchersScreen extends StatelessWidget {
  const VouchersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final vouchers = [
      {'code': 'LOCALEATS10', 'desc': '10% off on any order', 'expiry': 'Dec 31, 2026', 'color': 0xFF2E8B57, 'used': false},
      {'code': 'WELCOME20', 'desc': '20% off on first order', 'expiry': 'May 31, 2026', 'color': 0xFFFF7F50, 'used': true},
      {'code': 'FREESHIP', 'desc': 'Free delivery on next order', 'expiry': 'Jun 15, 2026', 'color': 0xFF1877F2, 'used': false},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, title: const Text('My Vouchers'), elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ...vouchers.map((v) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
          child: Stack(children: [
            if (v['used'] as bool) Positioned.fill(child: Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('USED', style: TextStyle(color: Colors.grey, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4))))),
            Padding(padding: const EdgeInsets.all(16), child: Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: Color(v['color'] as int).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.confirmation_number_outlined, color: Color(v['color'] as int), size: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v['code'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(v['color'] as int))),
                Text(v['desc'] as String, style: const TextStyle(fontSize: 13)),
                Text('Expires: ${v['expiry']}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ])),
              if (!(v['used'] as bool)) ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${v['code']} copied!'), backgroundColor: const Color(0xFF2E8B57))),
                style: ElevatedButton.styleFrom(backgroundColor: Color(v['color'] as int), foregroundColor: Colors.white, minimumSize: const Size(60, 34), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Use', style: TextStyle(fontSize: 12)),
              ),
            ])),
          ]),
        )),
      ]),
    );
  }
}
