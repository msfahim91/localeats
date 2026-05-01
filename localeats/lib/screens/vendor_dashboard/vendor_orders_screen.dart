import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorOrdersScreen extends StatefulWidget {
  final String vendorId;
  const VendorOrdersScreen({super.key, required this.vendorId});
  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white,
        title: const Text('Orders'), automaticallyImplyLeading: false,
        bottom: TabBar(controller: _tab, indicatorColor: Colors.white, labelColor: Colors.white, unselectedLabelColor: Colors.white60, isScrollable: true,
          tabs: const [Tab(text: 'New'), Tab(text: 'Preparing'), Tab(text: 'Delivered'), Tab(text: 'All')]),
      ),
      body: TabBarView(controller: _tab, children: [
        _OrderList(vendorId: widget.vendorId, status: 'placed'),
        _OrderList(vendorId: widget.vendorId, status: 'preparing'),
        _OrderList(vendorId: widget.vendorId, status: 'delivered'),
        _OrderList(vendorId: widget.vendorId, status: null),
      ]),
    );
  }
}

class _OrderList extends StatelessWidget {
  final String vendorId; final String? status;
  const _OrderList({required this.vendorId, this.status});

  @override
  Widget build(BuildContext context) {
    Query q = FirebaseFirestore.instance.collection('orders').where('vendorId', isEqualTo: vendorId);
    if (status != null) q = q.where('status', isEqualTo: status);
    return StreamBuilder<QuerySnapshot>(
      stream: q.snapshots(),
      builder: (_, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('📦', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No ${status ?? ''} orders', style: const TextStyle(color: Colors.grey)),
        ]));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final items = data['items'] as List? ?? [];
            final st = data['status'] ?? 'placed';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('#${data['orderId'].toString().substring(3, 13)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  _StatusBadge(st),
                ]),
                const SizedBox(height: 6),
                Text('👤 ${data['userName'] ?? 'Customer'}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                Text(items.map((i) => '${i['name']} x${i['quantity']}').join(', '),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('৳${(data['total'] ?? 0).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E8B57), fontSize: 15)),
                  Text(data['paymentMethod'] ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ]),
                if (st == 'placed' || st == 'preparing') ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    if (st == 'placed') Expanded(child: ElevatedButton(
                      onPressed: () => docs[i].reference.update({'status': 'preparing'}),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(0, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Accept & Prepare', style: TextStyle(fontSize: 12)))),
                    if (st == 'preparing') Expanded(child: ElevatedButton(
                      onPressed: () => docs[i].reference.update({'status': 'on_the_way'}),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, minimumSize: const Size(0, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Send for Delivery', style: TextStyle(fontSize: 12)))),
                    const SizedBox(width: 8),
                    if (st == 'placed') OutlinedButton(
                      onPressed: () => docs[i].reference.update({'status': 'cancelled'}),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), minimumSize: const Size(80, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Reject', style: TextStyle(fontSize: 12))),
                  ]),
                ],
              ]),
            );
          },
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);
  @override
  Widget build(BuildContext context) {
    Color bg, text;
    String label;
    switch (status) {
      case 'placed': bg = Colors.orange.shade100; text = Colors.orange; label = 'NEW'; break;
      case 'preparing': bg = Colors.blue.shade100; text = Colors.blue; label = 'PREPARING'; break;
      case 'on_the_way': bg = Colors.purple.shade100; text = Colors.purple; label = 'ON THE WAY'; break;
      case 'delivered': bg = const Color(0xFFE8F5E9); text = const Color(0xFF2E8B57); label = 'DELIVERED'; break;
      case 'cancelled': bg = Colors.red.shade100; text = Colors.red; label = 'CANCELLED'; break;
      default: bg = Colors.grey.shade100; text = Colors.grey; label = status.toUpperCase();
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)));
  }
}
