import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  final _numberController = TextEditingController();
  String _selectedMethod = 'bKash';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _methodTypes = [
    {'name': 'bKash', 'icon': '💳', 'color': 0xFFE91E8C},
    {'name': 'Nagad', 'icon': '💰', 'color': 0xFFFF6600},
    {'name': 'Rocket', 'icon': '🚀', 'color': 0xFF6B1C8C},
    {'name': 'Cash on Delivery', 'icon': '💵', 'color': 0xFF4CAF50},
  ];

  Future<void> _addPaymentMethod() async {
    if (_selectedMethod != 'Cash on Delivery' && _numberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter account number'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final newMethod = {
        'method': _selectedMethod,
        'number': _selectedMethod == 'Cash on Delivery' ? 'Pay when delivered' : _numberController.text.trim(),
        'addedAt': DateTime.now().toIso8601String(),
      };
      await FirestoreService.arrayUnion('paymentMethods', newMethod);
      _numberController.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment method added!'), backgroundColor: Color(0xFF2E8B57)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    setState(() => _isLoading = false);
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: _methodTypes.map((m) => GestureDetector(
            onTap: () => setModalState(() => _selectedMethod = m['name']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedMethod == m['name'] ? Color(m['color'] as int).withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _selectedMethod == m['name'] ? Color(m['color'] as int) : Colors.transparent)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(m['icon'] as String, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(m['name'] as String, style: TextStyle(fontWeight: FontWeight.w500, color: _selectedMethod == m['name'] ? Color(m['color'] as int) : Colors.black)),
              ])),
          )).toList()),
          const SizedBox(height: 12),
          if (_selectedMethod != 'Cash on Delivery') ...[
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter $_selectedMethod number (e.g. 01XXXXXXXXX)',
                prefixIcon: const Icon(Icons.phone_outlined),
                filled: true, fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 12),
          ],
          ElevatedButton(
            onPressed: _isLoading ? null : _addPaymentMethod,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Add Method', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, title: const Text('Payment Methods'), elevation: 0),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final methods = data?['paymentMethods'] as List? ?? [];
          final balance = data?['refundBalance'] ?? 0;
          return Column(children: [
            Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
              if (methods.isEmpty)
                Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(children: [
                  const Text('💳', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('No payment methods added', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Add bKash, Nagad or Cash on Delivery', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ]))),
              ...methods.map((m) {
                final method = m as Map<String, dynamic>;
                final type = _methodTypes.firstWhere((t) => t['name'] == method['method'], orElse: () => {'name': 'Other', 'icon': '💳', 'color': 0xFF2E8B57});
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                  child: Row(children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(color: Color(type['color'] as int).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(type['icon'] as String, style: const TextStyle(fontSize: 24)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(method['method'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(method['number'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ])),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => FirestoreService.arrayRemove('paymentMethods', method),
                    ),
                  ]),
                );
              }),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF2E8B57)), const SizedBox(width: 12), const Text('Refund Balance', style: TextStyle(fontWeight: FontWeight.bold))]),
                  Text('৳ $balance', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E8B57))),
                ]),
              ),
            ])),
            Padding(padding: const EdgeInsets.all(16), child: ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Payment Method'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )),
          ]);
        },
      ),
    );
  }
}
