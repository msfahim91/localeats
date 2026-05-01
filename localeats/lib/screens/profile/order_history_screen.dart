import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/order_service.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, title: const Text('Order History'), elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
        stream: OrderService.getUserOrders(uid),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF2E8B57)));
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🛍️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('No orders yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Your order history will appear here', style: TextStyle(color: Colors.grey[600])),
          ]));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final status = data['status'] ?? 'placed';
              final items = data['items'] as List? ?? [];
              final itemsText = items.map((i) => '${i['name']} x${i['quantity']}').join(', ');
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      const Text('🏪', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(data['vendorName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ]),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'delivered' ? const Color(0xFFE8F5E9) : status == 'placed' ? Colors.blue.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20)),
                      child: Text(status.toUpperCase(),
                        style: TextStyle(color: status == 'delivered' ? const Color(0xFF2E8B57) : status == 'placed' ? Colors.blue : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold))),
                  ]),
                  const SizedBox(height: 8),
                  Text(itemsText, style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${data['paymentMethod'] ?? ''} • #${(data['orderId'] ?? '').toString().substring(0, 10)}...',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    Text('৳${(data['total'] ?? 0).toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E8B57), fontSize: 15)),
                  ]),
                ])),
              );
            },
          );
        },
      ),
    );
  }
}
