import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cart_service.dart';
import '../cart/cart_screen.dart';

class VendorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> vendor;
  const VendorProfileScreen({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final vendorId = vendor['id'] ?? '';
    final isDemo = vendor['isDemo'] ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200, pinned: true,
          backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [const Color(0xFF2E8B57), Color(vendor['color'] as int).withOpacity(0.8)])),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                Text(vendor['emoji'], style: const TextStyle(fontSize: 64)),
                Text(vendor['name'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  Text(' ${vendor['rating']} • ${vendor['type']}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ]),
              ]),
            ),
          ),
        ),

        SliverToBoxAdapter(child: Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _InfoChip(Icons.timer_outlined, '${vendor['deliveryTime']} min', 'delivery'),
            const _InfoChip(Icons.percent, '10%', 'commission'),
            const _InfoChip(Icons.delivery_dining_outlined, '৳40', 'delivery fee'),
          ]))),

        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (!isDemo) StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('vendors').doc(vendorId).collection('menu').snapshots(),
              builder: (_, snap) => Text('${snap.data?.docs.length ?? 0} Items', style: const TextStyle(color: Color(0xFF2E8B57), fontWeight: FontWeight.bold))),
          ]))),

        // Real menu from Firestore (for real vendors) or demo menu
        if (!isDemo)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('vendors').doc(vendorId)
              .collection('menu').where('isAvailable', isEqualTo: true).snapshots(),
            builder: (_, snap) {
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) return const SliverToBoxAdapter(
                child: Center(child: Padding(padding: EdgeInsets.all(32),
                  child: Text('No menu items yet', style: TextStyle(color: Colors.grey)))));
              return SliverList(delegate: SliverChildBuilderDelegate((context, i) {
                final data = docs[i].data() as Map<String, dynamic>;
                final menuItem = {'id': docs[i].id, 'name': data['name'] ?? '', 'desc': data['desc'] ?? '', 'price': (data['price'] ?? 0).toDouble(), 'emoji': data['emoji'] ?? '🍛'};
                return _MenuItemCard(item: menuItem, vendor: vendor, cart: cart);
              }, childCount: docs.length));
            })
        else
          SliverList(delegate: SliverChildBuilderDelegate((context, i) {
            final demoMenu = [
              {'id': 'm1', 'name': 'Chicken Biryani', 'desc': 'Fragrant rice with tender chicken', 'price': 220.0, 'emoji': '🍛'},
              {'id': 'm2', 'name': 'Dal Makhani', 'desc': 'Slow-cooked lentils, butter', 'price': 150.0, 'emoji': '🫘'},
              {'id': 'm3', 'name': 'Paratha Set', 'desc': '3 parathas with curry', 'price': 120.0, 'emoji': '🫓'},
              {'id': 'm4', 'name': 'Beef Kala Bhuna', 'desc': 'Slow cooked spicy beef', 'price': 280.0, 'emoji': '🥩'},
              {'id': 'm5', 'name': 'Vegetable Khichuri', 'desc': 'Comfort food with veggies', 'price': 100.0, 'emoji': '🍲'},
              {'id': 'm6', 'name': 'Fish Curry', 'desc': 'Fresh fish in spicy gravy', 'price': 200.0, 'emoji': '🐟'},
            ];
            return _MenuItemCard(item: demoMenu[i], vendor: vendor, cart: cart);
          }, childCount: 6)),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ]),
      bottomNavigationBar: cart.itemCount > 0
        ? Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16)]),
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7F50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                  child: Text('${cart.itemCount} items', style: const TextStyle(fontWeight: FontWeight.bold))),
                const Text('View Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('৳${cart.total.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ])))
        : null,
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final Map<String, dynamic> item, vendor;
  final CartService cart;
  const _MenuItemCard({required this.item, required this.vendor, required this.cart});

  @override
  Widget build(BuildContext context) {
    final cartItems = cart.items.where((i) => i.id == item['id']).toList();
    final qty = cartItems.isNotEmpty ? cartItems.first.quantity : 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Row(children: [
        Container(width: 54, height: 54, decoration: BoxDecoration(color: const Color(0xFFF0F9F4), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(item['emoji'], style: const TextStyle(fontSize: 28)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          if ((item['desc'] ?? '').isNotEmpty) Text(item['desc'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Text('৳${(item['price'] as double).toInt()}', style: const TextStyle(color: Color(0xFF2E8B57), fontWeight: FontWeight.bold, fontSize: 14)),
        ])),
        qty == 0
          ? GestureDetector(
              onTap: () {
                cart.addItem(CartItem(id: item['id'], name: item['name'], price: item['price'], image: item['emoji']), vendor['id'], vendor['name']);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item['name']} added!'), backgroundColor: const Color(0xFF2E8B57), duration: const Duration(seconds: 1)));
              },
              child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFF2E8B57), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 20)))
          : Row(children: [
              GestureDetector(onTap: () => cart.removeItem(item['id']),
                child: Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle), child: const Icon(Icons.remove, size: 16))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              GestureDetector(onTap: () => cart.addItem(CartItem(id: item['id'], name: item['name'], price: item['price'], image: item['emoji']), vendor['id'], vendor['name']),
                child: Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFF2E8B57), shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 16))),
            ]),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String label, sublabel;
  const _InfoChip(this.icon, this.label, this.sublabel);
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: const Color(0xFF2E8B57), size: 20),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    Text(sublabel, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
  ]);
}
