import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vendor_orders_screen.dart';
import 'vendor_menu_screen.dart';
import 'vendor_profile_edit_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});
  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _currentIndex = 0;
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: [
        _DashboardTab(uid: _uid),
        VendorOrdersScreen(vendorId: _uid),
        VendorMenuScreen(vendorId: _uid),
        VendorProfileEditScreen(vendorId: _uid),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E8B57),
        unselectedItemColor: Colors.grey[400],
        selectedFontSize: 11, unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_outlined), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.store_outlined), label: 'Store'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final String uid;
  const _DashboardTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('vendors').doc(uid).snapshots(),
        builder: (_, snap) {
          final v = snap.data?.data() as Map<String, dynamic>? ?? {};
          final isActive = v['isActive'] ?? false;
          return ListView(padding: const EdgeInsets.all(16), children: [

            // Compact Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2E8B57), Color(0xFF4CAF50)]),
                borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v['name'] ?? 'My Kitchen',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(v['category'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: isActive ? Colors.greenAccent : Colors.red.shade300, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(isActive ? 'Open' : 'Closed', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ]),
                ])),
                Column(children: [
                  const Text('Store', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Switch(
                    value: isActive,
                    onChanged: (val) => FirebaseFirestore.instance.collection('vendors').doc(uid).update({'isActive': val}),
                    activeColor: Colors.white, activeTrackColor: const Color(0xFF1A6B3A),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 12),

            // Stats — compact 4 boxes
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').where('vendorId', isEqualTo: uid).snapshots(),
              builder: (_, os) {
                final orders = os.data?.docs ?? [];
                final pending = orders.where((d) => (d.data() as Map)['status'] == 'placed').length;
                final total = orders.fold<double>(0, (s, d) => s + (((d.data() as Map)['total']) ?? 0));
                final delivered = orders.where((d) => (d.data() as Map)['status'] == 'delivered').length;
                return GridView.count(
                  crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.9,
                  children: [
                    _Stat('Orders', '${orders.length}', Icons.receipt_outlined, const Color(0xFF2E8B57)),
                    _Stat('Pending', '$pending', Icons.pending_outlined, Colors.orange, alert: pending > 0),
                    _Stat('Done', '$delivered', Icons.check_circle_outline, Colors.blue),
                    _Stat('৳ Earn', '${total.toInt()}', Icons.payments_outlined, Colors.purple),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),

            // New Orders
            Row(children: [
              const Icon(Icons.notifications_active_outlined, color: Colors.orange, size: 16),
              const SizedBox(width: 6),
              const Text('New Orders', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders')
                .where('vendorId', isEqualTo: uid)
                .where('status', isEqualTo: 'placed').snapshots(),
              builder: (_, snap) {
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Row(children: [
                    Icon(Icons.check_circle_outline, color: Color(0xFF2E8B57), size: 16),
                    SizedBox(width: 8),
                    Text('No new orders', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ]),
                );
                return Column(children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final items = data['items'] as List? ?? [];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('#${data['orderId'].toString().substring(3, 13)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('৳${(data['total'] ?? 0).toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E8B57))),
                      ]),
                      const SizedBox(height: 4),
                      Text(items.map((i) => '${i['name']} x${i['quantity']}').join(', '),
                        style: TextStyle(color: Colors.grey[600], fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: ElevatedButton(
                          onPressed: () => doc.reference.update({'status': 'preparing'}),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(0, 32), padding: const EdgeInsets.symmetric(horizontal: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Text('Accept', style: TextStyle(fontSize: 12)))),
                        const SizedBox(width: 8),
                        Expanded(child: OutlinedButton(
                          onPressed: () => doc.reference.update({'status': 'cancelled'}),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), minimumSize: const Size(0, 32), padding: const EdgeInsets.symmetric(horizontal: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Text('Reject', style: TextStyle(fontSize: 12)))),
                      ]),
                    ]),
                  );
                }).toList());
              },
            ),
          ]);
        },
      )),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value; final IconData icon; final Color color; final bool alert;
  const _Stat(this.label, this.value, this.icon, this.color, {this.alert = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: alert ? color.withOpacity(0.08) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: alert ? Border.all(color: color) : null,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 9), textAlign: TextAlign.center),
    ]),
  );
}
